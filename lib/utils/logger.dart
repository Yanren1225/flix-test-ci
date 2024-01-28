class Logger {
  static void log(String log) {
    print(log);
  }

  static void logException(String log, Object exception) {
    print("${log} exeption:$exception");
  }
}
