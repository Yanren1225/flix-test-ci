import 'dart:async';

import 'package:androp/model/device_info.dart';
import 'package:androp/utils/device/device_utils.dart';
import 'package:androp/utils/iterable_extension.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../network/multicast_client_provider.dart';
import '../../network/multicast_impl.dart';
import '../../network/multicast_util.dart';
import '../../network/protocol/device_modal.dart';
import '../../utils/logger.dart';

class DeviceManager {
  DeviceManager._privateConstructor() {
    _initDeviceId().then((value) => did = value);
  }

  static final DeviceManager _instance = DeviceManager._privateConstructor();

  static DeviceManager get instance {
    return _instance;
  }

  /// 当前设备的id
  late String did;

  final deviceList = <DeviceModal>{};
  final _netAddress2DeviceInfo = <String, DeviceInfo>{};
  final _deviceId2NetAddress = <String, String>{};

  final multiCastApi = MultiCastImpl();
  var state = MultiState.idle;

  final deviceListChangeListeners = <OnDeviceListChanged>{};

  Future<String> _initDeviceId() async {
    var sharePreference = await SharedPreferences.getInstance();
    var deviceKey = "device_key";
    var saveDid = sharePreference.getString(deviceKey);
    if (saveDid == null || saveDid.isEmpty) {
      saveDid = const Uuid().v4();
      sharePreference.setString(deviceKey, saveDid);
    }
    return saveDid;
  }

  Future<void> startScan() async {
    multiCastApi.sendAnnouncement();
    state = MultiState.idle;
    multiCastApi.startScan(
        MultiCastUtil.defaultMulticastGroup, MultiCastUtil.defaultPort,
        (event) {
      bool isConnect = isDeviceConnected(event);
      if (!isConnect) {
        _addDevice(event);
      }
      Logger.log("event data:$event  deviceList = $deviceList");
      notifyDeviceListChanged();
    });
  }

  void clearDevices() {
    deviceList.clear();
    _netAddress2DeviceInfo.clear();
    _deviceId2NetAddress.clear();
    notifyDeviceListChanged();
  }

  bool isDeviceConnected(DeviceModal event) {
    var isConnect = false;
    for (var element in deviceList) {
      if (element.fingerprint == event.fingerprint) {
        isConnect = true;
      }
    }
    return isConnect;
  }

  void notifyDeviceListChanged() {
    for (var element in deviceListChangeListeners) {
      element(deviceList);
    }
  }

  void addDeviceListChangeListener(OnDeviceListChanged onDeviceListChanged) {
    onDeviceListChanged(deviceList);
    deviceListChangeListeners.add(onDeviceListChanged);
  }

  void removeDeviceListChangeListener(OnDeviceListChanged onDeviceListChanged) {
    deviceListChangeListeners.remove(onDeviceListChanged);
  }

  void _addDevice(DeviceModal device) {
    deviceList.add(device);
    _netAddress2DeviceInfo[toNetAddress(device.ip, device.port)] =
        device.toDeviceInfo();
    _deviceId2NetAddress[device.fingerprint] =
        toNetAddress(device.ip, device.port);
    notifyDeviceListChanged();
  }

  DeviceInfo? getDeviceInfoByNetAddress(String ip, int? port) {
    return _netAddress2DeviceInfo[toNetAddress(ip, port)];
  }

  DeviceInfo? getDeviceInfoById(String id) {
    return deviceList
        .find((element) => element.fingerprint == id)
        ?.toDeviceInfo();
  }

  String? getNetAdressByDeviceId(String id) {
    return _deviceId2NetAddress[id];
  }

  String toNetAddress(String ip, int? port) {
    return '$ip:${port ?? MultiCastUtil.defaultPort}';
  }
}

typedef OnDeviceListChanged = void Function(Set<DeviceModal>);
