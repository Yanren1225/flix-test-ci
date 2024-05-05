import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flix/domain/device/device_profile_repo.dart';
import 'package:flix/domain/ship_server/ship_service_proxy.dart';
import 'package:flix/model/device_info.dart';
import 'package:flix/model/ship/primitive_bubble.dart';
import 'package:flix/model/ui_bubble/shared_file.dart';
import 'package:flix/model/ui_bubble/ui_bubble.dart';
import 'package:flix/presentation/widgets/flix_bottom_sheet.dart';
import 'package:flix/utils/file/file_helper.dart';
import 'package:flix/utils/file/size_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:uuid/uuid.dart';

// TODO： 兼容ContentProvider
class FilesConfirmBottomSheet extends StatefulWidget {
  final DeviceInfo deviceInfo;
  final List<XFile> files;

  const FilesConfirmBottomSheet(
      {super.key, required this.deviceInfo, required this.files});

  @override
  State<StatefulWidget> createState() {
    return FilesConfirmBottomSheetState();
  }
}

// TODO: 支持 content://
class FilesConfirmBottomSheetState extends State<FilesConfirmBottomSheet> {
  DeviceInfo get deviceInfo => widget.deviceInfo;

  List<XFile> get files => widget.files;

  @override
  Widget build(BuildContext context) {
    return FlixBottomSheet(
        title: '发送文件',
        subTitle: '到${deviceInfo.name}',
        buttonText: '发送',
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(
                      decelerationRate: ScrollDecelerationRate.fast)),
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: files.length,
              itemBuilder: (_context, index) {
                final file = files[index];
                return ReadSendFileItem(file: file);
              }),
        ),
        onClick: () {
          _sendFiles(files);
        });
  }

  Future<void> _sendFiles(List<XFile> files) async {
    for (var file in files) {
      final fileType = getFileType(file.path);
      // final fileType = FileType.other;
      final meta = await file.toFileMeta(
          isImg: fileType == FileType.image,
          isVideo: fileType == FileType.video);
      final bubbleType = fileType == FileType.image
          ? BubbleType.Image
          : fileType == FileType.video
              ? BubbleType.Video
              : BubbleType.File;
      shipService.send(UIBubble(
          time: DateTime.now().millisecondsSinceEpoch,
          from: DeviceProfileRepo.instance.did,
          to: deviceInfo.id,
          type: bubbleType,
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
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(6)),
            alignment: Alignment.center,
            child: SvgPicture.asset(mimeIcon(widget.file.path)),
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
                          decoration: TextDecoration.none)
                      .useSystemChineseFont(),
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
                          decoration: TextDecoration.none)
                      .useSystemChineseFont(),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
