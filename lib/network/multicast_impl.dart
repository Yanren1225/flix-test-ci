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
  final String multicastGroup;
  final int multicastPort;

  MultiCastImpl({required this.deviceProfileRepo, required this.multicastGroup, required this.multicastPort});


  @override
  Future<void> startScan(DeviceScanCallback deviceScanCallback) async {
      await MultiCastUtil.startScan(multicastGroup, multicastPort, deviceScanCallback);
  }

  @override
  Future<void> stop() async {}

  @override
  Future<void> ping(int port) async {
    await MultiCastUtil.ping(multicastGroup, multicastPort, await deviceProfileRepo.getDeviceModal(port));
  }

  @override
  Future<void> pong(int port, DeviceModal to) async {
    await MultiCastUtil.pong(multicastGroup, multicastPort, await deviceProfileRepo.getDeviceModal(port), to);
  }
}
