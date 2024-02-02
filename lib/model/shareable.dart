import 'package:androp/model/bubble/shared_file.dart';
import 'package:device_apps/device_apps.dart';
import 'package:file_selector/file_selector.dart';

abstract class Shareable<C> {
  String get id;
  C get content;
}

class SharedText extends Shareable<String> {
  @override
  final String content;

  @override
  final String id;

  SharedText({required this.id, required this.content});
}

class SharedImage extends Shareable<FileMeta> {
  /// image uri
  @override
  final FileMeta content;

  @override
  final String id;

  SharedImage({required this.id, required this.content});
}

class SharedVideo extends Shareable<String> {
  /// video uri
  @override
  final String content;

  @override
  final String id;

  SharedVideo({required this.id, required this.content});
}

class SharedApp extends Shareable<Application> {
  /// app
  @override
  final Application content;

  @override
  final String id;

  SharedApp({required this.id, required this.content});
}
