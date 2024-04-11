import 'dart:async';

import 'package:flix/domain/device/device_profile_repo.dart';
import 'package:flix/network/multicast_api.dart';
import 'package:flix/network/multicast_util.dart';
import 'package:flix/network/protocol/device_modal.dart';

typedef DeviceScanCallback = void Function(DeviceModal deviceModal, bool needPong);

class MultiCastImpl extends MultiCastApi {
  // var _listening = false;
  // final List<SocketResult> _sockets = [];
  final DeviceProfileRepo deviceProfileRepo;

  MultiCastImpl({required this.deviceProfileRepo});


  @override
  Future<void> startScan(String multiGroup, int port,
      DeviceScanCallback deviceScanCallback) async {
      await MultiCastUtil.startScan(multiGroup, port, deviceScanCallback);
  }

  @override
  Future<void> stop() async {}

  @override
  Future<void> ping(int port) async {
    await MultiCastUtil.ping(await deviceProfileRepo.getDeviceModal(port));
  }

  @override
  Future<void> pong(int port, DeviceModal to) async {
    await MultiCastUtil.pong(await deviceProfileRepo.getDeviceModal(port), to);
  }

  // @override
  // Future<DeviceModal> getDeviceModal() async {
  //   return await MultiCastUtil.getDeviceModal();
  // }
}
