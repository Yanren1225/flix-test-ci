import 'dart:async';
import 'dart:io';

import 'package:flix/domain/device/ap_interface.dart';
import 'package:flix/domain/device/device_profile_repo.dart';
import 'package:flix/domain/ship_server/ship_service.dart';
import 'package:flix/domain/ship_server/ship_service_proxy.dart';
import 'package:flix/network/multicast_api.dart';
import 'package:flix/network/multicast_impl.dart';
import 'package:flix/network/protocol/device_modal.dart';
import 'package:flix/utils/net/net_utils.dart';

class HttpDiscover implements MultiCastApi {
  final DeviceProfileRepo deviceProfileRepo;
  final ApInterface? apInterface;
  final ShipServiceProxy shipService;
  final List<int> ports;

  HttpDiscover(
      {required this.deviceProfileRepo,
      required this.apInterface,
      required this.shipService,
      required this.ports});

  @override
  Future<void> ping(int port) async {}

  @override
  Future<void> pong(int port, DeviceModal to) async {}

  @override
  Future<void> startScan(DeviceScanCallback deviceScanCallback) async {
    final deviceModel = await deviceProfileRepo.getDeviceModal(await shipService.getPort());
    final interfaces = await getAvailableNetworkInterfaces();
    var concurrency = 50;
    var runningCount = 0;

    for (final interface in interfaces) {
      final ip = interface.address;
      if (ip == null) continue;
      final ipList = List.generate(
          256, (i) => '${ip.split('.').take(3).join('.')}.$i')
          .where((item) => item != ip)
          .toList();

      for (final ip in ipList) {
        for (final port in ports) {
          while (runningCount >= concurrency) {
            await Future.delayed(const Duration(milliseconds: 20));
          }
          unawaited(() async {
            runningCount++;
            await apInterface?.ping(ip, port, deviceModel);
            runningCount--;
          }());
        }
      }
    }


  }

  @override
  Future<void> stop() async {

  }
}
