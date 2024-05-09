import 'dart:async';

import 'package:flix/domain/database/database.dart';
import 'package:flix/domain/device/ap_interface.dart';
import 'package:flix/domain/device/device_profile_repo.dart';
import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/domain/settings/SettingsRepo.dart';
import 'package:flix/network/bonjour_impl.dart';
import 'package:flix/network/multicast_impl.dart';
import 'package:flix/network/nearby_service_info.dart';
import 'package:flix/network/protocol/device_modal.dart';
import 'package:flix/presentation/widgets/flix_toast.dart';
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
  final _deviceId2Device = <String, DeviceModal>{};
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

  void _onDeviceDiscover(DeviceModal device) {
    final preDevice = _findDevice(device);
    if (preDevice == null) {
      _addDevice(device);
      notifyDeviceListChanged();
    } else {
      final int? port;
      String ip = "";
      String host = "";

      bool isChanged = false;
      if (device.ip.isNotEmpty &&
          device.ip != preDevice.ip) {
        ip = device.ip;
        isChanged = true;
      } else {
        ip = preDevice.ip;
      }

      if (device.host.isNotEmpty &&
          device.host != preDevice.host) {
        host = device.host;
        isChanged = true;
      } else {
        host = preDevice.host;
      }

      if (device.port != null && device.port != preDevice.port) {
        port = device.port;
        isChanged = true;
      } else {
        port = preDevice.port;
      }

      if (device.alias != preDevice.alias ||
          device.deviceModel != preDevice.deviceModel ||
          device.deviceType != preDevice.deviceType) {
        isChanged = true;
      }

      if (isChanged) {
        final newDevice = DeviceModal(
            alias: device.alias,
            deviceModel: device.deviceModel,
            deviceType: device.deviceType,
            fingerprint: device.fingerprint,
            port: port,
            ip: ip,
            host: host);
        deviceList.remove(preDevice);
        _addDevice(newDevice);
        notifyDeviceListChanged();
      }
    }
  }

  void clearDevices() {
    deviceList.clear();
    _deviceId2Device.clear();
    notifyDeviceListChanged();
  }

  bool isDeviceConnected(DeviceModal event) {
    return _findDevice(event) != null;
  }

  DeviceModal? _findDevice(DeviceModal deviceModal) {
    for (var element in deviceList) {
      if (element.fingerprint == deviceModal.fingerprint) {
        return element;
      }
    }
    return null;
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
    _deviceId2Device[device.fingerprint] = device;
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

  String? getNetAdressByDeviceId(String id) {
    final device = _deviceId2Device[id];
    if (device != null) {
      if (device.ip.isNotEmpty) {
        return toNetAddress(device.ip, device.port);
      } else if (device.host.isNotEmpty) {
        return toNetAddress(device.host, device.port);
      } else {
        return null;
      }
    } else {
      talker.warning('设备已离线');
      flixToast.alert('设备已离线');
    }
    return null;
  }
}

typedef OnDeviceListChanged = void Function(Set<DeviceModal>);
