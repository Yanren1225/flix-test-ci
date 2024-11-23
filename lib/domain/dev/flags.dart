import 'dart:ffi';

import 'package:flix/domain/dev/flag.dart';
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

  final IntFlag multicastPort = IntFlag('multicast_port', '多播端口', 8891);
  final StringFlag multicastGroup = StringFlag(
      'multicast_group',
      '多播组',
      '224.0.0.168',
      'The default multicast group should be 224.0.0.0/24, because on some Android devices this is the only IP range that can receive UDP multicast messages.');
  final IntFlag defaultPort = IntFlag('default_port', '默认端口', 8891);

  final BoolFlag devMode = BoolFlag('dev_mode', '开发者模式', !kReleaseMode);
  final BoolFlag showLocalhost =
      BoolFlag('show_localhost', '显示 localhost', false);
  final BoolFlag enableSpeedTestApi = BoolFlag('enable_speed_test_api',
      '启用测速 API', false, '启用后，可在 GET /speedtest 获得一个 100GB 的文件流');

  final flags = [];

  FlagRepo() {
    flags.addAll([
      multicastPort,
      multicastGroup,
      defaultPort,
      devMode,
      showLocalhost,
      enableSpeedTestApi
    ]);

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
