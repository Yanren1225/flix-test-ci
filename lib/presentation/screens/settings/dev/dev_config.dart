import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../domain/dev/flags.dart';
import '../../../../domain/log/flix_log.dart';
import '../../../widgets/flix_toast.dart';

class DevConfig extends ChangeNotifier {
  final _dev = FlagRepo.instance.devMode;
  var _counter = 0;

  static DevConfig? _instance;

  DevConfig() {
    if (!kReleaseMode) {
      _dev.value = true;
    }

    _dev.addListener(() {
      notifyListeners();
    });
  }

  void onCounter() {
    talker.debug("onCounter, counter = $_counter, dev = $_dev");

    if (_dev.value) {
      FlixToast.instance.alert("您已处在开发者模式");
      return;
    }

    _counter++;
    if (_counter == 5) {
      _dev.value = true;
      FlixToast.instance.info("开发者模式已开启");
      notifyListeners();
    }

    //clear counter after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      _counter = 0;
      talker.debug("clear counter, counter = $_counter, dev = $_dev");
    });
  }

  void disableDev() {
    _dev.value = false;
    notifyListeners();
  }

  bool get current => _dev.value;

  static DevConfig get instance {
    _instance ??= DevConfig();
    return _instance!;
  }
}
