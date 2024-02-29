import 'dart:developer';

import 'package:anydrop/domain/bubble_pool.dart';
import 'package:anydrop/model/ship/primitive_bubble.dart';

extension StreamProgress on Stream<List<int>> {
  Stream<List<int>> progress(String bubbleId) {
    var byteCount = 0;
    var lastTime = DateTime.now().millisecondsSinceEpoch;
    return asyncMap((data) async {
      byteCount += data.length;

      final current = DateTime.now().millisecondsSinceEpoch;
      lastTime = current;
      final bubble = await BubblePool.instance.findLastById(bubbleId)
          as PrimitiveFileBubble;
      final updatedBubble = bubble.copy(
        content: bubble.content
            .copy(progress: byteCount.toDouble() / bubble.content.meta.size),
      );
      log("file transfer, byteCount: $byteCount, size: ${bubble.content.meta.size}");

      await BubblePool.instance.add(updatedBubble);

      return data;
    });
  }
}
