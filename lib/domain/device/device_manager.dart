import 'dart:async';

import 'package:flix/domain/database/database.dart';
import 'package:flix/domain/device/ap_interface.dart';
import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/model/device_info.dart';
import 'package:flix/utils/device/device_utils.dart';
import 'package:flix/utils/device_info_helper.dart' as deviceUtils;
import 'package:flix/utils/iterable_extension.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../network/multicast_client_provider.dart';
import '../../network/multicast_impl.dart';
import '../../network/multicast_util.dart';
import '../../network/protocol/device_modal.dart';

class DeviceManager {
  static const deviceNameKey = 'device_name_key';

  DeviceManager._privateConstructor() {}

  static final DeviceManager _instance = DeviceManager._privateConstructor();

  static DeviceManager get instance {
    return _instance;
  }

  late ApInterface apInterface;

  /// 当前设备的id
  late String did;

  String deviceName = '';
  final deviceNameBroadcast = StreamController<String>.broadcast();

  final deviceList = <DeviceModal>{};
  final history = <DeviceModal>{};
  final _netAddress2DeviceInfo = <String, DeviceInfo>{};
  final _deviceId2NetAddress = <String, String>{};

  final multiCastApi = MultiCastImpl();
  var state = MultiState.idle;

  final deviceListChangeListeners = <OnDeviceListChanged>{};
  final historyChangeListeners = <OnDeviceListChanged>{};

  Future<void> init(ApInterface apInterface) async {
    this.apInterface = apInterface;
    await _initDeviceInfo();
    _watchHistory();
    this.apInterface.listenPong((pong) {
      _onDeviceDiscover(pong.from);
    });
    startScan();
  }

  Future<void> _initDeviceInfo() async {
    var sharePreference = await SharedPreferences.getInstance();
    var deviceKey = "device_key";
    var saveDid = sharePreference.getString(deviceKey);
    if (saveDid == null || saveDid.isEmpty) {
      saveDid = const Uuid().v4();
      sharePreference.setString(deviceKey, saveDid);
    }
    did = saveDid;

    final deviceInfo = await deviceUtils.getDeviceInfo();
    var savedDeviceName = sharePreference.getString(deviceNameKey);
    if (savedDeviceName == null || savedDeviceName.isEmpty) {
      savedDeviceName = deviceInfo.alias ?? deviceInfo.deviceModel ?? '';
      sharePreference.setString(deviceNameKey, savedDeviceName);
    }

    deviceName = savedDeviceName;
  }

  Future<bool> renameDevice(String name) async {
    final sp = await SharedPreferences.getInstance();
    final result = await sp.setString(deviceNameKey, name);
    if (result) {
      deviceName = name;
      deviceNameBroadcast.add(name);
    }
    return result;
  }

  Future<deviceUtils.DeviceInfoResult> getDeviceInfo() async {
    final deviceInfo = await deviceUtils.getDeviceInfo();
    return deviceUtils.DeviceInfoResult(
        alias: deviceName,
        deviceType: deviceInfo.deviceType,
        deviceModel: deviceInfo.deviceModel,
        androidSdkInt: deviceInfo.androidSdkInt);
  }

  Future<void> startScan() async {
    state = MultiState.idle;
    await multiCastApi.startScan(
        MultiCastUtil.defaultMulticastGroup, MultiCastUtil.defaultPort,
        (deviceModal, needPong) {
      if (needPong) {
        multiCastApi.pong(deviceModal);
        multiCastApi
            .getDeviceModal()
            .then((value) => apInterface.pong(value, deviceModal));
      }
      _onDeviceDiscover(deviceModal);
    });
    unawaited(multiCastApi.ping());
  }


  Future<void> ping() async {
    await multiCastApi.ping();
  }

  void _onDeviceDiscover(DeviceModal deviceModal) {
    bool isConnect = isDeviceConnected(deviceModal);
    if (!isConnect) {
      _addDevice(deviceModal);
    } else {
      bool isChanged = isDeviceInfoChanged(deviceModal);
      if (isChanged) {
        deviceList.removeWhere((element) => element.fingerprint == deviceModal.fingerprint);
        _addDevice(deviceModal);
      }
    }
    notifyDeviceListChanged();
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

  bool isDeviceInfoChanged(DeviceModal event) {
    var isChanged = false;
    for (var element in deviceList) {
      if (element.fingerprint == event.fingerprint) {
        if (element.ip != event.ip || element.port != event.port || element.alias != event.alias || element.deviceModel != event.deviceModel || element.deviceType != event.deviceType) {
          isChanged = true;
        }
      }
    }
    return isChanged;
  }

  void notifyDeviceListChanged() {
    for (var element in deviceListChangeListeners) {
      element(deviceList);
    }
  }

  void notifyHistoryChanged() {
    for (var element in historyChangeListeners) {
      element(history);
    }
  }

  void addDeviceListChangeListener(OnDeviceListChanged onDeviceListChanged) {
    onDeviceListChanged(deviceList);
    deviceListChangeListeners.add(onDeviceListChanged);
  }

  void removeDeviceListChangeListener(OnDeviceListChanged onDeviceListChanged) {
    deviceListChangeListeners.remove(onDeviceListChanged);
  }

  void addHistoryChangeListener(OnDeviceListChanged onDeviceListChanged) {
    onDeviceListChanged(history);
    historyChangeListeners.add(onDeviceListChanged);
  }

  void removeHistoryChangeListener(OnDeviceListChanged onDeviceListChanged) {
    historyChangeListeners.remove(onDeviceListChanged);
  }

  void _addDevice(DeviceModal device) {
    deviceList.add(device);
    _netAddress2DeviceInfo[toNetAddress(device.ip, device.port)] =
        device.toDeviceInfo();
    _deviceId2NetAddress[device.fingerprint] =
        toNetAddress(device.ip, device.port);
    appDatabase.devicesDao.insertDevice(device);
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

  void _watchHistory() {
    appDatabase.devicesDao.watchDevices().listen((event) {
      history.clear();
      // 在前端去重，当在线设备变化时，可以再次去重
      // event.removeWhere((element) => deviceList.contains(element));
      history.addAll(event);
      notifyHistoryChanged();
    });
  }
}

typedef OnDeviceListChanged = void Function(Set<DeviceModal>);
