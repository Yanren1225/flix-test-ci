import 'dart:developer';
import 'dart:io';

import 'package:downloadsfolder/downloadsfolder.dart';
import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/utils/file/file_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:open_dir/open_dir.dart';
import 'package:open_filex/open_filex.dart';

class FileBubbleInteraction extends StatefulWidget {
  final String filePath;
  final Widget child;
  final bool clickable;

  const FileBubbleInteraction(
      {super.key,
      required this.filePath,
      required this.child,
      required this.clickable});

  @override
  State<StatefulWidget> createState() => FileBubbleIneractionState();
}

class FileBubbleIneractionState extends State<FileBubbleInteraction>
    with TickerProviderStateMixin {
  var tapDownTime = 0;
  @override
  Widget build(BuildContext context) {
    final _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 100),
    );

    final _animation = Tween<double>(begin: 1, end: 0.96).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut))
      ..addListener(() {
        // setState(() {});
      });

    return InkWell(
        radius: 10,
        borderRadius: BorderRadius.circular(10),
        onTapDown: (details) {
          if (!widget.clickable) return;
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
        onDoubleTap: () {
          if (!widget.clickable) return;
          _openDir();
        },
        onTap: () {
          if (!widget.clickable) return;
          // _controller.forward().whenComplete(() => _controller.reverse());
          talker.verbose('filePath: ${widget.filePath}');
          OpenFilex.open(widget.filePath).then((value) {
            if (value.type != ResultType.done) {
              talker.error(
                  'Failed open file: ${widget.filePath}, result: $value');
              _openDir();
            }
          });
        },
        child: ScaleTransition(scale: _animation, child: widget.child));
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
          .then((value) => OpenDir().openNativeDir(path: widget.filePath))
          .catchError(
              (error) => print('Failed to open download folder: $error'));
    }
  }
}
