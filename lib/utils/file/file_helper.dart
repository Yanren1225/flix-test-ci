import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:anydrop/model/ui_bubble/shared_file.dart';
import 'package:anydrop/utils/drawin_file_security_extension.dart';
import 'package:device_apps/device_apps.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:image_size_getter/file_input.dart';
import 'package:image_size_getter/image_size_getter.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_storage/shared_storage.dart' as shared_storage;
import 'package:path_provider/path_provider.dart' as path;
import 'package:video_player/video_player.dart';


Future<String> getDefaultDestinationDirectory() async {
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      // ignore: deprecated_member_use
      final dir = await shared_storage.getExternalStoragePublicDirectory(
          shared_storage.EnvironmentDirectory.downloads);
      return dir?.path ?? '/storage/emulated/0/Download';
    case TargetPlatform.iOS:
      return (await path.getApplicationDocumentsDirectory()).path;
    case TargetPlatform.linux:
    case TargetPlatform.macOS:
    case TargetPlatform.windows:
    case TargetPlatform.fuchsia:
      var downloadDir = await path.getDownloadsDirectory();
      if (downloadDir == null) {
        if (defaultTargetPlatform == TargetPlatform.windows) {
          downloadDir =
              Directory('${Platform.environment['HOMEPATH']}/Downloads');
          if (!downloadDir.existsSync()) {
            downloadDir = Directory(Platform.environment['HOMEPATH']!);
          }
        } else {
          downloadDir = Directory('${Platform.environment['HOME']}/Downloads');
          if (!downloadDir.existsSync()) {
            downloadDir = Directory(Platform.environment['HOME']!);
          }
        }
      }
      return downloadDir.path.replaceAll('\\', '/');
  }
}

extension XFileConvert on XFile {
  Future<FileMeta> toFileMeta(
      {bool isImg = false, bool isVideo = false}) async {
    await authPersistentAccess(this.path);
    var size = const Size(0, 0);
    if (isImg) {
      size = ImageSizeGetter.getSize(FileInput(File(this.path)));
    } else if (isVideo) {
      VideoPlayerController _controller = VideoPlayerController.file(File(this.path));
      await _controller.initialize();
      size = Size(_controller.value?.size?.width?.toInt() ?? 0, _controller.value?.size?.height?.toInt() ?? 0);
      _controller.dispose();
    }

    return FileMeta(
        name: this.name,
        path: this.path,
        mimeType: this.mimeType ?? 'application/octet-stream',
        nameWithSuffix: this.name,
        size: await length(),
        width: size.width,
        height: size.height);
  }
}

extension PlatformFileConvert on PlatformFile {
  Future<FileMeta> toFileMeta() async {
    if (this.path == null) {
      throw UnsupportedError('PlatformFile.path must not be null');
    }
    return FileMeta(
        name: this.name,
        path: this.path,
        mimeType: lookupMimeType(this.name) ?? 'application/octet-stream',
        nameWithSuffix: this.name,
        size: this.size);
  }
}

extension ApplicationConvert on Application {
  Future<FileMeta> toFileMeta() async {
    if (this.apkFilePath == null) {
      throw UnsupportedError('PlatformFile.path must not be null');
    }
    return FileMeta(
        name: '$packageName.apk',
        path: apkFilePath,
        mimeType: 'application/vnd.android.package-archive',
        nameWithSuffix: '$packageName.apk',
        size: File(apkFilePath).lengthSync());
  }
}

Future deleteAppFiles() async {
  // ...
  // _deleteFilesInDir(await getApplicationSupportDirectory());

  // 删除数据库文件
  // TODO getApplicationDocumentsDirectory返回的是用户的documents目录
  _deleteFilesInDir(await getApplicationDocumentsDirectory());

  // // 删除临时文件
  // _deleteFilesInDir(await getTemporaryDirectory());
  //
  // // 删除缓存文件
  // _deleteFilesInDir(await getApplicationCacheDirectory());
}

Future<void> _deleteFilesInDir(Directory dir) async {
  dir.listSync(recursive: true)
      .forEach((entity) {
    if (entity is File) {
      try {
        entity.deleteSync();
      } catch (e) {
        log('delete ${entity.path} failed: $e');
      }
    }
  });
}
