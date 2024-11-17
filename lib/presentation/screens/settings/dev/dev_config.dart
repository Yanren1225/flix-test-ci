import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../domain/log/flix_log.dart';
import '../../../widgets/flix_toast.dart';

class DevConfig extends ChangeNotifier {
  var _dev = false;
  var _counter = 0;

  static DevConfig? _instance;

  DevConfig() {
    if (!kReleaseMode) {
      _dev = true;
    }
    syncFromSP();
  }

  void syncFromSP() async {
    final sp = await SharedPreferences.getInstance();
    _dev = sp.getBool("dev") ?? !kReleaseMode;
    notifyListeners();
  }

  void syncToSP() async {
    final sp = await SharedPreferences.getInstance();
    sp.setBool("dev", _dev);
  }

  void onCounter() {
    talker.debug("onCounter, counter = $_counter, dev = $_dev");

    if (_dev) {
      FlixToast.instance.alert("您已处在开发者模式");
      return;
    }

    _counter++;
    if (_counter == 5) {
      _dev = true;
      FlixToast.instance.info("开发者模式已开启");
      notifyListeners();
      syncToSP();
    }

    //clear counter after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      _counter = 0;
      talker.debug("clear counter, counter = $_counter, dev = $_dev");
    });
  }

  void disableDev() {
    _dev = false;
    notifyListeners();
    syncToSP();
  }

  bool get current => _dev;

  static DevConfig get instance {
    _instance ??= DevConfig();
    return _instance!;
  }
}
