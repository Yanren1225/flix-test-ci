import 'dart:developer';
import 'dart:math' hide log;

import 'package:androp/model/pickable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';

class PickActionsArea extends StatefulWidget {
  final OnFilesPicked onFilesPicked;

  PickActionsArea({super.key, required this.onFilesPicked});

  @override
  State<StatefulWidget> createState() => PickActionAreaState();
}

class PickActionAreaState extends State<PickActionsArea> {
  OnFilesPicked get onFilesPicked => widget.onFilesPicked;

  dynamic _pickFileError;
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
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
          SizedBox(
            width: 36,
            height: 36,
            child: IconButton(
              padding: const EdgeInsets.all(0),
              iconSize: 20,
              onPressed: () {},
              icon: SvgPicture.asset('assets/images/ic_app.svg'),
            ),
          ),
          SizedBox(
            width: 36,
            height: 36,
            child: IconButton(
              padding: const EdgeInsets.all(0),
              iconSize: 20,
              onPressed: () {},
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
        onFilesPicked(pickedFileList
            .map((f) => Pickable(type: PickedFileType.Image, file: f))
            .toList());
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
          onFilesPicked(
              [Pickable(type: PickedFileType.Video, file: pickedFile)]);
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
}

typedef OnFilesPicked = void Function(List<Pickable> pickables);
