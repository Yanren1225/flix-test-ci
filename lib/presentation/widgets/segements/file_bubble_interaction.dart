import 'dart:io';

import 'package:downloadsfolder/downloadsfolder.dart';
import 'package:flix/domain/androp_context.dart';
import 'package:flix/domain/concert/concert_provider.dart';
import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/model/ui_bubble/shared_file.dart';
import 'package:flix/model/ui_bubble/ui_bubble.dart';
import 'package:flix/presentation/basic/corner/flix_clip_r_rect.dart';
import 'package:flix/presentation/basic/flix_thumbnail_provider.dart';
import 'package:flix/presentation/widgets/bubble_context_menu/delete_message_bottom_sheet.dart';
import 'package:flix/presentation/widgets/segements/bubble_context_menu.dart';
import 'package:flix/utils/android/android_utils.dart';
import 'package:flix/utils/drawin_file_security_extension.dart';
import 'package:flix/utils/file/file_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_installer/flutter_app_installer.dart';
import 'package:modals/modals.dart';
import 'package:open_dir/open_dir.dart';
import 'package:open_filex/open_filex.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class BubbleInteraction extends StatefulWidget {
  final UIBubble bubble;
  String path;
  final Widget child;
  final bool clickable;

  BubbleInteraction(
      {super.key,
      required this.bubble,
      required this.path,
      required this.child,
      required this.clickable});

  @override
  State<StatefulWidget> createState() => BubbleInteractionState();
}

class BubbleInteractionState extends State<BubbleInteraction>
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

    final sharedRes = widget.bubble.shareable;

    return ModalAnchor(
      tag: contextMenuTag,
      child: FlixClipRRect(
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
              if (SharedFile is SharedFile) {
                _openFile(sharedRes.content.resourceId, widget.path)
                    .then((isSuccess) {
                  if (!isSuccess) {
                    _openFileDir();
                  }
                });
              } else {
                _openDirectoryDir();
              }
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
                child: FlixClipRRect(
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
        _openFileDir();
      },
      BubbleContextMenuItemType.MultiSelect: () {
        concertProvider.enterEditing();
      },
      BubbleContextMenuItemType.Delete: () {
        showCupertinoModalPopup(
            context: context,
            builder: (context) => DeleteMessageBottomSheet(onConfirm: () async {
                  concertProvider.deleteBubble(widget.bubble);
                }));
      },
    });
  }

  Future<bool> _openFile(String resourceId, String filePath) async {
    if (Platform.isAndroid && filePath.endsWith(".apk") ||
        filePath.endsWith(".apk.1")) {
      return await _installApk(filePath);
    } else if (Platform.isIOS) {
      if (filePath.isEmpty && resourceId.isNotEmpty) {
        final AssetEntity? asset = await AssetEntity.fromId(resourceId);
        if (asset != null) {
          final file = await asset.originFile;
          filePath =  file?.path ?? '';
          setState(() {
            widget.path = filePath;
          });
        }
      }
    }

    final result = await OpenFilex.open(filePath);
    if (result.type == ResultType.done) {
      return true;
    } else {
      talker.error('Failed open file: ${widget.path}, result: $result');
      return false;
    }
  }

  void _openFileDir() {
    // fixme 打开android目录
    if (!(widget.bubble.shareable is SharedFile)) return;
    final sharedFile = widget.bubble.shareable as SharedFile;
    if (Platform.isIOS && sharedFile.content.resourceId.isNotEmpty) {
      _openIOSAlbum(sharedFile.content.resourceId).then((value) {
        if (!value) {
          talker.error("failed to open ios album");
        }
      }).catchError((e) {
        talker.error("failed to open ios album: $e");
      });
    } else if (Platform.isAndroid && sharedFile.content.resourceId.isNotEmpty) {
      AndroidUtils.launchGallery();
    } else if (Platform.isIOS || Platform.isAndroid) {
      _openDownloadDir();
    } else {
      if (Platform.isWindows) {
        openFileDirectoryOnWindows(widget.path);
      } else {
        OpenDir()
            .openNativeDir(
            path: widget.path)
            .catchError(
                (error) => print('Failed to open download folder: $error'));
      }

    }
  }

  Future<void> _openDirectoryDir() async {
    if (widget.bubble.shareable is SharedDirectory) {
      final p = joinPaths((await getDownloadDirectory()).path,
          (widget.bubble.shareable as SharedDirectory).meta.name ?? '');
      try {
        final Uri uri = Uri.file(p);
        if (!Directory(uri.toFilePath(windows: Platform.isWindows)).existsSync()) {
          throw Exception('$uri does not exist!');
        }
        if (!await launchUrl(uri)) {
          throw Exception('Could not launch $uri');
        }
      } catch (e) {
        talker.debug("open err =$e, path=$p");
      }
    }

    if (Platform.isIOS || Platform.isAndroid) {
      _openDownloadDir();
    } else {
      if (Platform.isWindows) {
        openFileDirectoryOnWindows(widget.path);
      } else {
        OpenDir()
            .openNativeDir(
            path: widget.path)
            .catchError(
                (error) => print('Failed to open download folder: $error'));
      }
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

  Future<bool> _openIOSAlbum(String resourceId) async {
    String _url = "photos-redirect://$resourceId";
    return await launchUrl(Uri.parse(_url));
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
