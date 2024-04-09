import 'dart:io';

import 'package:device_apps/device_apps.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/model/pickable.dart';
import 'package:flix/presentation/screens/android_apps_screen.dart';
import 'package:flix/presentation/screens/base_screen.dart';
import 'package:flix/utils/file/file_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

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
          SizedBox(
            width: 50,
            height: 50,
            child: IconButton(
                padding: const EdgeInsets.all(0),
                iconSize: 22,
                onPressed: () {
                  _onImageButtonPressed(context: context);
                },
                icon: SvgPicture.asset('assets/images/ic_image.svg',
                    width: 22, height: 22)),
          ),
          SizedBox(
            width: 50,
            height: 50,
            child: IconButton(
                padding: const EdgeInsets.all(0),
                iconSize: 22,
                onPressed: () {
                  _onVideoButtonPressed(context: context);
                },
                icon: SvgPicture.asset('assets/images/ic_video.svg',
                    width: 22, height: 22)),
          ),
          pickAppButton,
          SizedBox(
            width: 50,
            height: 50,
            child: IconButton(
              padding: const EdgeInsets.all(0),
              iconSize: 22,
              onPressed: () {
                _onFileButtonPressed();
              },
              icon: SvgPicture.asset(
                'assets/images/ic_file.svg',
                width: 22,
                height: 22,
              ),
            ),
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
                  requestType: RequestType.image, maxAssets: 100),
            );

            onPicked([
              for (final f in (result ?? <AssetEntity>[]))
                PickableFile(
                    type: PickedFileType.Image, content: await f.toFileMeta())
            ]);
          } else {
            final List<XFile> pickedFileList =
                await _picker.pickMultiImage(requestFullMetadata: true);
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
                  maxAssets: 100,
                  filterOptions: FilterOptionGroup(containsLivePhotos: false)),
            );

            onPicked([
              for (final f in (result ?? <AssetEntity>[]))
                PickableFile(
                    type: PickedFileType.Video, content: await f.toFileMeta())
            ]);
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
    // TODO 在Android平台上特化实现, 因为file_selector没有很好的支持ContentProvider,
    // 目前的实现是读取文件的所有内容加载到内存中，对于大文件来说会导致OOM，
    // see: https://github.com/flutter/flutter/issues/141002
    // 且通过XFile在Android平台拿不到真实的文件名称
    try {
      if (context.mounted) {
        if (await checkStoragePermission(context, manageExternalStorage: false)) {
          if (Platform.isAndroid) {
            final result = await FilePicker.platform.pickFiles(allowMultiple: true);
            if (result != null) {
              onPicked([
                for (final file in result.files)
                  PickableFile(
                      type: PickedFileType.File, content: await file.toFileMeta())
              ]);
            }
          } else {
            final typeGroup = const XTypeGroup(label: 'all');
            final files = await openFiles(acceptedTypeGroups: [typeGroup]);

            if (files.isNotEmpty) {
              onPicked([
                for (final file in files)
                  PickableFile(
                      type: PickedFileType.File, content: await file.toFileMeta())
              ]);
            }
          }
        }
      }


    } catch (e, stackTrace) {
      talker.error('pick file failed', e, stackTrace);
    }
  }

}

typedef OnPicked = void Function(List<Pickable> pickables);
