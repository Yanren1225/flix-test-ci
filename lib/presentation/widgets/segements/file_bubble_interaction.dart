import 'dart:developer';
import 'dart:io';

import 'package:downloadsfolder/downloadsfolder.dart';
import 'package:flix/domain/androp_context.dart';
import 'package:flix/domain/concert/concert_provider.dart';
import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/model/ui_bubble/ui_bubble.dart';
import 'package:flix/presentation/widgets/segements/bubble_context_menu.dart';
import 'package:flix/utils/file/file_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:modals/modals.dart';
import 'package:open_dir/open_dir.dart';
import 'package:open_filex/open_filex.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class FileBubbleInteraction extends StatefulWidget {
  final UIBubble bubble;
  final String filePath;
  final Widget child;
  final bool clickable;

  FileBubbleInteraction(
      {super.key,
      required this.bubble,
      required this.filePath,
      required this.child,
      required this.clickable});


  @override
  State<StatefulWidget> createState() => FileBubbleIneractionState();
}

class FileBubbleIneractionState extends State<FileBubbleInteraction>
    with TickerProviderStateMixin {
  var tapDownTime = 0;
  Offset? tapDown = null;
  late String contextMenuTag;


  @override
  void initState() {
    super.initState();
    contextMenuTag = Uuid().v4();
  }

  @override
  Widget build(BuildContext context) {
    AndropContext andropContext = context.watch();
    ConcertProvider concertProvider = Provider.of(context, listen: false);
    final _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 100),
    );

    final _animation = Tween<double>(begin: 1, end: 0.96)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut))
      ..addListener(() {
        // setState(() {});
      });

    return ModalAnchor(
      tag: contextMenuTag,
      child: InkWell(
          radius: 10,
          borderRadius: BorderRadius.circular(10),
          onTapDown: (details) {
            if (!widget.clickable) return;
            tapDown = details.localPosition;
            // 记下按下的时间
            tapDownTime = DateTime.now().millisecondsSinceEpoch;
            talker.debug('gesture details: ');
            // details.kind?.index == 0
            _controller.forward();
          },
          onTapUp: (_) {
            if (!widget.clickable) return;

            final diff = DateTime.now().millisecondsSinceEpoch - tapDownTime;
            talker.debug('gesture time diff: $diff');
            if (DateTime.now().millisecondsSinceEpoch - tapDownTime < 60) {
              Future.delayed(Duration(milliseconds: 60 - diff + 100), () {
                _controller.reverse();
              });
            } else {
              _controller.reverse();
            }
            tapDownTime = 0;
          },
          onTapCancel: () {
            if (!widget.clickable) return;
            _controller.reverse();
          },
          // onDoubleTap: () {
          //   if (!widget.clickable) return;
          //   _openDir();
          // },
          onTap: () {
            if (!widget.clickable) return;
            // _controller.forward().whenComplete(() => _controller.reverse());
            talker.debug('filePath: ${widget.filePath}');
            OpenFilex.open(widget.filePath).then((value) {
              if (value.type != ResultType.done) {
                talker.error(
                    'Failed open file: ${widget.filePath}, result: $value');
                _openDir();
              }
            });
          },
          onSecondaryTapDown: (detials) {
            if (!widget.clickable) return;
            _showBubbleContextMenu(context, detials.localPosition, andropContext, concertProvider);
          },
          onLongPress: () {
            if (!widget.clickable) return;
            if (tapDown == null) {
              return;
            }
            HapticFeedback.mediumImpact();
            _showBubbleContextMenu(context, tapDown! , andropContext, concertProvider);
          },
          child: ScaleTransition(scale: _animation, child: widget.child)),
    );
  }

  void _showBubbleContextMenu(BuildContext context, Offset clickPosition, AndropContext andropContext,
      ConcertProvider concertProvider) {
    showBubbleContextMenu(context, contextMenuTag, clickPosition, andropContext.deviceId,
        concertProvider.concertMainKey, widget.bubble, [
      // BubbleContextMenuItemType.Copy,
      BubbleContextMenuItemType.Location,
    ], {
      // BubbleContextMenuItemType.Copy: () {
      //   _copyContentToClipboard();
      // },
      BubbleContextMenuItemType.Location: () {
        _openDir();
      }
    });
  }

  void _openDir() {
    if (Platform.isIOS || Platform.isAndroid) {
      openDownloadFolder().then((value) {
        if (value) {
          print('Download folder opened successfully');
        } else {
          print('Failed to open download folder');
        }
      }).catchError((error, stackTrace) =>
          print('Failed to open download folder: $error'));
    } else {
      getDefaultDestinationDirectory()
          .then((value) => OpenDir().openNativeDir(
              path: Platform.isWindows
                  ? File(widget.filePath).parent.path
                  : widget.filePath))
          .catchError(
              (error) => print('Failed to open download folder: $error'));
    }
  }
}
