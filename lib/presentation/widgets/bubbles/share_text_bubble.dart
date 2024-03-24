import 'package:flix/domain/androp_context.dart';
import 'package:flix/domain/concert/concert_provider.dart';
import 'package:flix/model/ui_bubble/shareable.dart';
import 'package:flix/model/ui_bubble/ui_bubble.dart';
import 'package:flix/presentation/widgets/segements/bubble_context_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modals/modals.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/v4.dart';

class ShareTextBubble extends StatelessWidget {
  final UIBubble entity;
  Offset? tapDown ;
  final contextMenuTag = Uuid().v4();

  ShareTextBubble({super.key, required this.entity});

  @override
  Widget build(BuildContext context) {
    AndropContext andropContext = context.watch();
    ConcertProvider concertProvider = Provider.of(context, listen: false);
    final SharedText sharedText = entity.shareable as SharedText;
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
      child: LayoutBuilder(
        builder: (_context, _) => Material(
          color: backgroundColor,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          child: InkWell(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            onSecondaryTapDown: (TapDownDetails details) {
              _showBubbleContextMenu(_context, details.localPosition, andropContext, concertProvider);
            },
            onTapDown: (TapDownDetails details) {
              tapDown = details.localPosition;
            },
            onLongPress: () {
              if (tapDown == null) {
                return;
              }
              HapticFeedback.mediumImpact();
              _showBubbleContextMenu(_context, tapDown!, andropContext, concertProvider);
            },
            onTap: () {
             _copyContentToClipboard();
            },
            child: ModalAnchor(
              key: ValueKey(entity.shareable.id),
              tag: contextMenuTag,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                  sharedText.content,
                  style: TextStyle(
                      color: contentColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w400),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showBubbleContextMenu(BuildContext context, Offset clickPosition, AndropContext andropContext,
      ConcertProvider concertProvider) {
    return showBubbleContextMenu(context, contextMenuTag, clickPosition , andropContext.deviceId,
        concertProvider.concertMainKey, entity, [
      BubbleContextMenuItemType.Copy,
      // BubbleContextMenuItemType.Location,
    ], {
      BubbleContextMenuItemType.Copy: () {
        _copyContentToClipboard();
      }
    });
  }

  void _copyContentToClipboard() {
    Clipboard.setData(ClipboardData(text: (entity.shareable as SharedText).content));
    Fluttertoast.showToast(
        msg: "已复制到剪切板",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey.shade200,
        textColor: Colors.black,
        fontSize: 16.0);
  }
}
