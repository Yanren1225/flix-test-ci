import 'package:flix/domain/database/database.dart';
import 'package:flix/domain/device/device_discover.dart';
import 'package:flix/domain/device/device_profile_repo.dart';
import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/model/database/device/pair_devices.dart';
import 'package:flix/model/device_info.dart';
import 'package:flix/utils/device/device_utils.dart';
import 'package:flix/utils/iterable_extension.dart';
import 'package:flix/utils/net/net_utils.dart';

import '../../network/protocol/device_modal.dart';

// DeviceProfileRepo DeviceDiscoverService DeviceManager
// DeviceManager depends on DeviceProfileRepo and DeviceDiscover + history devices
// DeviceDiscover depends on DeviceProfileRepo
class DeviceManager {
  DeviceManager._privateConstructor();

  static final DeviceManager _instance = DeviceManager._privateConstructor();

  static DeviceManager get instance {
    return _instance;
  }

  final deviceProfileRepo = DeviceProfileRepo.instance;
  final deviceDiscover = DeviceDiscover.instance;

  final deviceList = <DeviceModal>{};
  final history = <DeviceModal>{};
  final pairDevices = <PairDevice>{};
  final deviceListChangeListeners = <OnDeviceListChanged>{};
  final historyChangeListeners = <OnDeviceListChanged>{};
  final pairDeviceChangeListeners = <OnPairDeviceListChanged>{};

  void init() {
    _watchHistory();
    _watchLiveDevices();
    _watchPairDevices();
  }

  void _watchLiveDevices() {
    deviceDiscover.addDeviceListChangeListener((devices) {
      deviceList.clear();
      deviceList.addAll(devices);
      notifyDeviceListChanged();
    });
  }

  void clearDevices() {
    deviceDiscover.clearDevices();
    deviceList.clear();
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

  void notifyHistoryChanged() {
    for (var element in historyChangeListeners) {
      element(history);
    }
  }

  void notifyPairDeviceListChanged() {
    for (var element in pairDeviceChangeListeners) {
      element(pairDevices);
    }
  }

  void addDeviceListChangeListener(OnDeviceListChanged onDeviceListChanged) {
    onDeviceListChanged(deviceList);
    deviceListChangeListeners.add(onDeviceListChanged);
  }

  bool addDevice(DeviceModal device) {
    deviceList.add(device);
    notifyDeviceListChanged();
    return true;
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

  void addPairDeviceChangeListener(OnPairDeviceListChanged onPairDeviceListChanged){
    pairDeviceChangeListeners.add(onPairDeviceListChanged);
  }

  void removePairDeviceChangeListener(OnPairDeviceListChanged onPairDeviceListChanged){
    pairDeviceChangeListeners.remove(onPairDeviceListChanged);
  }

  String? getNetAdressByDeviceId(String id) {
    for (var device in DeviceManager.instance.deviceList) {
      if (device.fingerprint == id) {
        return toNetAddress(device.ip, device.port);
      }
    }
    return null;
  }

  DeviceInfo? getDeviceInfoById(String id) {
    return deviceList
        .find((element) => element.fingerprint == id)
        ?.toDeviceInfo();
  }

  DeviceModal? getDeviceModalById(String id) {
    return deviceList.find((element) => element.fingerprint == id);
  }

  void _watchHistory() {
    appDatabase.devicesDao.watchDevices().listen((watchHistory) async {
      history.clear();
      talker.debug("_watchHistory start");
      // 在前端去重，当在线设备变化时，可以再次去重
      // event.removeWhere((element) => deviceList.contains(element));
      for (int i = watchHistory.length - 1; i >= 0; i--) {
        var element = watchHistory[i];
        var bubbleCount = await appDatabase.bubblesDao
            .queryDeviceBubbleCount(element.fingerprint);
        if (bubbleCount == 0) {
          watchHistory.remove(element);
        }
      }
      history.addAll(watchHistory);
      notifyHistoryChanged();
    });
  }

  Future<void> _watchPairDevices() async {
    appDatabase.pairDevicesDao.watchDevices().listen((_pairDevices) async {
      talker.debug("_watchPairDevices start");
      // 在前端去重，当在线设备变化时，可以再次去重
      // event.removeWhere((element) => deviceList.contains(element));
      pairDevices.clear();
      pairDevices.addAll(_pairDevices);
      notifyPairDeviceListChanged();
    });
  }

  Future<void> deleteHistory(String deviceId) async {
    talker.debug("deleteHistory = $deviceId");
    await appDatabase.bubblesDao.deleteBubblesByDeviceId(deviceId);
    await appDatabase.devicesDao.deleteDevice(deviceId);
  }

  Future<List<PairDevice>> getAllPairDevice() async {
    return await appDatabase.pairDevicesDao.getAll();
  }

  Future<int> addPairDevice(String fingerPrint, String code) async {
    return await appDatabase.pairDevicesDao.insert(fingerPrint, code);
  }

  Future<void> deletePairDevice(String deviceId) async {
      return await appDatabase.pairDevicesDao.deletePairDevice(deviceId);
  }
}

typedef OnPairDeviceListChanged = void Function(Set<PairDevice>);
