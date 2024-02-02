import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:androp/domain/concert/concert_service.dart';
import 'package:androp/domain/device/device_manager.dart';
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
  // final _concertService = ConcertService();
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
    var uri = Uri.parse(
        'http://${DeviceManager.instance.getNetAdressByDeviceId(primitiveBubble.to)}/bubble');

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
      await sendFile(fromBubbleEntity(bubbleEntity) as PrimitiveFileBubble);
    } else if (bubbleEntity.shareable is SharedImage) {
      await sendFile(fromBubbleEntity(bubbleEntity) as PrimitiveFileBubble);
    } else {
      throw UnimplementedError();
    }
  }

  Future<void> sendFile(PrimitiveFileBubble fileBubble) async {
    var _fileBubble = fileBubble.copy(
        content: fileBubble.content.copy(state: FileShareState.inTransit));
    await _send(_fileBubble);
    bubblePipeline.add(_fileBubble);

    final shardFile = fileBubble.content.meta;

    var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'http://${DeviceManager.instance.getNetAdressByDeviceId(fileBubble.to)}/file'));

    request.fields['share_id'] = fileBubble.id;
    request.fields['file_name'] = shardFile.name;

    var multipartFile = http.MultipartFile(
        'file', File(shardFile.path!).openRead(), shardFile.size,
        filename: shardFile.name,
        contentType: MediaType.parse(shardFile.mimeType ?? 'text/plain'));

    request.files.add(multipartFile);
    final response = await request.send();
    if (response.statusCode == 200) {
      dev.log('发送成功 ${await response.stream.bytesToString()}');
      _fileBubble = fileBubble.copy(
          content:
              fileBubble.content.copy(state: FileShareState.sendCompleted));
      // _send(_fileBubble);
      bubblePipeline.add(_fileBubble);
    } else {
      dev.log(
          '发送失败: status code: ${response.statusCode}, ${await response.stream.bytesToString()}');
      // TODO 区分发送失败还是接收失败
      _fileBubble = fileBubble.copy(
          content: fileBubble.content.copy(state: FileShareState.sendFailed));
      // _send(_fileBubble);
      bubblePipeline.add(_fileBubble);
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
          from: bubbleEntity.from,
          to: bubbleEntity.to,
          type: BubbleType.Text,
          content: sharedText.content);
    } else if (bubbleEntity.shareable is SharedFile) {
      final sharedFile = bubbleEntity.shareable as SharedFile;
      return PrimitiveFileBubble(
          id: sharedFile.id,
          from: bubbleEntity.from,
          to: bubbleEntity.to,
          type: BubbleType.File,
          content: FileTransfer(
              meta: sharedFile.meta, state: sharedFile.shareState));
    } else if (bubbleEntity.shareable is SharedImage) {
      final sharedFile = bubbleEntity.shareable as SharedImage;
      return PrimitiveFileBubble(
          id: sharedFile.id,
          from: bubbleEntity.from,
          to: bubbleEntity.to,
          type: BubbleType.Image,
          content: FileTransfer(
              meta: sharedFile.content, state: FileShareState.inTransit));
    } else {
      throw UnimplementedError();
    }
  }

  BubbleEntity toBubbleEntity(PrimitiveBubble bubble) {
    switch (bubble.type) {
      case BubbleType.Text:
        return BubbleEntity(
            from: bubble.from,
            to: bubble.to,
            shareable: SharedText(
                id: bubble.id,
                content: (bubble as PrimitiveTextBubble).content));
      case BubbleType.Image:
        final primitive = (bubble as PrimitiveFileBubble);
        return BubbleEntity(
            from: bubble.from,
            to: bubble.to,
            shareable:
                SharedImage(id: bubble.id, content: primitive.content.meta));
      case BubbleType.Video:
        throw UnimplementedError();
      case BubbleType.File:
        final primitive = (bubble as PrimitiveFileBubble);
        return BubbleEntity(
            from: bubble.from,
            to: bubble.to,
            shareable: SharedFile(
                id: bubble.id,
                shareState: primitive.content.state,
                meta: primitive.content.meta));
    }
  }
}
