
import 'package:flix/model/ui_bubble/shareable.dart';
import 'package:flix/model/ui_bubble/ui_bubble.dart';
import 'package:flix/presentation/widgets/app_icon.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/androp_context.dart';

class ShareAppBubble extends StatelessWidget {
  final UIBubble entity;

  const ShareAppBubble({super.key, required this.entity});

  @override
  Widget build(BuildContext context) {
    AndropContext andropContext = context.watch();
    final SharedApp sharedApp = entity.shareable as SharedApp;
    final Color backgroundColor;
    if (entity.isFromMe(andropContext.deviceId)) {
      backgroundColor = const Color.fromRGBO(0, 122, 255, 1);
    } else {
      backgroundColor = Colors.white;
    }

    final Color contentColor;
    if (entity.isFromMe(andropContext.deviceId)) {
      contentColor = Colors.white;
    } else {
      contentColor = Colors.black;
    }

    final Alignment alignment;
    if (entity.isFromMe(andropContext.deviceId)) {
      alignment = Alignment.centerRight;
    } else {
      alignment = Alignment.centerLeft;
    }
    return Align(
      alignment: alignment,
      child: Container(
        decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: const BorderRadius.all(Radius.circular(10))),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return ConstrainedBox(
              constraints: BoxConstraints(maxWidth: constraints.maxWidth - 60),
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 16, top: 12, right: 16, bottom: 12),
                child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image(
                        image: AppIcon(app: sharedApp.content),
                        width: 50,
                        height: 50,
                      ),
                      const SizedBox(
                        width: 16,
                      ),
                      Flexible(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sharedApp.content.appName,
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: contentColor),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              sharedApp.content.packageName,
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: contentColor.withOpacity(0.5)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )
                          ],
                        ),
                      ),
                    ]),
              ),
            );
          },
        ),
      ),
    );
  }
}
