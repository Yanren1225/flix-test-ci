import 'dart:developer';

import 'package:androp/domain/bubble_pool.dart';
import 'package:androp/model/ship/primitive_bubble.dart';

extension StreamProgress on Stream<List<int>> {
  Stream<List<int>> progress(PrimitiveFileBubble bubble) {
    var byteCount = 0;
    var lastTime = DateTime.now().millisecondsSinceEpoch;
    return asyncMap((data) async {
      byteCount += data.length;

      log("file transfer, byteCount: $byteCount, size: ${bubble.content.meta.size}");
      final current = DateTime.now().millisecondsSinceEpoch;
      // if (current - lastTime >= 100) {
        lastTime = current;
        // final _bubble = await BubblePool.instance.findLastById(bubble.id);
        // if (_bubble == null || _bubble is! PrimitiveFileBubble) {
        //   throw StateError('Can\'t find PrimitiveFileBubble with id: ${bubble.id}');
        // }
        final updatedBubble = bubble.copy(
          content: bubble.content
              .copy(progress: byteCount.toDouble() / bubble.content.meta.size),
        );
        await BubblePool.instance.add(updatedBubble);
      // }

      return data;
    });
  }
}
