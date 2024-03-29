import 'package:mime/mime.dart';

extension SizeUtils on int {
  String formateBinarySize() {
    if (this < 1024) {
      return '${toStringAsFixed(2)} B';
    } else if (this < 1024 * 1024) {
      return '${(this / 1024.0).toStringAsFixed(2)} KB';
    } else if (this < 1024 * 1024 * 1024) {
      return '${(this / 1024.0 / 1024).toStringAsFixed(2)} MB';
    } else {
      return '${(this / 1024.0 / 1024 / 1024).toStringAsFixed(2)} GB';
    }
  }
}





