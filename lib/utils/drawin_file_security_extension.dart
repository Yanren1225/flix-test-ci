import 'dart:io';

import 'package:flix/model/ui_bubble/shared_file.dart';
import 'package:macos_secure_bookmarks/macos_secure_bookmarks.dart';
import 'package:shared_preferences/shared_preferences.dart';

mixin DrawinFileSecurityExtension {
  final secureBookmarks = SecureBookmarks();

  Future<void> resolvePath(Future<void> Function(String path) callback) async {
    final fileMeta = this as FileMeta;
    await fileMeta.path!.resolvePath(callback);
  }

  Future<void> startAccessPath() async {
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
    }
  }

  Future<void> stopAccessPath() async {
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
        await secureBookmarks.stopAccessingSecurityScopedResource(resolvedFile);
      }
    }
  }
}

extension FilePathAuthorExtension on String {
  Future<void> resolvePath(Future<void> Function(String path) callback) async {
    if (Platform.isMacOS) {
      final secureBookmarks = SecureBookmarks();
      var sharePreference = await SharedPreferences.getInstance();
      var bookmark = sharePreference.getString(this);
      if (bookmark == null) {
        bookmark = await secureBookmarks.bookmark(File(this));
        sharePreference.setString(this, bookmark);
        await callback.call(this);
      } else {
        final resolvedFile = await secureBookmarks.resolveBookmark(bookmark);
        await secureBookmarks
            .startAccessingSecurityScopedResource(resolvedFile);
        await callback.call(this);
        await secureBookmarks.stopAccessingSecurityScopedResource(resolvedFile);
      }
    } else {
      await callback.call(this);
    }
  }

}



Future<void> authPersistentAccess(String path) async {
  if (Platform.isMacOS) {
    final secureBookmarks = SecureBookmarks();
    var sharePreference = await SharedPreferences.getInstance();
    var bookmark = sharePreference.getString(path);
    if (bookmark == null) {
      bookmark = await secureBookmarks.bookmark(File(path));
      sharePreference.setString(path, bookmark);
    }
  }
}
