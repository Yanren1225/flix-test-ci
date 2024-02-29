import 'dart:async';

import 'package:anydrop/model/device_info.dart';
import 'package:anydrop/utils/device/device_utils.dart';
import 'package:anydrop/utils/iterable_extension.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../network/multicast_client_provider.dart';
import '../../network/multicast_impl.dart';
import '../../network/multicast_util.dart';
import '../../network/protocol/device_modal.dart';
import '../../utils/logger.dart';

class DeviceManager {
  DeviceManager._privateConstructor() {}

  static final DeviceManager _instance = DeviceManager._privateConstructor();

  static DeviceManager get instance {
    return _instance;
  }

  /// 当前设备的id
  late String did;

  late DeviceModal self;

  final deviceList = <DeviceModal>{};
  final _netAddress2DeviceInfo = <String, DeviceInfo>{};
  final _deviceId2NetAddress = <String, String>{};

  final multiCastApi = MultiCastImpl();
  var state = MultiState.idle;

  final deviceListChangeListeners = <OnDeviceListChanged>{};

  void init() {
    _initDeviceId().then((value) {
      did = value;
      startScan();
    });
  }

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
    state = MultiState.idle;
    multiCastApi.startScan(
        MultiCastUtil.defaultMulticastGroup, MultiCastUtil.defaultPort,
        (deviceModal, needPong) {
      if (needPong) {
        multiCastApi.pong(deviceModal);
      }
      bool isConnect = isDeviceConnected(deviceModal);
      if (!isConnect) {
        _addDevice(deviceModal);
      }
      Logger.log("event data:$deviceModal  deviceList = $deviceList");
      notifyDeviceListChanged();
    });
    unawaited(multiCastApi.ping());
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
