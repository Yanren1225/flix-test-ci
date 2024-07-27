import 'dart:async';
import 'dart:ui' as ui show Image;

import 'package:device_apps/device_apps.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

@immutable
class AppIcon extends ImageProvider<String> {
  final Application app;

  const AppIcon({required this.app});

  @override
  Future<String> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture("app_icon://${app.packageName}");

  @override
  ImageStreamCompleter loadImage(String key, ImageDecoderCallback decode) {
    return OneFrameImageStreamCompleter((() async {
      var appWithIcon =
          (await DeviceApps.getApp(app.packageName, true)) as ApplicationWithIcon;
      return ImageInfo(image: await _loadImageFromBytes(appWithIcon.icon));
    })());
  }

  Future<ui.Image> _loadImageFromBytes(Uint8List bytes) async {
    return await decodeImageFromList(bytes);
  }
}
