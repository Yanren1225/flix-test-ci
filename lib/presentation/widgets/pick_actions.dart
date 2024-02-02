import 'dart:developer';
import 'dart:io';
import 'dart:math' hide log;

import 'package:androp/model/pickable.dart';
import 'package:androp/presentation/screens/android_apps_screen.dart';
import 'package:androp/utils/file/file_helper.dart';
import 'package:device_apps/device_apps.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';

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
        width: 36,
        height: 36,
        child: IconButton(
          padding: const EdgeInsets.all(0),
          iconSize: 20,
          onPressed: () {
            _onAppButtonPressed();
          },
          icon: SvgPicture.asset('assets/images/ic_app.svg'),
        ),
      );
    } else {
      pickAppButton = const SizedBox();
    }
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 2, right: 8, bottom: 2),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            height: 36,
            child: IconButton(
                padding: const EdgeInsets.all(0),
                iconSize: 20,
                onPressed: () {
                  _onImageButtonPressed(context: context);
                },
                icon: SvgPicture.asset('assets/images/ic_image.svg')),
          ),
          SizedBox(
            width: 36,
            height: 36,
            child: IconButton(
                padding: const EdgeInsets.all(0),
                iconSize: 20,
                onPressed: () {
                  _onVideoButtonPressed(context: context);
                },
                icon: SvgPicture.asset('assets/images/ic_video.svg')),
          ),
          pickAppButton,
          SizedBox(
            width: 36,
            height: 36,
            child: IconButton(
              padding: const EdgeInsets.all(0),
              iconSize: 20,
              onPressed: () {
                _onFileButtonPressed();
              },
              icon: SvgPicture.asset('assets/images/ic_file.svg'),
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
      try {
        final List<XFile> pickedFileList =
            await _picker.pickMultiImage(requestFullMetadata: true);
        onPicked([
          for (final f in pickedFileList)
            PickableFile(
                type: PickedFileType.Image, content: await f.toFileMeta())
        ]);
      } catch (e) {
        log("pick images failed", error: e);
        setState(() {
          _pickFileError = e;
        });
      }
    }
  }

  Future<void> _onVideoButtonPressed({
    required BuildContext context,
  }) async {
    if (context.mounted) {
      try {
        final XFile? pickedFile =
            await _picker.pickVideo(source: ImageSource.gallery);
        if (pickedFile != null) {
          onPicked([
            PickableFile(
                type: PickedFileType.Video,
                content: await pickedFile.toFileMeta())
          ]);
        } else {
          log("pick video failed, return null");
        }
      } catch (e) {
        log("pick video failed", error: e);
        setState(() {
          _pickFileError = e;
        });
      }
    }
  }

  Future<void> _onAppButtonPressed() async {
    List<Application>? apps = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => const AppsScreen()));
    if (apps != null) {
      onPicked(apps.map((app) => PickableApp(content: app)).toList());
    }
  }

  Future<void> _onFileButtonPressed() async {
    // TODO 在Android平台上特化实现, 因为file_selector没有很好的支持ContentProvider,
    // 目前的实现是读取文件的所有内容加载到内存中，对于大文件来说会导致OOM，
    // see: https://github.com/flutter/flutter/issues/141002
    // 且通过XFile在Android平台拿不到真实的文件名称
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

typedef OnPicked = void Function(List<Pickable> pickables);
