import 'package:device_apps/device_apps.dart';
import 'package:image_picker/image_picker.dart';

enum PickedFileType {
  Image,
  Video,
  App,
  Other;
}

abstract class Pickable<Content> {
  PickedFileType get type;
  Content get content;
}

class PickableFile extends Pickable<XFile> {
  @override
  PickedFileType type;
  @override
  XFile content;

  PickableFile({required this.type, required this.content});

  @override
  String toString() {
    return 'PickableFile{type: $type, file: ${content.path}}';
  }
}

class PickableApp extends Pickable<Application> {
  @override
  PickedFileType get type => PickedFileType.App;
  @override
  Application content;

  PickableApp({required this.content});

  @override
  String toString() {
    return 'PickableFile{type: $type, app: $content}';
  }
}
