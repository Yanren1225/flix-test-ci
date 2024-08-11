import 'dart:io';
import 'package:path/path.dart' as path_utils;
import '../../domain/settings/settings_repo.dart';

class FileUtils {
  static const String tempName = ".flixdownload";
  static Future<File> getTargetFile(String dir, String fileName) async {
    //判断文件夹存在,不存在创建
    Directory folder = Directory(dir);
    if(!await folder.exists()){
      await folder.create(recursive: true);
    }
    //文件本来不存在
    File outFile = File(dir + Platform.pathSeparator + fileName);
    if (!await outFile.exists()) {
      return outFile;
    }
    String desDir = path_utils.normalize(dir);
    String fileSuffix = getFileNameSuffix(fileName);
    String filePrefix = getFileNamePrefix(fileName);
    int copyIndex = 0;
    String filePath =
        '$desDir${Platform.pathSeparator}$fileSuffix$copyIndex$filePrefix';
    for (copyIndex = 0; copyIndex < 100; copyIndex++) {
      final tag = copyIndex == 0 ? "" : "($copyIndex)";
      filePath = '$desDir${Platform.pathSeparator}$filePrefix$tag$fileSuffix';
      if (!await File(filePath).exists()) {
        break;
      }
    }
    outFile = File(filePath);
    return outFile;
  }

  static Future<File> getOrCreateTempWithFolder(
      String dir, String fileName) async {
    String desDir = dir;
    desDir = path_utils.normalize(desDir);
    String tempFilePath = "$desDir${Platform.pathSeparator}$fileName$tempName";
    File file = File(tempFilePath);
    //判断文件夹存在,不存在创建
    Directory folder = Directory(dir);
    if(!await folder.exists()){
      await folder.create(recursive: true);
    }
    return file;
  }

  static Future<File> getOrCreateTempFile(String fileName) {
    return getOrCreateTempWithFolder(SettingsRepo.instance.savedDir, fileName);
  }

  static String getFileNamePrefix(String fileName) {
    //开始获取后缀名
    final dotIndex = fileName.lastIndexOf('.');
    final String fileNameWithoutSuffix;
    if (dotIndex == -1) {
      fileNameWithoutSuffix = fileName;
    } else {
      fileNameWithoutSuffix = fileName.substring(0, dotIndex);
    }
    return fileNameWithoutSuffix;
  }

  static String getFileNameSuffix(String fileName) {
    final dotIndex = fileName.lastIndexOf('.');
    final String fileSuffix;
    if (dotIndex == -1) {
      fileSuffix = "";
    } else {
      fileSuffix = fileName.substring(dotIndex);
    }
    return fileSuffix;
  }
}
