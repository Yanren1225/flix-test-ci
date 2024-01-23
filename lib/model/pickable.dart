import 'package:image_picker/image_picker.dart';

enum PickedFileType {
  Image,
  Video,
  App,
  Other;
}

class Pickable {
  final PickedFileType type;
  final XFile file;

  Pickable({required this.type, required this.file});

  @override
  String toString() {
    return 'Pickable{type: $type, file: ${file.path}}';
  }
}
