import 'dart:developer';
import 'dart:io';

import 'package:downloadsfolder/downloadsfolder.dart';
import 'package:flix/domain/androp_context.dart';
import 'package:flix/domain/concert/concert_provider.dart';
import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/model/ui_bubble/ui_bubble.dart';
import 'package:flix/presentation/widgets/bubble_context_menu/delete_message_bottom_sheet.dart';
import 'package:flix/presentation/widgets/segements/bubble_context_menu.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_app_installer/flutter_app_installer.dart';
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
            radius: 12,
            borderRadius: BorderRadius.circular(12),
            onTapDown: (details) {
              tapDown = details.localPosition;
              // 记下按下的时间
              tapDownTime = DateTime.now().millisecondsSinceEpoch;
              talker.debug('gesture details: ');
              // details.kind?.index == 0
              _controller.forward();
            },
            onTapUp: (_) {
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
              _controller.reverse();
            },
            // onDoubleTap: () {
            //   if (!widget.clickable) return;
            //   _openDir();
            // },
            onTap: () async {
              if (!widget.clickable) return;
              // _controller.forward().whenComplete(() => _controller.reverse());
              _openFile(widget.filePath).then((isSuccess) {
                if (!isSuccess) {
                  _openDir();
                }
              });
            },
            onSecondaryTapDown: (detials) {
              _showBubbleContextMenu(context, detials.localPosition,
                  andropContext, concertProvider, !widget.clickable);
            },
            onLongPress: () {
              if (tapDown == null) {
                return;
              }
              HapticFeedback.mediumImpact();
              _showBubbleContextMenu(context, tapDown!, andropContext,
                  concertProvider, !widget.clickable);
            },
            child: ScaleTransition(
                scale: _animation,
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: widget.child))),
      ),
    );
  }

  void _showBubbleContextMenu(
      BuildContext context,
      Offset clickPosition,
      AndropContext andropContext,
      ConcertProvider concertProvider,
      bool onlyDelete) {
    final List<BubbleContextMenuItemType> items;
    if (onlyDelete) {
      items = [
        BubbleContextMenuItemType.MultiSelect,
        BubbleContextMenuItemType.Delete
      ];
    } else {
      items = [
        BubbleContextMenuItemType.Location,
        BubbleContextMenuItemType.MultiSelect,
        BubbleContextMenuItemType.Delete,
      ];
    }
    showBubbleContextMenu(
        context,
        contextMenuTag,
        clickPosition,
        andropContext.deviceId,
        concertProvider.concertMainKey,
        widget.bubble,
        items, {
      BubbleContextMenuItemType.Location: () {
        _openDir();
      },
      BubbleContextMenuItemType.MultiSelect: () {
        concertProvider.enterEditing();
      },
      BubbleContextMenuItemType.Delete: () {
        showCupertinoModalPopup(
            context: context,
            builder: (context) => DeleteMessageBottomSheet(onConfirm: () {
                  concertProvider.deleteBubble(widget.bubble);
                }));
      },
    });
  }

  Future<bool> _openFile(String filePath) async {
    if (Platform.isAndroid && filePath.endsWith(".apk") ||
        filePath.endsWith(".apk.1")) {
      return await _installApk(filePath);
    } else {
      final result = await OpenFilex.open(filePath);
      if (result.type == ResultType.done) {
        return true;
      } else {
        talker.error('Failed open file: ${widget.filePath}, result: $result');
        return false;
      }
    }
  }

  void _openDir() {
    // fixme 打开android目录
    if (Platform.isIOS || Platform.isAndroid) {
      _openDownloadDir();
    } else {
      final encodePath = File(widget.filePath).parent.path.replaceAll('/', '\\');
      if (Platform.isWindows) {
        // 使用 Explorer 打开目录
        Process.run('explorer', [encodePath]).catchError((error) => print('Failed to open download folder: $error'));
        return;
      }
      OpenDir()
          .openNativeDir(
              path: Platform.isWindows
                  ? encodePath
                  : widget.filePath)
          .catchError(
              (error) => print('Failed to open download folder: $error'));
    }
  }

  void _openDownloadDir() {
    openDownloadFolder().then((value) {
      if (value) {
        print('Download folder opened successfully');
      } else {
        print('Failed to open download folder');
      }
    }).catchError(
        (error, stackTrace) => print('Failed to open download folder: $error'));
  }

  Future<bool> _installApk(String apkPath) async {
    try {
      // 请求安装权限
      final result = await FlutterAppInstaller().installApk(filePath: apkPath);
      if (!result) {
        talker.error('install apk failed');
      }
      return result;
    } catch (e, stackTrace) {
      talker.error('install apk failed: ', e, stackTrace);
      return false;
    }
  }
}
