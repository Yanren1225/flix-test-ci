import 'dart:developer' as dev;

class Logger {
  static void log(String log) {
    dev.log(log);
    // print(log);
  }

  static void logException(String log, Object exception) {
    dev.log("${log} exeption:$exception");
    // print("${log} exeption:$exception");
  }
}
