import 'dart:io';
import 'dart:math';

import 'package:device_apps/device_apps.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/model/pickable.dart';
import 'package:flix/model/ui_bubble/shared_file.dart';
import 'package:flix/presentation/screens/android_apps_screen.dart';
import 'package:flix/presentation/screens/base_screen.dart';
import 'package:flix/presentation/widgets/actions/progress_action.dart';
import 'package:flix/utils/file/file_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:path/path.dart' as path_utils;

import '../../model/ui_bubble/shared_file.dart';

// 同时发送的数量100左右，但是没有错误信息，失败表现为接收到的文件大小未0
const MAX_ASSETS = 60;

class PickActionsArea extends StatefulWidget {
  final OnPicked onPicked;

  PickActionsArea({super.key, required this.onPicked});

  @override
  State<StatefulWidget> createState() => PickActionAreaState();
}

class PickActionAreaState extends State<PickActionsArea> {
  OnPicked get onPicked => widget.onPicked;

  dynamic _pickFileError;
  final ImagePicker _picker = ImagePicker();
  bool _isImageLoading = false;
  bool _isVideoLoading = false;
  bool _isFileLoading = false;
  bool _isDirectoryLoading = false;

  @override
  Widget build(BuildContext context) {
    late final Widget pickAppButton;
    if (Platform.isAndroid) {
      pickAppButton = SizedBox(
        width: 50,
        height: 50,
        child: IconButton(
          padding: const EdgeInsets.all(0),
          iconSize: 22,
          onPressed: () {
            _onAppButtonPressed();
          },
          icon: SvgPicture.asset('assets/images/ic_app.svg',
              width: 22, height: 22),
        ),
      );
    } else {
      pickAppButton = const SizedBox();
    }
    return Padding(
      padding: const EdgeInsets.only(left: 6, top: 6, right: 6, bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ProgressAction(
              showProgress: _isImageLoading,
              icon: 'assets/images/ic_image.svg',
              onTap: () => _onImageButtonPressed(context: context)),
          ProgressAction(
              showProgress: _isVideoLoading,
              icon: 'assets/images/ic_video.svg',
              onTap: () => _onVideoButtonPressed(context: context)),
          pickAppButton,
          ProgressAction(
            showProgress: _isFileLoading,
            icon: 'assets/images/ic_file.svg',
            onTap: _onFileButtonPressed,
          ),
          ProgressAction(
            showProgress: _isDirectoryLoading,
            icon: 'assets/images/ic_dir_pick.svg',
            onTap: _onDirectoryButtonPressed,
          ),
        ],
      ),
    );
  }

  Future<void> _onImageButtonPressed({
    required BuildContext context,
  }) async {
    if (context.mounted) {
      if (await checkPhotosPermission(context)) {
        try {
          if (Platform.isAndroid || Platform.isIOS) {
            final List<AssetEntity>? result = await AssetPicker.pickAssets(
              context,
              pickerConfig: const AssetPickerConfig(
                  requestType: RequestType.image, maxAssets: MAX_ASSETS),
            );
            _isImageLoading = true;
            for (final f in (result ?? <AssetEntity>[])) {
              onPicked([PickableFile(
                  type: PickedFileType.Image, content: await f.toFileMeta())]);
            }

            _isImageLoading = false;
          } else {
            final List<XFile> pickedFileList =
                await _picker.pickMultiImage(requestFullMetadata: true, limit: MAX_ASSETS);
            onPicked([
              for (final f in pickedFileList)
                PickableFile(
                    type: PickedFileType.Image,
                    content: await f.toFileMeta(isImg: true))
            ]);
          }
        } catch (e, stack) {
          talker.error("pick images failed: $e, $stack", e, stack);
          setState(() {
            _pickFileError = e;
          });
        }
      }
    }
  }

  Future<void> _onVideoButtonPressed({
    required BuildContext context,
  }) async {
    if (context.mounted) {
      if (await checkVideosPermission(context)) {
        // showMaskLoading(context);
        try {
          if (Platform.isAndroid || Platform.isIOS) {
            final List<AssetEntity>? result = await AssetPicker.pickAssets(
              context,
              pickerConfig: AssetPickerConfig(
                  requestType: RequestType.video,
                  maxAssets: MAX_ASSETS,
                  filterOptions: FilterOptionGroup(containsLivePhotos: false)),
            );
            _isVideoLoading = true;
            for (final f in (result ?? <AssetEntity>[])) {
              onPicked([
                PickableFile(
                    type: PickedFileType.Video, content: await f.toFileMeta())
              ]);
            }
            _isVideoLoading = false;
          } else {
            final XFile? pickedFile =
                await _picker.pickVideo(source: ImageSource.gallery);
            talker.debug('video selected: ${pickedFile?.path}');
            if (pickedFile != null) {
              onPicked([
                PickableFile(
                    type: PickedFileType.Video,
                    content: await pickedFile.toFileMeta(isVideo: true))
              ]);
            } else {
              talker.error("pick video failed, return null");
            }
          }
        } catch (e) {
          talker.error("pick video failed: ", e);
          setState(() {
            _pickFileError = e;
          });
        } finally {
          // dismissMaskLoading();
        }
      }
    }
  }

  Future<void> _onAppButtonPressed() async {
    List<Application>? apps = await Navigator.push(
        context, CupertinoPageRoute(builder: (context) => const AppsScreen()));
    if (apps != null) {
      onPicked([
        for (final app in apps)
          PickableFile(
              type: PickedFileType.App, content: await app.toFileMeta())
      ]);
    }
  }

  Future<void> _onFileButtonPressed() async {
    try {
      if (mounted) {
        if (await checkStoragePermission(context,
            manageExternalStorage: false)) {
          // if (Platform.isAndroid) {
          final result = await FilePicker.platform.pickFiles(
              allowMultiple: true,
              onFileLoading: (FilePickerStatus pickerStatus) {
                if (mounted) {
                  switch (pickerStatus) {
                    case FilePickerStatus.picking:
                      setState(() {
                        _isFileLoading = true;
                      });
                      break;
                    case FilePickerStatus.done:
                      setState(() {
                        _isFileLoading = false;
                      });
                      break;
                  }
                }
              });
          if (result != null) {
            onPicked([
              for (final file in result.files)
                PickableFile(
                    type: PickedFileType.File, content: await file.toFileMeta())
            ]);
          }
        }
      }
    } catch (e, stackTrace) {
      talker.error('pick file failed', e, stackTrace);
    }
  }

  Future<void> _onDirectoryButtonPressed() async {
    try {
      if (mounted) {
        if (await checkStoragePermission(context,
            manageExternalStorage: false)) {
          // if (Platform.isAndroid) {
          setState(() {
            _isDirectoryLoading = true;
          });
          String? result = await FilePicker.platform.getDirectoryPath(lockParentWindow:true);
          setState(() {
            _isDirectoryLoading = false;
          });

          if (result != null) {
            var directory = Directory(result);
            final directoryMeta = DirectoryMeta(
                name: path_utils.basenameWithoutExtension(directory.path),
                size: directory.statSync().size,
                path: directory.path);
            List<FileSystemEntity> entities =
                directory.listSync(recursive: true);
            List<FileMeta> picks = [];
            int totalSize = 0;
            for (FileSystemEntity entity in entities) {
              if (entity is File) {
                final sf = await entity.toFileMeta(parent: directoryMeta);
                totalSize += entity.lengthSync();
                picks.add(sf);
              }
            }
            directoryMeta.size = totalSize;
            onPicked([
              PickableDirectory(
                  content: picks,
                  meta: directoryMeta)
            ]);
          }
        }
      }
    } catch (e, stackTrace) {
      talker.error('pick directory failed', e, stackTrace);
    }
  }
}

typedef OnPicked = void Function(List<Pickable> pickables);
