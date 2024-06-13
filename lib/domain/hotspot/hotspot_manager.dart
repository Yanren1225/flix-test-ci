import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flix/domain/lifecycle/AppLifecycle.dart';
import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/model/hotspot/hotspot_info.dart';
import 'package:flutter_p2p_connection/flutter_p2p_connection.dart';

class HotspotManager implements LifecycleListener {
  final _flutterP2pConnectionPlugin = FlutterP2pConnection();
  Completer<bool?> _initCompleter = Completer();
  HotspotInfo? hotspotInfo = null;
  StreamController<HotspotInfo?> hotspotInfoStreamController = StreamController.broadcast();

  HotspotManager._privateConstructor() {
    if (Platform.isAndroid) {
      _init();
    }
  }

  Future<bool> enableHotspot() async {
    try {
      await _initCompleter.future;
      return await _flutterP2pConnectionPlugin.createGroup();
    } catch (e, s) {
      talker.error('enableHotspot failed', e, s);
      return false;
    }
  }

  Future<bool> disableHotspot() async {
    try {
      await _initCompleter.future;
      return await _flutterP2pConnectionPlugin.removeGroup();
    } catch (e, s) {
      talker.error('disableHotspot failed', e, s);
      return false;
    }
  }


  Future<HotspotInfo?> getHotspotInfo() async {
    HotspotInfo? info = await _getHotspotInfo();
    if (info == null) {
      await Future.delayed(const Duration(seconds: 1));
      info = await _getHotspotInfo();
    }
    if (info != hotspotInfo) {
      hotspotInfo = info;
      hotspotInfoStreamController.add(info);
    }
    return info;
  }


  Future<HotspotInfo?> _getHotspotInfo() async {
    try {
      await _initCompleter.future;
      WifiP2PGroupInfo? info = await _flutterP2pConnectionPlugin.groupInfo();
      if (info != null) {
        return HotspotInfo(ssid: info.groupNetworkName, key: info.passPhrase ?? "");
      } else {
        return null;
      }
    } catch (e, s) {
      talker.error('getHotspotInfo failed', e, s);
      return null;
    }
  }

  void _init() async {
    try {
      bool? initialized = await _flutterP2pConnectionPlugin.initialize();
      _initCompleter.complete(initialized == true);
    } catch (e, s) {
      talker.error('init failed', e, s);
      _initCompleter.completeError(e, s);
    }
  }

  @override
  void onLifecycleChanged(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _getHotspotInfo();
    }
  }

}

final hotspotManager = HotspotManager._privateConstructor();

