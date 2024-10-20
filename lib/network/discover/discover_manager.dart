import 'dart:io';

import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/network/discover/discover_api.dart';
import 'package:flix/network/discover/discover_param.dart';
import 'package:flix/network/discover/impl/port_discover_impl.dart';
import 'package:flix/network/discover/network_connect_manager.dart';
import 'package:flix/network/nearby_service_info.dart';

import 'impl/multi_discover_impl.dart';

typedef DeviceDiscoverCallback = void Function(String ip, String from);
typedef DeviceDiscoverFinishCallback = void Function(String from);
typedef DeviceDiscoverErrorCallback = void Function(
    String from, int errorCode, String errorMsg);

class DiscoverManager {
  static const String tag = "DiscoverManager";

  DiscoverManager._privateConstructor();

  static final DiscoverManager _instance =
      DiscoverManager._privateConstructor();

  static DiscoverManager get instance {
    return _instance;
  }

  final List<DeviceDiscoverFinishCallback> _onFinishListener = [];

  void addOnFinishListener(DeviceDiscoverFinishCallback onFinish) {
    _onFinishListener.add(onFinish);
  }

  void removeOnFinishListener(DeviceDiscoverFinishCallback onFinish) {
    _onFinishListener.remove(onFinish);
  }
  // PortDiscoverImpl(),
  // BonjourDiscoverImpl(),
  List<DiscoverApi> discovers = [
    MultiDiscoverImpl(),
    PortDiscoverImpl()
  ];

  void stop() {
    for (var discover in discovers) {
      discover.stop();
    }
  }

  DeviceDiscoverCallback deviceDiscoverCallback = (ip, from) {
    talker.debug(tag, 'discover from $from device is $ip');
    NetworkConnectManager.instance.connect(from, ip);
  };

  DeviceDiscoverFinishCallback discoverFinishCallback = (from) {
    talker.debug(tag, "discoverFinishCallback");
    for (var listener in DiscoverManager.instance._onFinishListener) {
      listener.call(from);
    }
  };

  DeviceDiscoverErrorCallback discoverErrorCallback = (from, errorCode, errorMsg) {
    talker.debug(tag,
        "discoverErrorCallback from = $from  errorCode = $errorCode  errorMsg = $errorMsg");
  };

  void startDiscover(int port) {
    for (var discoverItem in discovers) {
      var discoverParam = DiscoverParam(
          defaultMulticastGroup,
          port,
          deviceDiscoverCallback,
          discoverFinishCallback,
          discoverErrorCallback,
          discoverItem.getFrom());
      discoverItem.startScan(discoverParam);
    }
  }
}
