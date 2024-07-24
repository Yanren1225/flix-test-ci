
import 'package:flix/utils/android/android_file_info.dart';

class AndroidFilePackerResult {

  const AndroidFilePackerResult(this.infoList);

  final List<FileInfo> infoList;

  @override
  String toString() => 'AndroidFilePickerResult(files: $infoList)';

}