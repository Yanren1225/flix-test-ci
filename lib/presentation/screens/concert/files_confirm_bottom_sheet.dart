import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flix/domain/device/device_profile_repo.dart';
import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/domain/ship_server/ship_service_proxy.dart';
import 'package:flix/model/device_info.dart';
import 'package:flix/model/ship/primitive_bubble.dart';
import 'package:flix/model/ui_bubble/shared_file.dart';
import 'package:flix/model/ui_bubble/ui_bubble.dart';
import 'package:flix/presentation/basic/corner/flix_decoration.dart';
import 'package:flix/presentation/widgets/flix_bottom_sheet.dart';
import 'package:flix/utils/file/file_helper.dart';
import 'package:flix/utils/file/size_utils.dart';
import 'package:flix/utils/text/text_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path_utils;

import '../../../l10n/l10n.dart';

// TODO： 兼容ContentProvider
class FilesConfirmBottomSheet extends StatefulWidget {
  static const tag = "FilesConfirmBottomSheet";
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
        title: S.of(context).dialog_confirm_send_title,
        subTitle: S.of(context).dialog_confirm_send_subtitle(deviceInfo.name),
        buttonText: S.of(context).dialog_confirm_send_button,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(
                      decelerationRate: ScrollDecelerationRate.fast)),
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: files.length,
              itemBuilder: (context, index) {
                final file = files[index];
                return ReadSendFileItem(file: file);
              }),
        ),
        onClickFuture: () async {
          _sendFiles(files);
        });
  }

  Future<void> _sendFiles(List<XFile> files) async {
    for (var file in files) {
      final fileType = await getFileType(file.path);

      final meta = await file.toFileMeta(
          isImg: fileType == FileType.image,
          isVideo: fileType == FileType.video);

      var bubbleFileType = BubbleType.File;
      switch (fileType) {
        case FileType.image:
          bubbleFileType = BubbleType.Image;
          break;
        case FileType.video:
          bubbleFileType = BubbleType.Video;
          break;
        case FileType.directory:
          bubbleFileType = BubbleType.Directory;
          break;
        case FileType.other:
          bubbleFileType = BubbleType.File;
          break;
      }
      talker.debug(
          FilesConfirmBottomSheet.tag, "_sendFiles type = $bubbleFileType");
      if (bubbleFileType == BubbleType.Directory) {
        final directoryId = const Uuid().v4();
        final directoryMeta = DirectoryMeta(
            name: path_utils.basenameWithoutExtension(file.path),
            size: meta.size,
            path: file.path);

        List<SharedFile> fileList = [];
        await for (final entity in Directory(file.path).list(recursive: true)) {
          if (entity is File) {
            FileMeta fileMeta = await entity.toFileMeta(parent: directoryMeta);
            fileList.add(SharedFile(
                id: fileMeta.name, content: fileMeta, groupId: directoryId));
          }
        }

        talker.debug(FilesConfirmBottomSheet.tag,
            "_sendFiles directoryMeta = $directoryMeta");
        shipService.send(UIBubble(
            time: DateTime.now().millisecondsSinceEpoch,
            from: DeviceProfileRepo.instance.did,
            to: deviceInfo.id,
            type: bubbleFileType,
            shareable: SharedDirectory(
                id: directoryId,
                state: FileState.picked,
                meta: directoryMeta,
                content: fileList)));
      } else {
        shipService.send(UIBubble(
            time: DateTime.now().millisecondsSinceEpoch,
            from: DeviceProfileRepo.instance.did,
            to: deviceInfo.id,
            type: bubbleFileType,
            shareable: SharedFile(
                id: const Uuid().v4(),
                state: FileState.picked,
                content: meta)));
      }
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
  var isDir = false;

  @override
  void initState() {
    super.initState();
    File _file = File(widget.file.path);
    File(widget.file.path).isFile().then((value) async {
      if (value) {
        fileSize = await _file.length();
        isDir = false;
      } else {
        fileSize = await Directory(widget.file.path).getSize();
        isDir = true;
      }
      setState(() {});
    });
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
            decoration: FlixDecoration(borderRadius: BorderRadius.circular(6)),
            alignment: Alignment.center,
            child: SvgPicture.asset(mimeIcon(isDir ? "/" : widget.file.path)),
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.file.name,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                          decoration: TextDecoration.none)
                      .fix(),
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
                      .fix(),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
