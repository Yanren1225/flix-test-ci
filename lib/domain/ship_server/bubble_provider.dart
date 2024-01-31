import 'dart:convert';
import 'dart:math';

import 'package:androp/domain/ship_server/ship_server.dart';
import 'package:androp/model/bubble/shared_file.dart';
import 'package:androp/model/bubble_entity.dart';
import 'package:androp/model/shareable.dart';
import 'package:androp/model/ship/primitive_bubble.dart';
import 'package:flutter/widgets.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as dev;
import 'package:http_parser/http_parser.dart';

class BubbleProvider extends ChangeNotifier {
  List<BubbleEntity> bubbles = [];

  BubbleProvider() {
    startShipServer().then((server) {
      bubblePipeline.stream.listen((primitiveBubble) {
        var i;
        for (i = 0; i < bubbles.length; i++) {
          final bubble = bubbles[i];
          if (bubble.shareable.id == primitiveBubble.id) {
            break;
          }
        }
        if (i == bubbles.length) {
          bubbles.add(toBubbleEntity(primitiveBubble));
        } else {
          bubbles[i] = toBubbleEntity(primitiveBubble);
        }
        notifyListeners();
      });
    }).catchError((error) {
      dev.log('Error starting ship server: $error');
    });
  }

  Future<void> _send(PrimitiveBubble primitiveBubble) async {
    var uri = Uri.parse('http://192.168.31.149:8099/bubble');

    var response = await http.post(
      uri,
      body: jsonEncode(primitiveBubble.toJson()),
      headers: {"Content-type": "application/json; charset=UTF-8"},
    );

    if (response.statusCode == 200) {
      dev.log('发送成功: response: ${response.body}');
    } else {
      dev.log('发送失败: status code: ${response.statusCode}, ${response.body}');
    }
  }

  Future<void> send(BubbleEntity bubbleEntity) async {
    if (bubbleEntity.shareable is SharedText) {
      final primitiveBubble = fromBubbleEntity(bubbleEntity);
      await _send(primitiveBubble);
      bubblePipeline.add(primitiveBubble);
    } else if (bubbleEntity.shareable is SharedFile) {
      await sendFile(bubbleEntity);
    } else {
      throw UnimplementedError();
    }
  }

  Future<void> sendFile(BubbleEntity bubbleEntity) async {
    if (bubbleEntity.shareable is SharedFile) {
      final fileBubble = fromBubbleEntity(bubbleEntity) as PrimitiveFileBubble;

      var _fileBubble = fileBubble.copy(
          content: fileBubble.content.copy(state: FileShareState.inTransit));
      await _send(_fileBubble);
      bubblePipeline.add(_fileBubble);

      final shardFile = (bubbleEntity.shareable as SharedFile).content!!;

      var request = http.MultipartRequest(
          'POST', Uri.parse('http://192.168.31.149:8099/file'));

      request.fields['share_id'] = bubbleEntity.shareable.id;
      request.fields['file_name'] = shardFile.name;

      var multipartFile = http.MultipartFile(
          'file', shardFile.openRead(), await shardFile.length(),
          filename: shardFile.name,
          contentType: MediaType.parse(shardFile.mimeType ?? 'text/plain'));

      request.files.add(multipartFile);
      final response = await request.send();
      if (response.statusCode == 200) {
        dev.log('发送成功 ${await response.stream.bytesToString()}');
        _fileBubble = fileBubble.copy(
            content:
                fileBubble.content.copy(state: FileShareState.sendCompleted));
        _send(_fileBubble);
        bubblePipeline.add(_fileBubble);
      } else {
        dev.log(
            '发送失败: status code: ${response.statusCode}, ${await response.stream.bytesToString()}');
        // TODO 区分发送失败还是接收失败
        _fileBubble = fileBubble.copy(
            content: fileBubble.content.copy(state: FileShareState.sendFailed));
        _send(_fileBubble);
        bubblePipeline.add(_fileBubble);
      }
    } else {
      throw UnimplementedError();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  PrimitiveBubble fromBubbleEntity(BubbleEntity bubbleEntity) {
    if (bubbleEntity.shareable is SharedText) {
      final sharedText = bubbleEntity.shareable as SharedText;
      return PrimitiveTextBubble(
          id: sharedText.id,
          type: BubbleType.Text,
          content: sharedText.content);
    } else if (bubbleEntity.shareable is SharedFile) {
      final sharedFile = bubbleEntity.shareable as SharedFile;
      return PrimitiveFileBubble(
          id: sharedFile.id,
          type: BubbleType.File,
          content: FileTransfer(
              meta: sharedFile.meta, state: sharedFile.shareState));
    } else {
      throw UnimplementedError();
    }
  }

  BubbleEntity toBubbleEntity(PrimitiveBubble bubble) {
    const device0 = 'Xiaomi 13';
    const device1 = 'Macbook';
    final random = Random();
    final fromMe = random.nextBool();
    final from = fromMe ? device0 : device1;
    final to = fromMe ? device1 : device0;
    switch (bubble.type) {
      case BubbleType.Text:
        return BubbleEntity(
            from: from,
            to: to,
            shareable: SharedText(
                id: bubble.id,
                content: (bubble as PrimitiveTextBubble).content));
      case BubbleType.Image:
        throw UnimplementedError();
      case BubbleType.Video:
        throw UnimplementedError();
      case BubbleType.File:
        final primitive = (bubble as PrimitiveFileBubble);
        return BubbleEntity(
            from: from,
            to: to,
            shareable: SharedFile(
                id: bubble.id,
                shareState: primitive.content.state,
                meta: primitive.content.meta));
    }
  }
}
