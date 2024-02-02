import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:androp/model/bubble/shared_file.dart';
import 'package:androp/model/ship/primitive_bubble.dart';
import 'package:androp/network/multicast_util.dart';
import 'package:androp/utils/iterable_extension.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_multipart/form_data.dart';
import 'package:shelf_multipart/multipart.dart';
import 'package:shelf_router/shelf_router.dart';

import '../../utils/file/file_helper.dart';

final bubblePipeline = StreamController<PrimitiveBubble>.broadcast();
final _cache = <PrimitiveBubble>[];

PrimitiveBubble? getBubbleById(String id) {
  return _cache.find((element) => element.id == id);
}

void removeBubbleById(String id) {
  _cache.removeWhere((element) => element.id == id);
}

Future<HttpServer> startShipServer() async {
  bubblePipeline.stream.listen((event) {
    var i = 0;
    for (i; i < _cache.length; i++) {
      final bubble = _cache[i];
      if (bubble.id == event.id) {
        break;
      }
    }
    if (i == _cache.length) {
      _cache.add(event);
    } else {
      _cache[i] = event;
    }
  });

  var app = Router();
  app.post('/bubble', _receiveBubble);
  app.post('/file', _reciveFile);

  var server = await io.serve(app, '0.0.0.0', MultiCastUtil.defaultPort);

  log('Servering at http://0.0.0.0:${MultiCastUtil.defaultPort}');
  return server;
}

Future<Response> _receiveBubble(Request request) async {
  var body = await request.readAsString();
  var data = jsonDecode(body) as Map<String, dynamic>;
  var bubble = PrimitiveBubble.fromJson(data);
  bubblePipeline.add(bubble);
  return Response.ok('receviced bubble');
}

Future<Response> _reciveFile(Request request) async {
  if (!request.isMultipart) {
    return Response.badRequest();
  } else if (request.isMultipartForm) {
    final description = StringBuffer('Parsed form multipart request\n');

    var shareId = "";
    await for (final formData in request.multipartFormData) {
      switch (formData.name) {
        case 'share_id':
          shareId = await formData.part.readString();
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
          formData.part.pipe(out);
          final bubble = getBubbleById(shareId);
          if (bubble == null) {
            throw StateError(
                'Primitive Bubble with id: $shareId should not null.');
          }

          if (!(bubble is PrimitiveFileBubble)) {
            throw StateError('Primitive Bubble should be PrimitiveFileBubble');
          }

          final fileBubble = bubble as PrimitiveFileBubble;
          final updatedBubble = fileBubble.copy(
              content: fileBubble.content.copy(
                  state: FileShareState.receiveCompleted,
                  meta: fileBubble.content.meta.copy(path: filePath)));
          removeBubbleById(updatedBubble.id);
          bubblePipeline.add(updatedBubble);
          break;
      }
    }

    return Response.ok(description.toString());
  } else {

    return Response.badRequest();
  }
}

// class ShipService {
//
//   ShipService._privateConstruct();
//
//   static final ShipService _instance = ShipService._privateConstruct();
//
//   static ShipService get instance => _instance;
//
//
// }



