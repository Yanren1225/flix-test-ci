import 'dart:async';
import 'dart:io';

import 'package:device_apps/device_apps.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/model/ui_bubble/shared_file.dart';
import 'package:flix/utils/drawin_file_security_extension.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:image_size_getter/file_input.dart';
import 'package:image_size_getter/image_size_getter.dart';
import 'package:mime/mime.dart';
import 'package:open_dir/open_dir.dart';
import 'package:path/path.dart' as path_utils;
import 'package:path_provider/path_provider.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:share_handler/share_handler.dart';
import 'package:shared_storage/shared_storage.dart' as shared_storage;
import 'package:video_player/video_player.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

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
        resourceId: '',
        name: name,
        path: this.path,
        mimeType: mimeType ?? 'application/octet-stream',
        nameWithSuffix: name,
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
    if (type == SharedAttachmentType.image) {
      size = await getImgSize(size, this.path);
    } else if (type == SharedAttachmentType.video) {
      size = await getVideoSize(size, this.path);
    }

    final fileName = _getFileNameFromPath(this.path);

    return FileMeta(
        resourceId: '',
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
    await authPersistentAccess(this.path!);
    return FileMeta(
        resourceId: '',
        name: name,
        path: this.path,
        mimeType: lookupMimeType(name) ?? 'application/octet-stream',
        nameWithSuffix: name,
        size: size);
  }
}

extension FileConvert on File {
  Future<FileMeta> toFileMeta({DirectoryMeta? parent}) async {
    await authPersistentAccess(this.path);
    return FileMeta(
        resourceId: '',
        name: path_utils.basename(this.path),
        path: this.path,
        mimeType: lookupMimeType(this.path) ?? 'application/octet-stream',
        nameWithSuffix: path_utils.basename(this.path),
        size: lengthSync(),
        parent: parent);
  }
}

extension ApplicationConvert on Application {
  Future<FileMeta> toFileMeta() async {
    return FileMeta(
        resourceId: '',
        name: '$packageName.apk',
        path: apkFilePath,
        mimeType: 'application/vnd.android.package-archive',
        nameWithSuffix: '$packageName.apk',
        size: File(apkFilePath).lengthSync());
  }
}

extension AssetEntityExtension on AssetEntity {
  Future<FileMeta> toFileMeta() async {
    final title = await titleAsync;
    final file = await originFile;

    return FileMeta(
        resourceId: id,
        name: title,
        path: file?.path ?? '',
        mimeType: await mimeTypeAsync ?? 'application/octet-stream',
        nameWithSuffix: title,
        size: await file?.length() ?? 0,
        width: orientatedWidth,
        height: orientatedHeight);
  }
}

Future deleteCache() async {
  // ...
  // _deleteFilesInDir(await getApplicationSupportDirectory());

  // 删除数据库文件
  // _deleteFilesInDir(await getApplicationDocumentsDirectory());

  // final tmpDir = await getTemporaryDirectory();
  if (Platform.isIOS) {
    String tmpPath = await getTmpPath();
    final tmpDir = Directory(tmpPath);
    talker.debug('clean tmp dir: ${tmpDir.path}');
    // 删除临时文件
    _deleteFilesInDir(tmpDir);
  }

  //  删除缓存文件
  final cacheDir = await getApplicationCacheDirectory();
  talker.debug('clean cache dir: ${cacheDir.path}');
  _deleteFilesInDir(cacheDir);
}

Future<bool> isInCacheOrTmpDir(String path) async {
  if (Platform.isIOS) {
    String tmpPath = await getTmpPath();
    if (path.toLowerCase().startsWith(tmpPath.toLowerCase())) {
      return true;
    }
  }

  final cacheDir = await getApplicationCacheDirectory();
  return path.toLowerCase().startsWith(cacheDir.path.toLowerCase());
}

Future<String> getTmpPath() async {
  if (Platform.isAndroid) {
    return await getCachePath();
  } else {
    return await _getTmpPath();
  }
}

Future<String> _getTmpPath() async {
  final Directory directory = await getApplicationDocumentsDirectory();
  String tmpPath = "${directory.parent.path}/tmp/";
  return tmpPath;
}

Future<String> getCachePath() async {
  return (await getApplicationCacheDirectory()).path;
}

Future<void> _deleteFilesInDir(Directory dir) async {
  dir.list(recursive: true).forEach((entity) async {
    if (entity is File) {
      try {
        talker.verbose('delete ${entity.path}');
        await entity.delete();
      } catch (e) {
        talker.error('delete ${entity.path} failed: ', e);
      }
    }
  });
}

String _getFileNameFromPath(String path) {
  return path.substring(path.lastIndexOf('/') + 1);
}

Future<Size> getImgSize(Size size, String path) async {
  // TODO: 其他平台也优先使用getHeifImageSize2
  try {
    if (Platform.isIOS) {
      final size0 = await getHeifImageSize2(path);
      if (size0 == null) {
        talker.error('Failed to get size of image, path: $path');
      } else {
        size = size0;
      }
    } else {
      try {
        size = ImageSizeGetter.getSize(FileInput(File(path)));
        if (size.needRotate) {
          size = Size(size.height, size.width);
        }
      } catch (e, stack) {
        talker.error('inner: Failed to get size of image, path: $path: $e, $stack', e,
            stack);
        final size0 = await getHeifImageSize2(path);
        if (size0 == null) {
          talker.error('Failed to get size of heifImage, path: $path');
        } else {
          size = size0;
        }
      }
    }
  } catch (e, stacktrace) {
    talker.error('outer: Failed to get image size, path: $path', e, stacktrace);
  }

  return size;
}

