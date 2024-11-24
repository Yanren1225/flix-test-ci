import 'dart:collection';

import 'package:flix/domain/device/device_manager.dart';
import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/domain/ship_server/ship_service_proxy.dart';
import 'package:flix/network/discover/ping/ping_api.dart';
import 'package:flix/network/discover/ping/ping_impl.dart';
import 'package:flix/utils/net/net_utils.dart';

import '../protocol/device_modal.dart';

class NetworkConnectManager {
  NetworkConnectManager._privateConstructor();

  static final NetworkConnectManager _instance =
      NetworkConnectManager._privateConstructor();

  static NetworkConnectManager get instance {
    return _instance;
  }

  HashMap<String, DeviceModal> deviceMap = HashMap();

  HashSet<String> selfIP = HashSet();
  PingApi pingApi = PingImpl();

  Future<HashSet<String>> getSelfIP() async {
    if (selfIP.isEmpty) {
      var networkInterfaces = await getAvailableNetworkInterfaces();
      for (var networkInter in networkInterfaces) {
        selfIP.add(networkInter.address);
      }
    }
    return selfIP;
  }

  Future<bool> connect(String from, String ip) async {
    if ((await getSelfIP()).contains(ip)) {
      talker.debug('connect failed:$ip is myself,return from = $from');
      return false;
    }
    var deviceModal =
        await pingApi.pingWithTime(ip, await shipService.getPort(), from, 2000);
    deviceModal?.from = from;
    bool isAddSuccess = false;
    if (deviceModal != null) {
      isAddSuccess = DeviceManager.instance.addDevice(deviceModal);
    }
    talker.debug('connect from = $from ip = $ip deviceModal = $deviceModal  isAddSuccess = $isAddSuccess');
    return isAddSuccess;
  }
}
