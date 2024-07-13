import 'dart:async';

import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/model/hotspot/hotspot_info.dart';
import 'package:wifi_iot/wifi_iot.dart';

class DirectWifiManager  {
  HotspotInfo? hotspotInfo;
  StreamController<HotspotInfo?> hotspotInfoStreamController = StreamController.broadcast();

  DirectWifiManager._privateConstructor();

  Future<bool> connect(String ssid, String key) async {
    try {
      _setHotspotInfo(ssid, key);
      final result = await WiFiForIoTPlugin.connect(ssid,
          password:key, security: NetworkSecurity.WPA);
      WiFiForIoTPlugin.forceWifiUsage(true);
      return result;
    } catch (e, s) {
      talker.error('connect ap failed', e, s);
      return false;
    }
  }

  Future<bool> disconnect() async {
    try {
      final result = await WiFiForIoTPlugin.disconnect();
      _setHotspotInfo(null, null);
      return result;
    } catch (e, s) {
      talker.error('disconnect ap failed', e, s);
      return false;
    }
  }

  _setHotspotInfo(String? ssid, String? key) {
    if (ssid == null || key == null) {
      hotspotInfo = null;
    } else {
      hotspotInfo = HotspotInfo(ssid: ssid, key: key);
    }
    hotspotInfoStreamController.add(hotspotInfo);
  }
}

final directWifiManager = DirectWifiManager._privateConstructor();

