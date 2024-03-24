import 'dart:ffi';

import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flix/domain/device/device_manager.dart';
import 'package:flix/domain/ship_server/ship_service.dart';
import 'package:flix/model/device_info.dart';
import 'package:flix/model/ship/primitive_bubble.dart';
import 'package:flix/model/ui_bubble/shared_file.dart';
import 'package:flix/model/ui_bubble/ui_bubble.dart';
import 'package:flix/utils/file/file_helper.dart';
import 'package:flix/utils/file/size_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class Droper extends StatefulWidget {
  const Droper({super.key, required this.deviceInfo, required this.child, this.onDropEntered = null, this.onDropExited = null});

  final DeviceInfo deviceInfo;
  final Widget child;
  final VoidCallback? onDropEntered;
  final VoidCallback? onDropExited;

  @override
  State<StatefulWidget> createState() {
    return DroperState();
  }
}

class DroperState extends State<Droper> {
  DeviceInfo get deviceInfo => widget.deviceInfo;

  Widget get child => widget.child;


  @override
  Widget build(BuildContext context) {
    // final concertProvider =
    //     Provider.of<ConcertProvider>(context, listen: false);
    return DropTarget(
      onDragEntered: (details) {
        widget.onDropEntered?.call();
        print('onDragEnter');
      },
      onDragUpdated: (details) {
        print('onDragUpdate');
      },
      onDragExited: (details) {
        widget.onDropExited?.call();
        print('onDragExit');
      },
      onDragDone: (details) async {
        print('onDragDone');
        showCupertinoModalPopup(
            context: context,
            builder: (context) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(

                    width: 40,
                    height: 40,
                    child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child:
                            SvgPicture.asset('assets/images/ic_handler.svg')),
                  ),
                  Material(
                    type: MaterialType.transparency,
                    child: Flexible(
                      child: Container(
                        margin: const EdgeInsets.only(left: 16, right: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color.fromRGBO(232, 243, 255, 1),
                              Color.fromRGBO(255, 255, 255, 1),
                              Color.fromRGBO(255, 255, 255, 1),
                            ],
                            stops: [0, 0.2043, 1],
                          ),
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: 400,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 20, top: 28, right: 20),
                                child: Text(
                                  '发送文件',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ).useSystemChineseFont(),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 20, right: 20),
                                child: Text(
                                  '到${deviceInfo.name}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: 0,
                                    color: Color.fromRGBO(60, 60, 67, 0.6),
                                  ).useSystemChineseFont(),
                                ),
                              ),
                              Flexible(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 24),
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      minHeight: 62,
                                      maxHeight: 400,
                                    ),
                                    child: ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: details.files.length,
                                        itemBuilder: (_context, index) {
                                          final file = details.files[index];
                                          return ReadSendFileItem(file: file);
                                        }),
                                  ),
                                ),
                              ),
                              Padding(
                                  padding: const EdgeInsets.only(
                                      left: 28, right: 28, bottom: 28),
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: CupertinoButton(
                                      onPressed: () {
                                        _sendFiles(details);
                                        Navigator.of(context).pop();
                                      },
                                      color: const Color.fromRGBO(0, 122, 255, 1),
                                      borderRadius: BorderRadius.circular(14),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 24, vertical: 16),
                                      child: Text(
                                        '发送',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 0,
                                          color: Colors.white,
                                        ).useSystemChineseFont(),
                                      ),
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              );
            });
      },
      child: child,
    );
  }

  Future<void> _sendFiles(DropDoneDetails details) async {
    final files = details.files;
    for (var file in files) {
      final meta = await file.toFileMeta();
      ShipService.instance.send(UIBubble(
          from: DeviceManager.instance.did,
          to: deviceInfo.id,
          type: BubbleType.File,
          shareable: SharedFile(
              id: const Uuid().v4(), state: FileState.picked, content: meta)));
    }
  }
}

class ReadSendFileItem extends StatefulWidget {
  const ReadSendFileItem({
    super.key,
    required this.file,
  });

  final XFile file;

  @override
  State<StatefulWidget> createState() {
    return ReadSendFileItemState();
  }
}

class ReadSendFileItemState extends State<ReadSendFileItem> {
  var fileSize = 0;

  @override
  void initState() {
    super.initState();
    widget.file.length().then((value) => setState(() {
          fileSize = value;
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6)),
            alignment: Alignment.center,
            child: SvgPicture.asset(
              mimeIcon(widget.file.path)),
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.file?.name ?? '',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ).useSystemChineseFont(),
                ),
                const SizedBox(
                  height: 2,
                ),
                Text(
                  fileSize.formateBinarySize(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0,
                    color: Color.fromRGBO(60, 60, 67, 0.6),
                  ).useSystemChineseFont(),
                ),

              ],
            ),
          )
        ],
      ),
    );
  }
}
