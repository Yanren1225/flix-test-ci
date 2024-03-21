import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/model/ui_bubble/shared_file.dart';
import 'package:flix/utils/drawin_file_security_extension.dart';
import 'package:device_apps/device_apps.dart';
import 'package:drift/drift.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:image_size_getter/file_input.dart';
import 'package:image_size_getter/image_size_getter.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_handler/share_handler.dart';
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
      size = await getImgSize(size, this.path);
    } else if (isVideo) {
      size = await getVideoSize(size, this.path);
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

extension AttachmentConvert on SharedAttachment {
  Future<FileMeta> toFileMeta() async {
    await authPersistentAccess(this.path);
    var size = const Size(0, 0);
    final file = File(this.path);
    if (this.type == SharedAttachmentType.image) {
      size = await getImgSize(size, this.path);
    } else if (this.type == SharedAttachmentType.video) {
      size = await getVideoSize(size, this.path);
    }

    final fileName = _getFileNameFromPath(this.path);

    return FileMeta(
        name: _getFileNameFromPath(this.path),
        path: this.path,
        mimeType: lookupMimeType(this.path) ?? 'application/octet-stream',
        nameWithSuffix: fileName,
        size: await file.length(),
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
        talker.error('delete ${entity.path} failed: $e', e);
      }
    }
  });
}

String _getFileNameFromPath(String path) {
  return path.substring(path.lastIndexOf('/') + 1);
}

Future<Size> getImgSize(Size size, String path) async {
  // TODO: 其他平台也优先使用getHeifImageSize2
  if (Platform.isIOS) {
    final _size = await getHeifImageSize2(path);
    if (_size == null) {
      talker.error('Failed to get size of image, path: ${path}');
    } else {
      size = _size;
    }
  } else {
    try {
      size = ImageSizeGetter.getSize(FileInput(File(path)));
    } catch (e, stack) {
      talker.error('Failed to get size of image, path: ${path}: $e, $stack', e, stack);
      final _size = await getHeifImageSize2(path);
      if (_size == null) {
        talker.error('Failed to get size of heifImage, path: ${path}');
      } else {
        size = _size;
      }
    }
  }

  return size;
}

Future<Size> getVideoSize(Size size, String path) async {
  try {
    VideoPlayerController _controller = VideoPlayerController.file(File(path));
    await _controller.initialize();
    size = Size(_controller.value?.size?.width?.toInt() ?? 0, _controller.value?.size?.height?.toInt() ?? 0);
    _controller.dispose();
  } catch (e, stack) {
    talker.error('Failed to get size of video, path: ${path}: $e, $stack', e, stack);
  }
  return size;
}

Future<Size?> getHeifImageSize2(String filePath) async  {
  final properties = await FlutterNativeImage.getImageProperties(filePath);
  if (properties.width != 0 && properties.height != 0) {
    return Size(properties.width!, properties.height!);
  }
  return null;
}