Future<Size> getVideoSize(Size size, String path) async {
  try {
    VideoPlayerController controller = VideoPlayerController.file(File(path));
    await controller.initialize();
    size = Size(controller.value.size.width.toInt(), controller.value.size.height.toInt());
    controller.dispose();
  } catch (e, stack) {
    talker.error('Failed to get size of video, path: $path: $e, $stack', e, stack);
  }
  return size;
}

Future<Size?> getHeifImageSize2(String filePath) async {
  final properties = await FlutterNativeImage.getImageProperties(filePath);
  if (properties.width != 0 && properties.height != 0) {
    if (properties.orientation == ImageOrientation.rotate90 ||
        properties.orientation == ImageOrientation.rotate270) {
      return Size(properties.height!, properties.width!);
    } else {
      return Size(properties.width!, properties.height!);
    }
  }
  return null;
}

String mimeIcon(String filePath) {
  if(filePath == '/') {
    return "assets/images/ic_dir.svg";
  }
  // 识别word excel ppt pdf 图片 视频等文件
  final mimeType = lookupMimeType(filePath) ?? "";
  if (mimeType.startsWith('application/vnd.openxmlformats-officedocument')) {
    if (mimeType
        .startsWith('application/vnd.openxmlformats-officedocument.word')) {
      return 'assets/images/ic_txt.svg';
    } else if (mimeType.startsWith(
        'application/vnd.openxmlformats-officedocument.spreadsheet')) {
      return 'assets/images/ic_excel.svg';
    } else if (mimeType.startsWith(
        'application/vnd.openxmlformats-officedocument.presentation')) {
      return 'assets/images/ic_ppt.svg';
    } else {
      return 'assets/images/ic_unknown_type.svg';
    }
  } else if (mimeType.startsWith('image')) {
    return 'assets/images/ic_mime_image.svg';
  } else if (mimeType.startsWith('video')) {
    return 'assets/images/ic_mime_video.svg';
  } else if (mimeType.startsWith('text')) {
    return 'assets/images/ic_txt.svg';
  } else if (mimeType.startsWith('application/zip')) {
    return 'assets/images/ic_zip.svg';
  } else if (mimeType.startsWith('audio')) {
    return 'assets/images/ic_audio.svg';
  } else if (mimeType.startsWith('application/vnd.android.package-archive')) {
    return 'assets/images/ic_apk.svg';
  } else {
    return 'assets/images/ic_unknown_type.svg';
  }
}

// 判断文件是图片、视频还是其他
FileType getFileType(String filePath) {
  final mimeType = lookupMimeType(filePath) ?? "";
  if (mimeType.startsWith('image')) {
    return FileType.image;
  } else if (mimeType.startsWith('video')) {
    return FileType.video;
  } else {
    return FileType.other;
  }
}

Future<File> createFile(String desDir, String fileName,
    {int copyIndex = 0,bool deleteExist = true}) async {
  final dotIndex = fileName.lastIndexOf('.');
  final String fileSuffix;
  final String fileNameWithoutSuffix;
  if (dotIndex == -1) {
    fileSuffix = "";
    fileNameWithoutSuffix = fileName;
  } else {
    fileSuffix = fileName.substring(dotIndex);
    fileNameWithoutSuffix = fileName.substring(0, dotIndex);
  }

  final tag = copyIndex == 0 ? "" : "($copyIndex)";
  String filePath = '$desDir${Platform.pathSeparator}$fileNameWithoutSuffix$tag$fileSuffix';
  final outFile = File(filePath);
  if (await outFile.exists()) {
    if (!deleteExist) {
      return outFile;
    }
    try {
      await outFile.delete();
    } catch (e, stackTrace) {
      talker.warning('delete file failed: ', e, stackTrace);
    }
  }

  if (!(await outFile.exists())) {
    await outFile.create(recursive: true);
    return outFile;
  }

  return await createFile(desDir, fileName, copyIndex: copyIndex + 1);
}

Future<void> openDir(String path) async {
  if (Platform.isWindows) {
    openFileDirectoryOnWindows(path);
  } else {
    OpenDir()
        .openNativeDir(
        path: path)
        .catchError(
            (e, s) => talker.error('Failed to open folder: ', e, s));
  }
}


Future<void> openFileDirectoryOnWindows(String path) async {
  try {
    final encodePath = File(path).parent.path.replaceAll('/', '\\');
    if (Platform.isWindows) {
      // 使用 Explorer 打开目录
      final result = await Process.run('explorer', [encodePath]);
      talker.info('open file directory result: $result');
      return;
    }
  } catch (e, s) {
    talker.error('Failed to open file directory', e, s);
  }

}

enum FileType {
  image,
  video,
  other;
}

enum FilePathSaveType { full, relative, none }
