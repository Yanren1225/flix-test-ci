import 'package:flix/domain/database/database.dart';
import 'package:flix/domain/device/device_discover.dart';
import 'package:flix/domain/device/device_profile_repo.dart';
import 'package:flix/model/device_info.dart';
import 'package:flix/network/bonjour_impl.dart';
import 'package:flix/utils/device/device_utils.dart';
import 'package:flix/utils/iterable_extension.dart';
import 'package:flix/utils/net/net_utils.dart';

import '../../network/multicast_impl.dart';
import '../../network/protocol/device_modal.dart';
// DeviceProfileRepo DeviceDiscoverService DeviceManager
// DeviceManager depends on DeviceProfileRepo and DeviceDiscover + history devices
// DeviceDiscover depends on DeviceProfileRepo
class DeviceManager {

  DeviceManager._privateConstructor() {}

  static final DeviceManager _instance = DeviceManager._privateConstructor();

  static DeviceManager get instance {
    return _instance;
  }

  final deviceProfileRepo = DeviceProfileRepo.instance;
  final deviceDiscover = DeviceDiscover.instance;

  final deviceList = <DeviceModal>{};
  final history = <DeviceModal>{};

  late MultiCastImpl multiCastApi = MultiCastImpl(deviceProfileRepo: deviceProfileRepo);
  late BonjourImpl bonjourApi = BonjourImpl(deviceProfileRepo: deviceProfileRepo);

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

  DeviceInfo? getDeviceInfoByNetAddress(String ip, int? port) {
    return deviceDiscover.getDeviceInfoByNetAddress(ip, port);
  }

  String? getNetAdressByDeviceId(String id) {
    return deviceDiscover.getNetAdressByDeviceId(id);
  }

  DeviceInfo? getDeviceInfoById(String id) {
    return deviceList
        .find((element) => element.fingerprint == id)
        ?.toDeviceInfo();
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

