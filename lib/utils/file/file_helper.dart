import 'dart:io';

import 'package:androp/model/ui_bubble/shared_file.dart';
import 'package:device_apps/device_apps.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:mime/mime.dart';
import 'package:shared_storage/shared_storage.dart' as shared_storage;
import 'package:path_provider/path_provider.dart' as path;

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
  Future<FileMeta> toFileMeta() async {
    return FileMeta(
        name: this.name,
        path: this.path,
        mimeType: this.mimeType ?? 'application/octet-stream',
        nameWithSuffix: this.name,
        size: await length());
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
    if (this.apkFilePath
    == null) {
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
