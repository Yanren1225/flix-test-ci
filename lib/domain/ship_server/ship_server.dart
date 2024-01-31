import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:androp/model/bubble_entity.dart';
import 'package:androp/model/ship/primitive_bubble.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_multipart/form_data.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_multipart/multipart.dart';

final bubblePipeline = StreamController<PrimitiveBubble>();

Future<HttpServer> startShipServer() async {
  var app = Router();
  app.post('/bubble', _receiveBubble);
  app.post('/file', _reciveFile);

  var server = await io.serve(app, '0.0.0.0', 8099);

  log('Servering at http://0.0.0.0:8099');
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
  // if (!request.isMultipart) {
  //   return Response(401); // not a multipart request
  // }

  // IOSink? out;

  // await for (final part in request.parts) {

  //   // Headers are available through part.headers as a map:
  //   final headers = part.headers;

  //   if (out == null) {
  //     final fileName = headers['file_name'];
  //     final Directory? downloadsDir = await getDownloadsDirectory();
  //     final outFile = File('${downloadsDir!.path!}/$fileName');
  //     log('writing file to ${outFile.path}');
  //     if (!(await outFile.exists())) {
  //       await outFile.create();
  //     }
  //     out = outFile.openWrite(mode: FileMode.append);
  //   }

  //   // part implements the `Stream<List<int>>` interface which can be used to
  //   // read data. You can also use `part.readBytes()` or `part.readString()`
  //   part.pipe(out);
  // }

  // return Response(200);

  if (!request.isMultipart) {
    return Response.badRequest();
  } else if (request.isMultipartForm) {
    final description = StringBuffer('Parsed form multipart request\n');

    await for (final formData in request.multipartFormData) {
      switch (formData.name) {
        case 'share_id':
          break;
        case 'file':
          final Directory? downloadsDir = await getDownloadsDirectory();
          final outFile = File('${downloadsDir!.path!}/${formData.filename}.json');
          log('writing file to ${outFile.path}');
          if (!(await outFile.exists())) {
            await outFile.create();
          }
          final out = outFile.openWrite(mode: FileMode.append);
          formData.part.pipe(out);
          break;
      }
    }

    return Response.ok(description.toString());
  } else {
    final description = StringBuffer('Regular multipart request\n');

    await for (final part in request.parts) {
      description.writeln('new part');

      part.headers
          .forEach((key, value) => description.writeln('Header $key=$value'));
      final content = await part.readString();
      description.writeln('content: $content');

      description.writeln('end of part');
    }

    return Response.ok(description.toString());
  }
}
