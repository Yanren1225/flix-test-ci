import 'dart:ffi';

import 'package:flix/domain/dev/flag.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import '../../network/multicast_client_provider.dart';
import '../../network/protocol/device_modal.dart';
import '../../presentation/screens/settings/dev/client_debug_page.dart';
import '../device/device_manager.dart';

class FlagRepo extends ChangeNotifier {
  static FlagRepo? _instance;

  static FlagRepo get instance {
    _instance ??= FlagRepo();
    return _instance!;
  }

  /// 在这里定义所有的 flag

  final BoolFlag devMode = BoolFlag('dev_mode', '开发者模式', !kReleaseMode);
  final BoolFlag showLocalhost =
      BoolFlag('show_localhost', '显示 localhost', false);
  final BoolFlag enableSpeedTestApi =
      BoolFlag('enable_speed_test_api', '启用测速 API', false);

  final flags = [];

  FlagRepo() {
    flags.addAll([devMode, showLocalhost, enableSpeedTestApi]);

    showLocalhost.addListener(() {
      generateLocalhostDevice().then((DeviceModal localhost) {
        if (showLocalhost.value == true) {
          DeviceManager.instance.addDevice(localhost);
        } else {
          DeviceManager.instance.deleteDevice(localhost);
        }
      });
    });

    for (var flag in flags) {
      flag.addListener(() {
        notifyListeners();
      });
    }
  }
}
