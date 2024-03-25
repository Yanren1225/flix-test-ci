import 'dart:async';
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flix/domain/device/device_manager.dart';
import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/network/multicast_impl.dart';
import 'package:flix/network/multicast_util.dart';
import 'package:flix/network/protocol/device_modal.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum MultiState { idle, scanning, connect, failure }

class MultiCastClientProvider extends ChangeNotifier {
  Set<DeviceModal> get deviceList => DeviceManager.instance.deviceList;

  Set<DeviceModal> get history => DeviceManager.instance.history
      .where((e) => !deviceList.contains(e))
      .toSet();
  StreamSubscription? connectivitySubscription;

  String? _selectedDeviceId = null;

  String? get selectedDeviceId => _selectedDeviceId;

  var deviceName = DeviceManager.instance.deviceName;

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
      startScan();
    });
    DeviceManager.instance.deviceNameBroadcast.stream.listen((event) {
      if (deviceName != event) {
        deviceName = event;
        DeviceManager.instance.ping();
      }
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
    DeviceManager.instance.startScan();
  }

  void clearDevices() {
    DeviceManager.instance.clearDevices();
  }


  void setSelectedDeviceId(String id) {
    _selectedDeviceId = id;
    notifyListeners();
  }
}
