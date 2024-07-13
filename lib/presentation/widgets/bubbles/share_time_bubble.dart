import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/model/ui_bubble/ui_bubble.dart';
import 'package:flix/theme/theme_extensions.dart';
import 'package:flix/utils/text/text_extension.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ShareTimeBubble extends StatefulWidget {
  final UIBubble entity;

  const ShareTimeBubble({super.key, required this.entity});

  @override
  State<StatefulWidget> createState() => ShareTimeBubbleState();
}

class ShareTimeBubbleState extends State<ShareTimeBubble> {
  UIBubble get entity => widget.entity;
  Offset? tapDown;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.center,
        child: Text(formatTime(entity.time),
            style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).flixColors.text.secondary)
                .fix()));
  }

  String formatTime(int time) {
    try {
      final dateTime = DateTime.fromMillisecondsSinceEpoch(time);
      final now = DateTime.now();
      final formatter = DateFormat("yyyy/MM/dd HH:mm");
      final todayStart = DateTime(now.year, now.month, now.day);
      final yesterdayStart = DateTime(now.year, now.month, now.day - 1);
      final twoDaysAgoStart = DateTime(now.year, now.month, now.day - 2);

      if (dateTime.millisecondsSinceEpoch >=
          todayStart.millisecondsSinceEpoch) {
        // 当天的时间，只显示分钟和秒
        return formatter.format(dateTime).substring(11); // 截取"HH:mm:ss"部分
      } else if (dateTime.millisecondsSinceEpoch >=
              yesterdayStart.millisecondsSinceEpoch &&
          dateTime.millisecondsSinceEpoch < todayStart.millisecondsSinceEpoch) {
        // 昨天的时间，显示"昨天 HH:mm:ss"
        return '昨天 ${formatter.format(dateTime).substring(11)}';
      } else if (dateTime.millisecondsSinceEpoch >=
              twoDaysAgoStart.millisecondsSinceEpoch &&
          dateTime.millisecondsSinceEpoch <
              yesterdayStart.millisecondsSinceEpoch) {
        // 前天的时间，只显示日期
        return formatter.format(dateTime).substring(0, 10); // 截取"yyyy-MM-dd"部分
      } else {
        // 其他时间，显示完整日期和时间
        return formatter.format(dateTime);
      }
    } catch (e, s) {
      talker.error('failed to format time', e, s);
      return "";
    }
  }
}
