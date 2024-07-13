import 'package:desktop_drop/desktop_drop.dart';
import 'package:flix/model/device_info.dart';
import 'package:flix/presentation/screens/concert/files_confirm_bottom_sheet.dart';
import 'package:flutter/cupertino.dart';

class Droper extends StatefulWidget {
  const Droper(
      {super.key,
      required this.deviceInfo,
      required this.child,
      this.onDropEntered,
      this.onDropExited});

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
              return FilesConfirmBottomSheet(deviceInfo: deviceInfo, files: details.files);
        });
      },
      child: child,
    );
  }

}
