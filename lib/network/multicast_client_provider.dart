import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flix/domain/device/device_discover.dart';
import 'package:flix/domain/device/device_manager.dart';
import 'package:flix/domain/device/device_profile_repo.dart';
import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/domain/ship_server/ship_service_proxy.dart';
import 'package:flix/network/protocol/device_modal.dart';
import 'package:flix/utils/iterable_extension.dart';
import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

enum MultiState { idle, scanning, connect, failure }

class MultiCastClientProvider extends ChangeNotifier {
  Set<DeviceModal> get deviceList => DeviceManager.instance.deviceList;

  Set<DeviceModal> get history => DeviceManager.instance.history
      .where((e) => deviceList.find((d) => d.fingerprint == e.fingerprint) == null)
      .toSet();
  StreamSubscription? connectivitySubscription;

  String? _selectedDeviceId = null;

  String? get selectedDeviceId => _selectedDeviceId;

  var deviceName = DeviceProfileRepo.instance.deviceName;
  StreamController<String> get deviceNameStream =>  DeviceProfileRepo.instance.deviceNameBroadcast;

  final info = NetworkInfo();

  var wifiName = "";
  StreamController<String> wifiNameStream = StreamController<String>.broadcast();

  var connectivityResult = ConnectivityResult.none;
  StreamController<ConnectivityResult> connectivityResultStream = StreamController<ConnectivityResult>.broadcast();

  static MultiCastClientProvider of(BuildContext context,
      {bool listen = false}) {
    return Provider.of<MultiCastClientProvider>(context, listen: listen);
  }

  MultiCastClientProvider() {
    DeviceManager.instance.addDeviceListChangeListener(_onDeviceListChanged);
    DeviceManager.instance.addHistoryChangeListener(_onHistoryListChanged);
    connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((result) {
      talker.debug('connectivity changed: $result');
      if (result == ConnectivityResult.wifi) {
        getWifiName();
      }
      _setConnectivityResult(result);
      shipService.isServerLiving().then((isServerLiving) async {
        talker.debug('isServerLiving: $isServerLiving');
        if (isServerLiving) {
          startScan();
        } else {
          if (await shipService.restartShipServer()) {
            startScan();
          } else {
            talker.error('restartShipServer failed');
          }
        }
      }).catchError((error, stackTrace) =>
          talker.error('isServerLiving error', error, stackTrace));
    });
    DeviceProfileRepo.instance.deviceNameBroadcast.stream.listen((event) async {
      if (deviceName != event) {
        deviceName = event;
        DeviceDiscover.instance.ping(await shipService.getPort());
      }
    });
  }

  void getWifiName() {
    info.getWifiName().then((_name) {
      var name = _name ?? "";
      if (Platform.isAndroid) {
        if (name[0] == "\"" && name[name.length - 1] == "\"") {
          name = name.substring(1, name.length - 1);
        }
      }
      _setWifiName(name);
    }).onError((error, stackTrace) {
      talker.error('getWifiName error', error, stackTrace);
    });
  }

  void _onDeviceListChanged(Set<DeviceModal> deviceList) {
    notifyListeners();
  }

  void _onHistoryListChanged(Set<DeviceModal> history) {
    notifyListeners();
  }

  @override
  void dispose() {
    connectivitySubscription?.cancel();
    DeviceManager.instance.removeDeviceListChangeListener(_onDeviceListChanged);
    DeviceManager.instance.removeHistoryChangeListener(_onHistoryListChanged);
    super.dispose();
  }

  Future<void> startScan() async {
    DeviceDiscover.instance.startScan(await shipService.getPort());
  }

  void clearDevices() {
    DeviceManager.instance.clearDevices();
  }

  void setSelectedDeviceId(String id) {
    _selectedDeviceId = id;
    notifyListeners();
  }

  Future<void> deleteHistory(String deviceId) async {
    await DeviceManager.instance.deleteHistory(deviceId);
  }

  void _setWifiName(String? name) {
    if (name != null && name.isNotEmpty && wifiName != name) {
      wifiName = name;
      wifiNameStream.add(name);
    }

  }

  void _setConnectivityResult(ConnectivityResult result) {
    if (connectivityResult != result) {
      connectivityResult = result;
      connectivityResultStream.add(result);
    }

  }


}
