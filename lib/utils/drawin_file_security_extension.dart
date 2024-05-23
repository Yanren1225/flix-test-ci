import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/model/ui_bubble/shared_file.dart';
import 'package:flix/utils/file/file_helper.dart';
import 'package:macos_secure_bookmarks/macos_secure_bookmarks.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

mixin DrawinFileSecurityExtension {
  final secureBookmarks = SecureBookmarks();

  Future<void> resolvePath(Future<void> Function(String path) callback) async {
    final fileMeta = this as FileMeta;
    await _resolvePath(fileMeta.resourceId, fileMeta.path!, callback);
  }

  Future<String> startAccessPath() async {
    final fileMeta = this as FileMeta;
    if (Platform.isMacOS) {
      final secureBookmarks = SecureBookmarks();
      var sharePreference = await SharedPreferences.getInstance();
      var bookmark = sharePreference.getString(fileMeta.path!);
      if (bookmark == null) {
        bookmark = await secureBookmarks.bookmark(File(fileMeta.path!));
        sharePreference.setString(fileMeta.path!, bookmark);
      } else {
        final resolvedFile = await secureBookmarks.resolveBookmark(bookmark);
        await secureBookmarks
            .startAccessingSecurityScopedResource(resolvedFile);
      }
    } else if (Platform.isIOS && fileMeta.resourceId.isNotEmpty && (fileMeta.path == null || !(await File(fileMeta.path!).exists()))) {
      final AssetEntity? asset = await AssetEntity.fromId(fileMeta.resourceId);
      if (asset != null) {
        final file = await asset.originFile;
        return file?.path ?? '';
      } else if (fileMeta.path != null) {
        return await replaceSandboxPath(fileMeta.path!);
      }
    } else if (Platform.isIOS && fileMeta.path != null && fileMeta.path!.isNotEmpty && !(await File(fileMeta.path!).exists())) {
      return await replaceSandboxPath(fileMeta.path!);

    }

    return fileMeta.path ?? '';
  }

  Future<void> stopAccessPath() async {
    final fileMeta = this as FileMeta;
    if (fileMeta.path == null) return;
    if (Platform.isMacOS) {
      final secureBookmarks = SecureBookmarks();
      var sharePreference = await SharedPreferences.getInstance();
      var bookmark = sharePreference.getString(fileMeta.path!);
      if (bookmark == null) {
        try {
          bookmark = await secureBookmarks.bookmark(File(fileMeta.path!));
          sharePreference.setString(fileMeta.path!, bookmark);
        } catch (e, s) {
          talker.error('authPersistentAccess failed: ${fileMeta.path}', e, s);
        }
      } else {
        final resolvedFile = await secureBookmarks.resolveBookmark(bookmark);
        await secureBookmarks.stopAccessingSecurityScopedResource(resolvedFile);
      }
    }
  }
}

Future<void> _resolvePath(String resourceId, String path,
    Future<void> Function(String path) callback) async {
  if (Platform.isMacOS) {
    final secureBookmarks = SecureBookmarks();
    var sharePreference = await SharedPreferences.getInstance();
    var bookmark = sharePreference.getString(path);
    if (bookmark == null) {
      try {
        bookmark = await secureBookmarks.bookmark(File(path));
        sharePreference.setString(path, bookmark);
      } catch (e, s) {
        talker.error('authPersistentAccess failed: $path', e, s);
      }
      await callback.call(path);
    } else {
      final resolvedFile = await secureBookmarks.resolveBookmark(bookmark);
      await secureBookmarks.startAccessingSecurityScopedResource(resolvedFile);
      await callback.call(path);
      await secureBookmarks.stopAccessingSecurityScopedResource(resolvedFile);
    }
  } else if (Platform.isIOS && resourceId.isNotEmpty) {
    final AssetEntity? asset = await AssetEntity.fromId(resourceId);
    if (asset != null) {
      final file = await asset.originFile;
      await callback.call(file?.path ?? '');
    } else {
      await callback.call(await replaceSandboxPath(path));
    }
  } else if (Platform.isIOS && path.isNotEmpty) {
    callback.call(await replaceSandboxPath(path));
  } else {
    await callback.call(path);
  }
}

Future<void> authPersistentAccess(String path) async {
  if (Platform.isMacOS) {
    final secureBookmarks = SecureBookmarks();
    var sharePreference = await SharedPreferences.getInstance();
    var bookmark = sharePreference.getString(path);
    if (bookmark == null) {
      try {
        bookmark = await secureBookmarks.bookmark(File(path));
        sharePreference.setString(path, bookmark);
      } catch (e, s) {
        talker.error('authPersistentAccess failed: $path', e, s);
      }
    }
  }
}

Future<String> replaceSandboxPath(String originalPath) async {
  // 正则表达式模式，用于匹配沙盒路径的格式
  // 假设路径格式为：/var/mobile/Containers/Data/Application/一串字符/...
  final newPath = (await getApplicationDocumentsDirectory()).parent.path + Platform.pathSeparator;
  var pattern = RegExp(r'/var/mobile/Containers/Data/Application/[A-Za-z0-9-]+/');

  // 使用正则表达式的 replaceFirst 方法替换匹配到的第一个路径
  // 如果你需要替换所有匹配到的路径，可以使用replaceAll方法
  var updatedPath = originalPath.replaceFirst(pattern, newPath);

  return updatedPath;
}

