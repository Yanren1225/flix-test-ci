import 'dart:io';

import 'package:androp/model/ui_bubble/shared_file.dart';
import 'package:macos_secure_bookmarks/macos_secure_bookmarks.dart';
import 'package:shared_preferences/shared_preferences.dart';

mixin DrawinFileSecurityExtension {
  final secureBookmarks = SecureBookmarks();

  Future<void> resolvePath(Future<void> Function(String path) callback) async {
    final fileMeta = this as FileMeta;
    if (Platform.isMacOS) {
      final secureBookmarks = SecureBookmarks();
      var sharePreference = await SharedPreferences.getInstance();
      var bookmark = sharePreference.getString(fileMeta.path!);
      if (bookmark == null) {
        bookmark = await secureBookmarks.bookmark(File(fileMeta.path!));
        sharePreference.setString(fileMeta.path!, bookmark);
        await callback.call(fileMeta.path!);
      } else {
        final resolvedFile = await secureBookmarks.resolveBookmark(bookmark);
        await secureBookmarks.startAccessingSecurityScopedResource(resolvedFile);
        await callback.call(fileMeta.path!);
        await secureBookmarks.stopAccessingSecurityScopedResource(resolvedFile);
      }
    } else {
      await callback.call(fileMeta.path!);
    }
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
        await secureBookmarks.startAccessingSecurityScopedResource(resolvedFile);
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
