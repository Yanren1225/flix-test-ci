import 'package:flix/domain/log/persistence/log_persistence_proxy.dart';
import 'package:flutter/services.dart';
import 'package:talker_flutter/talker_flutter.dart';

final talker = TalkerFlutter.init(
  observer: _FlixTalkerObserver(),
  settings: TalkerSettings(

      /// You can enable/disable all talker processes with this field
      enabled: true,

      /// You can enable/disable saving logs data in history
      useHistory: true,

      /// Length of history that saving logs data
      maxHistoryItems: 10000,

      /// You can enable/disable console logs
      useConsoleLogs: true,
      colors: {
        TalkerLogType.verbose: AnsiPen()..gray(),
        TalkerLogType.info: AnsiPen()..blue(),
        TalkerLogType.debug: AnsiPen()..black(),
      }),

  /// Setup your implementation of logger
  logger: TalkerLogger(),

  ///etc...
);

class _FlixTalkerObserver extends TalkerObserver {
  _FlixTalkerObserver();

  @override
  void onError(TalkerError err) {
    super.onError(err);
    logPersistence.write('${err.generateTextMessage()}\n');
  }

  @override
  void onException(TalkerException exception) {
    super.onException(exception);
    logPersistence.write('${exception.generateTextMessage()}\n');
  }

  @override
  void onLog(TalkerData log) {
    super.onLog(log);
    logPersistence.write('${log.generateTextMessage()}\n');
  }
}

void initLog() {
  const logIosChannel = MethodChannel("com.ifreedomer.flix/log");
  logIosChannel.setMethodCallHandler((call) async {
    try {
      if (call.method == "log") {
        final args = call.arguments as Map;
        switch (args["level"] as String) {
          case "error":
            talker.error(args["msg"] as String);
            break;
          case "critical":
            talker.critical(args["msg"] as String);
            break;
          case "info":
            talker.info(args["msg"] as String);
            break;
          case "debug":
            talker.debug(args["msg"] as String);
            break;
          case "verbose":
            talker.verbose(args["msg"] as String);
            break;
          case "warning":
            talker.warning(args["msg"] as String);
            break;
          case "exception":
            break;
        }
      }
    } catch (e) {}
  });
}
