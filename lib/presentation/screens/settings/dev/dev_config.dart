import 'package:flutter/foundation.dart';

import '../../../../domain/log/flix_log.dart';
import '../../../widgets/flix_toast.dart';

class DevConfig {
  var dev = false;
  var counter = 0;

  static DevConfig? _instance;

  DevConfig() {
    if (!kReleaseMode) {
      dev = true;
    }
  }

  void onCounter() {

    talker.debug("onCounter, counter = $counter, dev = $dev");

    if (dev) {
      FlixToast.instance.alert("您已处在开发者模式");
      return;
    }

    counter++;
    if (counter == 5) {
      dev = true;
      FlixToast.instance.info("开发者模式已开启");
    }

    //clear counter after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      counter = 0;
      talker.debug("clear counter, counter = $counter, dev = $dev");
    });

  }

  bool get current => dev;

  static DevConfig get instance {
    _instance ??= DevConfig();
    return _instance!;
  }
}
