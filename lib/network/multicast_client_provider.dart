import 'package:androp/domain/device/device_manager.dart';
import 'package:androp/network/multicast_impl.dart';
import 'package:androp/network/multicast_util.dart';
import 'package:androp/network/protocol/device_modal.dart';
import 'package:androp/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum MultiState { idle, scanning, connect, failure }

class MultiCastClientProvider extends ChangeNotifier {
  Set<DeviceModal> get deviceList => DeviceManager.instance.deviceList;

  static MultiCastClientProvider of(BuildContext context,
      {bool listen = false}) {
    return Provider.of<MultiCastClientProvider>(context, listen: listen);
  }

  MultiCastClientProvider() {
    DeviceManager.instance.addDeviceListChangeListener(_onDeviceListChanged);
  }

  void _onDeviceListChanged(Set<DeviceModal> deviceList) {
    notifyListeners();
  }

  @override
  void dispose() {
    DeviceManager.instance.removeDeviceListChangeListener(_onDeviceListChanged);
    super.dispose();
  }

  Future<void> startScan() async {
    DeviceManager.instance.startScan();
  }

  void clearDevices() {
    DeviceManager.instance.clearDevices();
  }

  bool isDeviceConnected(DeviceModal event) {
    return DeviceManager.instance.isDeviceConnected(event);
  }
}
