import 'package:flix/domain/bubble_pool.dart';
import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/domain/ship_server/ship_service_proxy.dart';
import 'package:flix/model/ship/primitive_bubble.dart';

extension StreamProgress on Stream<List<int>> {
  Stream<List<int>>  progress(PrimitiveFileBubble bubble,int receiveBytes) {
    var byteCount = 0;
    var lastByteCount = 0;
    var lastTime = DateTime.now().millisecondsSinceEpoch;
    return asyncMap((data) async {
      byteCount += data.length;

      final current = DateTime.now().millisecondsSinceEpoch;
      final timeDiff = current - lastTime;
      final byteDiff = byteCount - lastByteCount;
      if (timeDiff > 1000) {
        lastTime = current;
        lastByteCount = byteCount;
        final updatedBubble = bubble.copy(
          content: bubble.content
              .copy(progress: (byteCount.toDouble()+receiveBytes) / bubble.content.meta.size,receiveBytes: byteCount, speed: (byteDiff / timeDiff * 1000).ceil()),
        );
        // talker.debug("StreamProgress",
        //     "file progress change, path=${bubble.content.meta.path} byteCount: $byteCount ,receiveBytes = $receiveBytes, , size: ${bubble.content.meta.size}");
        // 异步插入，减少对发送和接收的阻塞
        BubblePool.instance.add(updatedBubble);
      }

      return data;
    });
  }
}
