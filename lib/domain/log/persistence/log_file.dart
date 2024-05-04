import 'dart:io';

class LogFile {
  final String logPath;
  late File file;

  LogFile({required this.logPath}) {
    file = File(logPath);
  }

  void create() {
    file.createSync(recursive: true);
  }

  void write(String message) {
    file.writeAsStringSync(message, mode: FileMode.append);
  }

  int size() {
    return file.lengthSync();
  }

}