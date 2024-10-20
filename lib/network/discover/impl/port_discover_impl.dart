import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:dart_ping_ios/dart_ping_ios.dart';
import 'package:drift/drift.dart';
import 'package:flix/domain/device/device_manager.dart';
import 'package:flix/domain/device/device_profile_repo.dart';
import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/domain/ship_server/processor/ping_v2_processor.dart';
import 'package:flix/domain/ship_server/ship_service_proxy.dart';
import 'package:flix/network/discover/discover_api.dart';
import 'package:flix/network/discover/discover_param.dart';
import 'package:flix/network/protocol/device_modal.dart';
import 'package:flix/utils/net/net_utils.dart';
import 'package:lan_scanner/lan_scanner.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quiver/testing/time.dart';

class PortDiscoverImpl extends DiscoverApi {
  bool isScanning = false;
  static const int threadCount = 6;
  var curCount = threadCount;
  static const String tag = "PortDiscoverImpl";
  final scanner = LanScanner();
  int startTime = 0;

  @override
  String getFrom() {
    return DeviceFrom.port;
  }

  @override
  Future<void> startScan(DiscoverParam param) async {
    var networkInterfaces = await getAvailableNetworkInterfaces();
    //扫描优先级，如果第一个没有扫描到，就是用后面的
    if (networkInterfaces.isEmpty) {
      talker.debug(tag, "startScan failed from = ${getFrom()}");
      return;
    }
    if (isScanning) {
      talker.debug(tag, "startScan  failed is Scanning = ${getFrom()}");
      return;
    }
    resetData();
    var subnet = ipToCSubnet(networkInterfaces[0].address);
    DeviceModal deviceModel = await DeviceProfileRepo.instance
        .getDeviceModal(await shipService.getPort());
    int multiThread = threadCount - 1;
    for (int i = 0; i < multiThread; i++) {
      scanRange(subnet, i * 50 + 1, (i + 1) * 50, param, deviceModel)
          .then((deviceList) {
        triggerResult(param, deviceList);
      });
    }
    scanRange(subnet, 251, 255, param, deviceModel).then((deviceList) {
      triggerResult(param, deviceList);
    });
    // var hostList = [];
    // scanner.icmpScan(subnet, timeout: const Duration(milliseconds: 40),
    //     progressCallback: (progress) {
    //   talker.debug(tag, "progress = $progress");
    // }).listen((host) {
    //   talker.debug(tag, "port ip = ${host.internetAddress.address}");
    //   hostList.add(host.internetAddress.address);
    //   param.onData?.call(host.internetAddress.address, getFrom());
    // }, onDone: () {
    //   param.onDone?.call(getFrom());
    //   talker.debug(tag, "startScan done");
    // }, onError: (error) {
    //   param.onError?.call(getFrom(), 0, error);
    //   talker.debug(tag, "startScan error message = $error");
    // });
  }

  void resetData() {
    startTime = DateTime.now().millisecondsSinceEpoch;
    curCount = threadCount;
    isScanning = true;
  }

  void triggerResult(DiscoverParam params, List<DeviceModal> deviceList) {
    for (var device in deviceList) {
      DeviceManager.instance.addDevice(device);
    }
    --curCount;
    talker.debug(tag, "curCount = $curCount");
    if (curCount == 0) {
      isScanning = false;
      talker.debug(tag, "cost time = ${DateTime.now().millisecondsSinceEpoch - startTime}");
      params.onDone?.call(getFrom());
    }
  }

  Future<List<DeviceModal>> scanRange(
      String subnet, int start, int end, param, DeviceModal deviceModal) async {
    return await Isolate.run(
        () => _scanRange(subnet, start, end, param, deviceModal),
        debugName: "scan_rang_thread_start$start _end= $end");
  }

  Future<List<DeviceModal>> _scanRange(
      String subnet, int start, int end, param, DeviceModal deviceModal) async {
    List<DeviceModal> deviceList = [];
    for (int i = start; i <= end; i++) {
      var ip = "$subnet.$i";
      talker.debug(tag, "ip = $ip");
      try {
        var pingResult =
            await PingV2Processor.pingV2(ip, param.port, deviceModal);
        if (pingResult != null) {
          deviceList.add(pingResult);
        }
        talker.debug('pingResult = $pingResult');
      } catch (e, stack) {
        talker.debug(tag, "ping failed e = $e");
      }
    }
    return deviceList;
  }

  @override
  Future<void> initConfig() async {
    if (Platform.isIOS) {
      DartPingIOS.register();
    }
  }

  @override
  void stop() {}
}
