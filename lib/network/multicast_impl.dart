import 'dart:async';

import 'package:flix/domain/device/device_manager.dart';
import 'package:flix/network/multicast_api.dart';
import 'package:flix/network/multicast_util.dart';
import 'package:flix/network/protocol/device_modal.dart';

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
  Future<void> stop() async {}

  @override
  Future<void> ping() async {
    await MultiCastUtil.ping(await DeviceManager.instance.getDeviceModal());
  }

  @override
  Future<void> pong(DeviceModal to) async {
    await MultiCastUtil.pong(await DeviceManager.instance.getDeviceModal(), to);
  }

  // @override
  // Future<DeviceModal> getDeviceModal() async {
  //   return await MultiCastUtil.getDeviceModal();
  // }
}
