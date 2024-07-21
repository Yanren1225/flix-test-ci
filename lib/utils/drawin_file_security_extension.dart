import 'dart:io';

import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/model/ui_bubble/shared_file.dart';
import 'package:macos_secure_bookmarks/macos_secure_bookmarks.dart';
import 'package:path/path.dart' as path;
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
      await startAccessPathOnMacos(fileMeta.path!);
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
      await stopAccessPathOnMacos(fileMeta.path!);
    }
  }


}

Future<void> _resolvePath(String resourceId, String path,
    Future<void> Function(String path) callback) async {
  if (Platform.isMacOS) {
    await resolvePathOnMacOS(path, callback);
  } else if (Platform.isIOS && resourceId.isNotEmpty) {
    final AssetEntity? asset = await AssetEntity.fromId(resourceId);
    if (asset != null) {
      final file = await asset.originFile;
      await callback.call(file?.path ?? '');
    } else {
      await callback.call(await replaceSandboxPath(path));
    }
  } else if (Platform.isIOS && path.isNotEmpty) {
    await callback.call(await replaceSandboxPath(path));
  } else {
    await callback.call(path);
  }
}

Future<void> resolvePathOnMacOS(String path, Future<void> Function(String path) callback) async {
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
  } else {
    await callback(path);
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

Future<void> startAccessPathOnMacos(String path) async {
  if (Platform.isMacOS) {
    final secureBookmarks = SecureBookmarks();
    var sharePreference = await SharedPreferences.getInstance();
    var bookmark = sharePreference.getString(path);
    if (bookmark == null) {
      bookmark = await secureBookmarks.bookmark(File(path));
      sharePreference.setString(path, bookmark);
    } else {
      final resolvedFile = await secureBookmarks.resolveBookmark(bookmark);
      await secureBookmarks
          .startAccessingSecurityScopedResource(resolvedFile);
    }
  }

}

Future<void> stopAccessPathOnMacos(String path) async {
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
    } else {
      final resolvedFile = await secureBookmarks.resolveBookmark(bookmark);
      await secureBookmarks.stopAccessingSecurityScopedResource(resolvedFile);
    }
  }

}

String ensureTrailingSeparator(String p) {
  if (!p.endsWith(path.separator)) {
    return p + path.separator;
  }
  return p;
}

/// 安全的文件路径拼接：平台分隔符处理、路径拼接边界处理
String safeJoinPaths(String basePath, String relativePath) {
  talker.debug("safeJoinPaths: basePath=$basePath, relativePath=$relativePath");
  String safeBasePath = basePath;
  if(containsNonPlatformSeparator(safeBasePath)) {
    safeBasePath = normalizePath(safeBasePath);
  }
  safeBasePath=path.normalize(safeBasePath);

  String safeRelativePath = relativePath;
  if (containsNonPlatformSeparator(safeRelativePath)) {
    safeRelativePath = normalizePath(safeRelativePath);
  }
  safeRelativePath = path.normalize(safeRelativePath);

  if(safeRelativePath.startsWith(safeBasePath)){
    talker.debug("safeJoinPaths: safeRelativePath=$safeRelativePath");
    return safeRelativePath;
  }
  // 确保 basePath 以分隔符结尾
  safeBasePath = ensureTrailingSeparator(safeBasePath);

  // 确保 relativePath 不以分隔符开头
  if (safeRelativePath.startsWith(path.separator)) {
    safeRelativePath = safeRelativePath.substring(1);
  }

  String fullPath = path.absolute(safeBasePath, safeRelativePath);
  talker.debug("safeJoinPaths: fullPath=$fullPath");
  return fullPath;
}

String getRelativePath(String fullPath, String rootPath) {
  // 获取相对路径
  String relativePath = path.relative(fullPath, from: rootPath);
  // 获取相对路径的目录部分
  String relativeDirectory = path.dirname(relativePath);
  // 确保相对目录不以分隔符开头
  if (relativeDirectory.startsWith(path.separator)) {
    relativeDirectory = relativeDirectory.substring(1);
  }
  return relativeDirectory;
}

/// 判断是否存在非此平台的文件分隔符
bool containsNonPlatformSeparator(String filePath) {
  String currentSeparator = path.separator;
  String nonPlatformSeparator = currentSeparator == '/' ? '\\' : '/';

  return filePath.contains(nonPlatformSeparator);
}

/// 将传入的路径标准化为当前平台的路径格式
String normalizePath(String originalPath) {
  // 分割原始路径为路径段
  List<String> segments = path.split(originalPath);
  // 使用当前平台的路径分隔符重新拼接路径
  return path.joinAll(segments);
}