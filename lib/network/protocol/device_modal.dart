import 'package:dart_mappable/dart_mappable.dart';
import 'package:flix/domain/device/device_manager.dart';
import 'package:flutter/material.dart';

part 'device_modal.mapper.dart';

@MappableClass()
class DeviceModal with DeviceModalMappable {
  final String alias;
  final String? deviceModel;
  final DeviceType? deviceType; // nullable since v2
  final String fingerprint;
  int? port;
  final int? version;
  String ip = "";
  String host = "";
  String from = "";

  DeviceModal(
      {required this.alias,
      required this.deviceModel,
      required this.deviceType,
      required this.fingerprint,
      required this.port,
      required this.version,
      this.ip = '',
      this.host = '',
      this.from = ''});

  static const fromJson = DeviceModalMapper.fromJson;

  bool heartBeat() {
    return true;
  }



  static DeviceModal getUpdateDeviceModal(DeviceModal device)  {
    final preDevice = DeviceManager.instance.findDevice(device);
    if (preDevice == null) {
      return device;
    } else {
      final int? port;
      String ip = "";
      String host = "";
      String from = "";
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

      if (device.from.isNotEmpty &&
          device.from != preDevice.from) {
        from = device.from;
        isChanged = true;
      } else {
        from = preDevice.from;
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
            version: device.version,
            port: port,
            ip: ip,
            host: host,
            from: from);
        return newDevice;
      }else{
        return preDevice;
      }
    }
  }

}

@MappableEnum(defaultValue: DeviceType.desktop)
enum DeviceType {
  mobile(Icons.smartphone),
  desktop(Icons.computer),
  web(Icons.language),
  headless(Icons.terminal),
  server(Icons.dns);

  const DeviceType(this.icon);

  final IconData icon;
}

class DeviceFrom {
  static const String port = "port";
  static const String multiBroadcast = "broadcast";
  static const String manual = "manual";
  static const String bonjour = "bonjour";
}
