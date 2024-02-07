import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';

import 'package:androp/domain/bubble_pool.dart';
import 'package:androp/domain/database/database.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../../model/ui_bubble/ui_bubble.dart';
import '../../model/ui_bubble/shareable.dart';
import '../../model/ship/primitive_bubble.dart';
import '../../model/ui_bubble/shared_file.dart';
import '../../utils/bubble_convert.dart';
import '../device/device_manager.dart';
import 'package:async/async.dart' show StreamGroup;

/// Concert：表示设备间文件互传的会话
/// 负责：
/// 持久化层和表示层的通信，
/// 文件传输服务和表示层的通信
class ConcertService {
  // 负责承载底层的互传消息
  final String collaboratorId;
  final _bubblePool = BubblePool.instance;

  StreamSubscription<List<UIBubble>>? streamSubscription;

  ConcertService({required this.collaboratorId});

  void listenBubbles(void Function(List<UIBubble> bubbles) onData) {
    streamSubscription = appDatabase.bubblesDao
        .watchBubblesByCid(collaboratorId)
        .map((bubbles) => bubbles.map((e) => toUIBubble(e)).toList())
        .listen(onData);
  }

  void clear() {
    streamSubscription?.cancel();
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

  Future<void> send(UIBubble uiBubble) async {
    switch (uiBubble.type) {
      case BubbleType.Text:
        final primitiveBubble = fromUIBubble(uiBubble);
        await _bubblePool.add(primitiveBubble);
        await _send(primitiveBubble);
        break;
      case BubbleType.Image:
      case BubbleType.Video:
      case BubbleType.File:
        await _sendFile(fromUIBubble(uiBubble) as PrimitiveFileBubble);
        break;
      case BubbleType.App:
        throw UnimplementedError();
    }
  }

  Future<void> _sendFile(PrimitiveFileBubble fileBubble) async {
    var _fileBubble = fileBubble.copy(
        content: fileBubble.content.copy(state: FileState.inTransit));
    await _bubblePool.add(_fileBubble);
    // send with no path
    await _send(_fileBubble.copy(content: _fileBubble.content.copy(meta: _fileBubble.content.meta.copy(path: null))));

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
        contentType: MediaType.parse(shardFile.mimeType));

    request.files.add(multipartFile);
    final response = await request.send();
    if (response.statusCode == 200) {
      dev.log('发送成功 ${await response.stream.bytesToString()}');
      _updateFileShareState(fileBubble.id, FileState.sendCompleted);
    } else {
      dev.log(
          '发送失败: status code: ${response.statusCode}, ${await response.stream.bytesToString()}');
      _updateFileShareState(fileBubble.id, FileState.sendFailed);
    }
  }

  Future<void> _updateFileShareState(String bubbleId, FileState state) async {
    final _bubble = await _bubblePool.findLastById(bubbleId);
    if (_bubble == null) {
      throw StateError('Can\'t find bubble by id: $bubbleId');
    }

    if (!(_bubble is PrimitiveFileBubble)) {
      throw StateError('The Bubble with id: $bubbleId is not a file bubble');
    }

    final _fileBubble = _bubble! as PrimitiveFileBubble;
    // final updateBubble = UpdateFileStateBubble(id: bubbleId, from: _fileBubble.from, to: _fileBubble.to, type: _fileBubble.type, content: state);

    // _send(updateBubble);

    // _bubblePool.add(updateBubble);
  }
}
