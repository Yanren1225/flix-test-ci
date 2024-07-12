import 'dart:async';

import 'package:flix/domain/bubble_pool.dart';
import 'package:flix/domain/database/database.dart';
import 'package:flix/domain/ship_server/ship_service_proxy.dart';

import '../../model/ship/primitive_bubble.dart';
import '../../model/ui_bubble/ui_bubble.dart';
import '../../utils/bubble_convert.dart';

/// Concert：表示设备间文件互传的会话
/// 负责：
/// 持久化层和表示层的通信，
/// 文件传输服务和表示层的通信
class ConcertService {
  // 负责承载底层的互传消息
  final String collaboratorId;
  // final _bubblePool = BubblePool.instance;

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


  Future<void> send(UIBubble uiBubble) async {
    return await shipService.send(uiBubble);
  }

  Future<void> confirmReceive(UIBubble uiBubble) async {
    return await shipService.confirmReceive(uiBubble.from, uiBubble.shareable.id);
  }

  Future<void> cancelSend(UIBubble uiBubble) async {
    return await shipService.cancelSend(uiBubble);
  }

  Future<void> cancelReceive(UIBubble uiBubble) async {
    return await shipService.cancelReceive(uiBubble);
  }

  Future<void> resend(UIBubble uiBubble) async {
    return await shipService.resend(uiBubble);
  }

  Future<void> deleteBubble(UIBubble uiBubble) async {
    // if (uiBubble.shareable is SharedText) {
      await BubblePool.instance.deleteBubble(uiBubble);
    // } else {
    //   await BubblePool.instance.deleteBubble(uiBubble);
    //   // TODO 取消发送或者接收
    // }
  }

  Future<void> updateFilePath(UIBubble uiBubble, String path) async {
    final bubble = fromUIBubble(uiBubble) as PrimitiveFileBubble;
    await BubblePool.instance.add(bubble.copy(content: bubble.content.copy(meta: bubble.content.meta.copy(path: path))));
  }
}
