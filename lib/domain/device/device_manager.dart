import 'package:flix/domain/database/database.dart';
import 'package:flix/domain/device/device_discover.dart';
import 'package:flix/domain/device/device_profile_repo.dart';
import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/model/device_info.dart';
import 'package:flix/utils/device/device_utils.dart';
import 'package:flix/utils/iterable_extension.dart';

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

  final deviceListChangeListeners = <OnDeviceListChanged>{};
  final historyChangeListeners = <OnDeviceListChanged>{};

  void init() {
    _watchHistory();
    _watchLiveDevices();
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

  String? getNetAdressByDeviceId(String id) {
    return deviceDiscover.getNetAdressByDeviceId(id);
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
    appDatabase.devicesDao.watchDevices().listen((history) async {
      history.clear();
      talker.debug("_watchHistory start");
      // 在前端去重，当在线设备变化时，可以再次去重
      // event.removeWhere((element) => deviceList.contains(element));
      for (int i = history.length - 1; i >= 0; i--) {
        var element = history[i];
        var bubbleCount = await appDatabase.bubblesDao
            .queryDeviceBubbleCount(element.fingerprint);
        if (bubbleCount == 0) {
          history.remove(element);
        }
      }
      history.addAll(history);
      notifyHistoryChanged();
    });
  }

  Future<void> deleteHistory(String deviceId) async {
    talker.debug("deleteHistory = $deviceId");
    await appDatabase.bubblesDao.deleteBubblesByDeviceId(deviceId);
    await appDatabase.devicesDao.deleteDevice(deviceId);
  }
}
