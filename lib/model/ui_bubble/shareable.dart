import 'package:device_apps/device_apps.dart';

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

class SharedApp extends Shareable<Application> {
  /// app
  @override
  final Application content;

  @override
  final String id;

  SharedApp({required this.id, required this.content});
}
