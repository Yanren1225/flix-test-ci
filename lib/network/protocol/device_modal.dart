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

  DeviceModal({
    required this.alias,
    required this.deviceModel,
    required this.deviceType,
    required this.fingerprint,
    required this.port,
    required this.version,
    this.ip = '',
    this.host = ''
  });


  static const fromJson = DeviceModalMapper.fromJson;

  bool heartBeat() {
    return true;
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
