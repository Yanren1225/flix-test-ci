import 'dart:developer';

import 'package:flix/domain/bubble_pool.dart';
import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/model/ship/primitive_bubble.dart';

extension StreamProgress on Stream<List<int>> {
  Stream<List<int>> progress(String bubbleId) {
    var byteCount = 0;
    var lastTime = DateTime.now().millisecondsSinceEpoch;
    return asyncMap((data) async {
      byteCount += data.length;

      final current = DateTime.now().millisecondsSinceEpoch;
      if (current - lastTime > 1000) {
        lastTime = current;
        final bubble = await BubblePool.instance.findLastById(bubbleId)
            as PrimitiveFileBubble;
        final updatedBubble = bubble.copy(
          content: bubble.content
              .copy(progress: byteCount.toDouble() / bubble.content.meta.size),
        );
        talker.debug(
            "file transfer, byteCount: $byteCount, size: ${bubble.content.meta.size}");

        // 异步插入，减少对发送和接收的阻塞
        BubblePool.instance.add(updatedBubble);
      }

      return data;
    });
  }
}
