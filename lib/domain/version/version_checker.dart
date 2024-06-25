import 'dart:async';
import 'dart:io';

import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/presentation/dialog/new_version_bottomsheet.dart';
import 'package:flix/utils/android/android_utils.dart';
import 'package:flix/utils/file/file_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class VersionChecker {
  static String? newestVersion;
  static StreamController<String?> newestVersionStream = StreamController.broadcast();
  static SharedPreferences? _sp;

  static Future<SharedPreferences> _getSp() async {
    _sp ??= await SharedPreferences.getInstance();
    return _sp!;
  }

  static Future<String?> getNewestVersion() async {
    try {
      final response = await http.get(Uri.parse('https://1.mashiro.asia/'));
      if (response.statusCode == 200) {
        return response.body;
      } else {
        talker.error(
            "get newest version failed, status code: ${response.statusCode}, body: ${response.body}");
        return null;
      }
    } catch (e, s) {
      talker.error("get newest version failed", e, s);
      return null;
    }
  }

  static Future<bool> hasNewerVersion() async {
    try {
      final _newestVersion = await getNewestVersion();
      final info = await PackageInfo.fromPlatform();
      final newestVersionComponents = _newestVersion
          ?.split('.')
          ?.map((e) => int.parse(e))
          .toList(growable: false);
      final versionComponents = info.version
          .split('.')
          .map((e) => int.parse(e))
          .toList(growable: false);

      if (newestVersionComponents != null) {
        if (newestVersionComponents[0] > versionComponents[0] ||
            (newestVersionComponents[0] == versionComponents[0] &&
                newestVersionComponents[1] > versionComponents[1]) ||
            (newestVersionComponents[0] == versionComponents[0] &&
                newestVersionComponents[1] == versionComponents[1] &&
                newestVersionComponents[2] > versionComponents[2])) {
          newestVersion = _newestVersion;
          newestVersionStream.add(_newestVersion);
          return true;
        } else {
          return false;
        }
      }
      return false;
    } catch (e, s) {
      talker.error("check newer version failed", e, s);
      return false;
    }
  }

  static Future<int> getVersionPromptCount(String version) async {
    return (await _getSp()).getInt("${version}_prompt_count") ?? 0;
  }

  static Future<void> increaseVersionPromptCount(String version) async {
    final count = await getVersionPromptCount(version);
    (await _getSp()).setInt("${version}_prompt_count", count + 1);
  }

  static Future<void> installNewestPackage() async {
    final version = newestVersion;
    if (version == null) {
      return;
    }
    await _downloadPackage(version, (progress) {
      talker.info("download package progress: $progress");
    }, (packagePath) async {
      if (Platform.isAndroid) {
        await AndroidUtils.installApk(packagePath);
      } else {
        openDir(packagePath);
      }
    });
  }

  static Future<void> openDownloadUrl(String version, Function() onDone,
      Function(String errorTips) onError) async {
    final String url;
    // https://fl1x.mashiro.asia/download/android
    // https://fl1x.mashiro.asia/download/mac
    // https://fl1x.mashiro.asia/download/deb
    // https://fl1x.mashiro.asia/download/rpm
    // https://fl1x.mashiro.asia/download/windows
    if (Platform.isAndroid) {
      url = 'https://fl1x.mashiro.asia/download/android';
    } else if (Platform.isWindows) {
      url = 'https://fl1x.mashiro.asia/download/windows';
    } else if (Platform.isMacOS) {
      url = 'https://fl1x.mashiro.asia/download/mac';
    } else {
      url = 'https://flix.center';
    }
    if (await launchUrlString(url, mode: LaunchMode.externalApplication)) {
      onDone();
    } else {
      onError('下载安装包失败。下载链接已赋值到剪切板，请手动打开浏览器，并粘贴下载链接');
    }
  }

  static Future<void> _downloadPackage(
      String version,
      Function(double progress) onProgress,
      Function(String packagePath) onDone) async {
    final String url;
    if (Platform.isAndroid) {
      url = 'https://flix.mashiro.asia/flix.apk';
    } else if (Platform.isWindows) {
      url = 'https://flix.mashiro.asia/flix_win.exe';
    } else if (Platform.isMacOS) {
      url = 'https://flix.mashiro.asia/flix_mac.zip';
    } else {
      talker.error("unsupported platform");
      return;
    }
    final response =
        await http.Client().send(http.Request('GET', Uri.parse(url)));

    if (response.statusCode == 200) {
      final contentLength = response.contentLength ?? 0;
      final String filePath;
      if (Platform.isAndroid) {
        filePath = "${await getCachePath()}/flix_$version.apk";
      } else if (Platform.isWindows) {
        filePath = "${await getCachePath()}/flix_$version.exe";
      } else if (Platform.isMacOS) {
        filePath = "${await getCachePath()}/flix_$version.zip";
      } else {
        talker.error("unsupported platform");
        return;
      }
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
      await file.create();
      final sink = file.openWrite();

      int downloadedBytes = 0;

      response.stream.listen(
        (List<int> chunk) {
          downloadedBytes += chunk.length;
          sink.add(chunk);

          onProgress(downloadedBytes * 1.0 / contentLength);
        },
        onDone: () async {
          await sink.close();
          onProgress(1);
          onDone(file.path);
        },
        onError: (e, s) {
          talker.error("download package failed", e, s);
        },
        cancelOnError: true,
      );
    } else {
      talker.error(
          "download package failed, status code: ${response.statusCode}");
    }
  }


  static Future<void> checkNewVersion(BuildContext context, {bool ignorePromptCount = false}) async {
    if (await VersionChecker. hasNewerVersion() &&
        (ignorePromptCount || await VersionChecker.getVersionPromptCount(
            VersionChecker.newestVersion ?? "") ==
            0)) {
      final newestVersion = VersionChecker.newestVersion ?? "";
      if (!ignorePromptCount) {
        await VersionChecker.increaseVersionPromptCount(
            VersionChecker.newestVersion ?? "");
      }
      await showCupertinoModalPopup(
          context: context,
          builder: (_) {
            return NewVersionBottomSheet(version: newestVersion);
          });
    }
  }

}
