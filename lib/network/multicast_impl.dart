import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flix/domain/device/device_manager.dart';
import 'package:flix/network/multicast_api.dart';
import 'package:flix/network/multicast_util.dart';
import 'package:flix/network/protocol/device_modal.dart';
import 'package:flix/network/protocol/ping_pong.dart';
import 'package:flix/utils/logger.dart';
import 'package:dart_mappable/dart_mappable.dart';

typedef DeviceScanCallback = void Function(DeviceModal deviceModal, bool needPong);

class MultiCastImpl extends MultiCastApi {
  // var _listening = false;
  // final List<SocketResult> _sockets = [];

  @override
  Future<void> startScan(String multiGroup, int port,
      DeviceScanCallback deviceScanCallback) async {
      await MultiCastUtil.startScan(multiGroup, port, deviceScanCallback);
  }

  @override
  void disconnect() {}

  @override
  Future<void> ping() async {
    await MultiCastUtil.ping();
  }

  @override
  Future<void> pong(DeviceModal to) async {
    await MultiCastUtil.pong(to);
  }

  @override
  Future<DeviceModal> getDeviceModal() async {
    return await MultiCastUtil.getDeviceModal();
  }
}
