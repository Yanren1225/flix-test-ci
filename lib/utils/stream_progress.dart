import 'dart:developer';

import 'package:androp/domain/bubble_pool.dart';
import 'package:androp/model/ship/primitive_bubble.dart';

extension StreamProgress on Stream<List<int>> {
  Stream<List<int>> progress(PrimitiveFileBubble bubble) {
    var byteCount = 0;
    var lastTime = DateTime.now().millisecondsSinceEpoch;
    return map((data) {
      byteCount += data.length;
      log("file transfer, byteCount: $byteCount, size: ${bubble.content.meta.size}");
      final current = DateTime.now().millisecondsSinceEpoch;
      if (current - lastTime >= 1000) {
        lastTime = current;
        final updatedBubble = bubble.copy(
          content: bubble.content
              .copy(progress: byteCount.toDouble() / bubble.content.meta.size),
        );
        BubblePool.instance.add(updatedBubble);
      }

      return data;
    });
  }
}
