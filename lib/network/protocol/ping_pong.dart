
import 'package:anydrop/network/protocol/device_modal.dart';
import 'package:dart_mappable/dart_mappable.dart';

part 'ping_pong.mapper.dart';

/// 多播组中没有设备加入
/// A加入发送Ping
/// Ping在局域网中消失
/// B加入发送Ping
/// A接收到B的Ping, 并记录B设备，向B发送Pong
/// B收到A的Pong, 记录A设备
/// C加入发送Ping
/// A接收到C的Ping, 并记录C设备，向C发送Pong
/// B接收到C的Ping, 并记录C设备，向C发送Pong
/// B收到A向C发送的Pong, 直接忽略
/// A收到B向C发送的Pong, 直接忽略
/// C收到A的Pong, 记录A设备
/// C收到B的Pong, 记录B设备

@MappableClass()
class Ping with  PingMappable {
  final DeviceModal deviceModal;

  Ping(this.deviceModal);

  static const fromJson =  PingMapper.fromJson;
}

@MappableClass()
class Pong with PongMappable {
  final DeviceModal from;
  final DeviceModal to;

  Pong(this.from, this.to);

  static const fromJson =  PongMapper.fromJson;
}