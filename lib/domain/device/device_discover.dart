import 'dart:async';

import 'package:flix/domain/database/database.dart';
import 'package:flix/domain/device/ap_interface.dart';
import 'package:flix/domain/device/device_profile_repo.dart';
import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/domain/settings/SettingsRepo.dart';
import 'package:flix/model/device_info.dart';
import 'package:flix/network/bonjour_impl.dart';
import 'package:flix/network/multicast_impl.dart';
import 'package:flix/network/nearby_service_info.dart';
import 'package:flix/network/protocol/device_modal.dart';
import 'package:flix/utils/device/device_utils.dart';
import 'package:flix/utils/net/net_utils.dart';

class DeviceDiscover {
  DeviceDiscover._privateConstructor() {}

  static final DeviceDiscover _instance = DeviceDiscover._privateConstructor();

  static DeviceDiscover get instance {
    return _instance;
  }

  final deviceProfileRepo = DeviceProfileRepo.instance;
  final settingsRepo = SettingsRepo.instance;
  ApInterface? apInterface;

  final deviceList = <DeviceModal>{};
  final _netAddress2DeviceInfo = <String, DeviceInfo>{};
  final _deviceId2NetAddress = <String, String>{};
  final deviceListChangeListeners = <OnDeviceListChanged>{};

  late MultiCastImpl multiCastApi = MultiCastImpl(
      multicastGroup: defaultMulticastGroup,
      multicastPort: defaultMulticastPort,
      deviceProfileRepo: deviceProfileRepo);
  late BonjourImpl bonjourApi =
      BonjourImpl(deviceProfileRepo: deviceProfileRepo);

  Future<void> start(ApInterface apInterface, int port) async {
    this.apInterface = apInterface;
    this.apInterface?.listenPong((pong) {
      _onDeviceDiscover(pong.from);
    });
    SettingsRepo.instance.enableMdnsStream.stream.listen((enableMdns) async {
      if (enableMdns) {
        await startBonjourScanService(port);
      } else {
        await bonjourApi.forceStop();
        clearDevices();
        await startScan(port);
      }
    });
    startScan(port);
  }

  Future<void> startScan(port) async {
    await multiCastApi.startScan((deviceModal, needPong) {
      talker.debug('discover device: $deviceModal');
      if (needPong) {
        multiCastApi.pong(port, deviceModal);
        deviceProfileRepo
            .getDeviceModal(port)
            .then((value) => apInterface?.pong(value, deviceModal));
      }
      _onDeviceDiscover(deviceModal);
    });
    unawaited(multiCastApi.ping(port));

    if (await settingsRepo.getEnableMdnsAsync()) {
      await startBonjourScanService(port);
    }
  }

  Future<void> startBonjourScanService(int port) async {
    await bonjourApi.startScan((DeviceModal deviceModal, bool needPong) {
      _onDeviceDiscover(deviceModal);
    });
    unawaited(bonjourApi.ping(port));
  }

  Future<void> stop() async {
    multiCastApi.stop();
    // always stop bonjour service
    bonjourApi.stop();
  }

  Future<void> ping(int port) async {
    multiCastApi.ping(port);
    if (await SettingsRepo.instance.getEnableMdnsAsync()) {
      bonjourApi.ping(port);
    }
  }

  void _onDeviceDiscover(DeviceModal deviceModal) {
    bool isConnect = isDeviceConnected(deviceModal);
    if (!isConnect) {
      _addDevice(deviceModal);
    } else {
      bool isChanged = isDeviceInfoChanged(deviceModal);
      if (isChanged) {
        deviceList.removeWhere(
            (element) => element.fingerprint == deviceModal.fingerprint);
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
        if (element.ip != event.ip ||
            element.port != event.port ||
            element.alias != event.alias ||
            element.deviceModel != event.deviceModel ||
            element.deviceType != event.deviceType) {
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

  void _addDevice(DeviceModal device) {
    deviceList.add(device);
    _netAddress2DeviceInfo[toNetAddress(device.ip, device.port)] =
        device.toDeviceInfo();
    _deviceId2NetAddress[device.fingerprint] =
        toNetAddress(device.ip, device.port);
    appDatabase.devicesDao.insertDevice(device);
    notifyDeviceListChanged();
  }

  void addDeviceListChangeListener(OnDeviceListChanged onDeviceListChanged) {
    onDeviceListChanged(deviceList);
    deviceListChangeListeners.add(onDeviceListChanged);
  }

  void removeDeviceListChangeListener(OnDeviceListChanged onDeviceListChanged) {
    deviceListChangeListeners.remove(onDeviceListChanged);
  }

  DeviceInfo? getDeviceInfoByNetAddress(String ip, int? port) {
    return _netAddress2DeviceInfo[toNetAddress(ip, port)];
  }

  String? getNetAdressByDeviceId(String id) {
    return _deviceId2NetAddress[id];
  }
}

typedef OnDeviceListChanged = void Function(Set<DeviceModal>);
