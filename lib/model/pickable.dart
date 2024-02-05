import 'package:androp/model/ui_bubble/shared_file.dart';
import 'package:device_apps/device_apps.dart';
import 'package:image_picker/image_picker.dart';

enum PickedFileType {
  Image,
  Video,
  App,
  File;
}

abstract class Pickable<Content> {
  PickedFileType get type;
  Content get content;
}

class PickableFile extends Pickable<FileMeta> {
  @override
  PickedFileType type;
  @override
  FileMeta content;

  PickableFile({required this.type, required this.content});

  @override
  String toString() {
    return 'PickableFile{type: $type, file: $content}';
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
