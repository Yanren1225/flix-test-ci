import 'package:desktop_drop/desktop_drop.dart';
import 'package:flix/domain/concert/concert_provider.dart';
import 'package:flix/domain/device/device_manager.dart';
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
  const Droper({super.key, required this.deviceInfo, required this.child});

  final DeviceInfo deviceInfo;
  final Widget child;

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
    final concertProvider =
        Provider.of<ConcertProvider>(context, listen: false);
    return DropTarget(
      onDragEntered: (details) {
        print('onDragEnter');
      },
      onDragUpdated: (details) {
        print('onDragUpdate');
      },
      onDragExited: (details) {
        print('onDragExit');
      },
      onDragDone: (details) async {
        print('onDragDone');
        final fileSize = await details.files.firstOrNull?.length() ?? 0;
        showCupertinoModalPopup(
            context: context,
            builder: (context) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [SizedBox(
                  width: 40,
                  height: 40,
                  child: CupertinoButton(padding: EdgeInsets.zero, onPressed: () {
                    Navigator.of(context).pop();
                  }, child: SvgPicture.asset('assets/images/ic_handler.svg')),
                ),
                  Container(
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
                          padding:
                              const EdgeInsets.only(left: 20, top: 28, right: 20),
                          child: Text(
                            '发送文件',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
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
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 34),
                          child: Align(
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6),
                                      color:
                                          const Color.fromRGBO(0, 122, 255, 1)),
                                  alignment: Alignment.center,
                                  child: SvgPicture.asset(
                                      'assets/images/ic_file1.svg'),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  details.files?.firstOrNull?.name ?? '',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(
                                  height: 6,
                                ),
                                Text(
                                  fileSize.formateBinarySize(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: 0,
                                    color: Color.fromRGBO(60, 60, 67, 0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                            padding: const EdgeInsets.only(
                                left: 28, right: 28, bottom: 28),
                            child: SizedBox(
                              width: double.infinity,
                              child: CupertinoButton(
                                child: const Text(
                                  '发送',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0,
                                    color: Colors.white,
                                  ),
                                ),
                                onPressed: () {
                                  _sendFiles(concertProvider, details);
                                  Navigator.of(context).pop();
                                },
                                color: const Color.fromRGBO(0, 122, 255, 1),
                                borderRadius: BorderRadius.circular(14),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 16),
                              ),
                            )),
                      ],
                    ),
                  ),
                )],
              );
            });
      },
      child: child,
    );
  }

  Future<void> _sendFiles(
      ConcertProvider concertProvider, DropDoneDetails details) async {
    final files = details.files;
    for (var file in files) {
      final meta = await file.toFileMeta();
      concertProvider.send(UIBubble(
          from: DeviceManager.instance.did,
          to: deviceInfo.id,
          type: BubbleType.File,
          shareable: SharedFile(
              id: const Uuid().v4(), state: FileState.picked, content: meta)));
    }
  }
}
