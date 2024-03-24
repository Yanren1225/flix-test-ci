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

String mimeIcon(String filePath) {
  final mimeType = lookupMimeType(filePath) ?? "";
  if (mimeType.startsWith('application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')) {
    return 'assets/images/ic_excel.svg';
  } else if (mimeType.startsWith('text')) {
    return 'assets/images/ic_txt.svg';
  } else if (mimeType.startsWith('application/zip')) {
    return 'assets/images/ic_zip.svg';
  } else if (mimeType.startsWith('audio')) {
    return 'assets/images/ic_audio.svg';
  } else if (mimeType.startsWith('application/vnd.android.package-archive')) {
    return 'assets/images/ic_apk.svg';
  } else {
    return 'assets/images/ic_unknown_type.svg';
  }
}
