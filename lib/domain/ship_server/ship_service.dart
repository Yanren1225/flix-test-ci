import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:androp/domain/bubble_pool.dart';
import 'package:androp/model/ui_bubble/shared_file.dart';
import 'package:androp/model/ship/primitive_bubble.dart';
import 'package:androp/network/multicast_util.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_multipart/form_data.dart';
import 'package:shelf_multipart/multipart.dart';
import 'package:shelf_router/shelf_router.dart';

import '../../utils/file/file_helper.dart';

class ShipService {
  ShipService._privateConstruct();

  static final ShipService _instance = ShipService._privateConstruct();

  static ShipService get instance => _instance;

  final _bubblePool = BubblePool.instance;

  Future<HttpServer> startShipServer() async {
    var app = Router();
    app.post('/bubble', _receiveBubble);
    app.post('/file', _receiveFile);

    var server = await io.serve(app, '0.0.0.0', MultiCastUtil.defaultPort);

    log('Servering at http://0.0.0.0:${MultiCastUtil.defaultPort}');
    return server;
  }

  Future<Response> _receiveBubble(Request request) async {
    var body = await request.readAsString();
    var data = jsonDecode(body) as Map<String, dynamic>;
    var bubble = PrimitiveBubble.fromJson(data);
    await _bubblePool.add(bubble);
    return Response.ok('received bubble');
  }

  Future<Response> _receiveFile(Request request) async {
    if (!request.isMultipart) {
      return Response.badRequest();
    } else if (request.isMultipartForm) {
      final description = StringBuffer('Parsed form multipart request\n');

      PrimitiveBubble? bubble;
      await for (final formData in request.multipartFormData) {
        switch (formData.name) {
          case 'share_id':
            final shareId = await formData.part.readString();
            bubble = await _bubblePool.findLastById(shareId);
            if (bubble == null) {
              throw StateError(
                  'Primitive Bubble with id: $shareId should not null.');
            }

            if (!(bubble is PrimitiveFileBubble)) {
              throw StateError(
                  'Primitive Bubble should be PrimitiveFileBubble');
            }
            break;
          case 'file':
            final String desDir = await getDefaultDestinationDirectory();
            final String filePath = '$desDir/${formData.filename}';
            final outFile = File(filePath);
            log('writing file to ${outFile.path}');
            if (!(await outFile.exists())) {
              await outFile.create();
            }
            final out = outFile.openWrite(mode: FileMode.append);
            await formData.part.pipe(out);

            final fileBubble = bubble as PrimitiveFileBubble;
            final updatedBubble = fileBubble.copy(
                content: fileBubble.content.copy(
                    state: FileState.receiveCompleted,
                    meta: fileBubble.content.meta.copy(path: filePath)));
            // removeBubbleById(updatedBubble.id);
            await _bubblePool.add(updatedBubble);
            break;
        }
      }

      return Response.ok(description.toString());
    } else {
      return Response.badRequest();
    }
  }
}
