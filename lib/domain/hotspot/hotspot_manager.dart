import 'package:flix/model/hotspot/HotspotInfo.dart';
import 'package:flutter_p2p_connection/flutter_p2p_connection.dart';

class HotspotManager {
  final _flutterP2pConnectionPlugin = FlutterP2pConnection();

  HotspotManager._privateConstructor();

  Future<bool> enableHotspot() async {
    return await _flutterP2pConnectionPlugin.createGroup() ?? false;
  }

  Future<bool> disableHotspot() async {
    return await _flutterP2pConnectionPlugin.removeGroup() ?? false;
  }


  Future<HotspotInfo?> getHotspotInfo() async {
    WifiP2PGroupInfo? info = await _flutterP2pConnectionPlugin.groupInfo();
    if (info != null) {
      return HotspotInfo(ssid: info.groupNetworkName, key: info.passPhrase);
    } else {
      return null;
    }
  }

}

final hotspotManager = HotspotManager._privateConstructor();

