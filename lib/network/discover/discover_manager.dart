import 'dart:io';

import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/network/discover/discover_api.dart';
import 'package:flix/network/discover/discover_param.dart';
import 'package:flix/network/discover/impl/port_discover_impl.dart';
import 'package:flix/network/discover/network_connect_manager.dart';
typedef DeviceDiscoverCallback = void Function(
    String ip, String from);

class DiscoverManager {
  DiscoverManager._privateConstructor();

  static final DiscoverManager _instance =
      DiscoverManager._privateConstructor();

  static DiscoverManager get instance {
    return _instance;
  }

  List<DiscoverApi> discovers = [
    PortDiscoverImpl(),
    // BonjourDiscoverImpl()
    // MultiDiscoverImpl(),
  ];

  void stop(){
    for(var discover in discovers){
      discover.stop();
    }
  }

  DeviceDiscoverCallback deviceDiscoverCallback = (ip, from) {
    talker.debug('discover from $from device is $ip');
    NetworkConnectManager.instance.connect(from, ip);
  };

  void startDiscover(int port) {
    for (var discoverItem in discovers) {
      var discoverParam =
          DiscoverParam.name(deviceDiscoverCallback, discoverItem.getFrom());
      discoverParam.port = port;
      discoverItem.startScan(discoverParam);
    }
  }
}
