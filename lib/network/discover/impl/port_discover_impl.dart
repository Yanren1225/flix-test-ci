import 'dart:async';

import 'package:dart_ping_ios/dart_ping_ios.dart';
import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/network/discover/discover_api.dart';
import 'package:flix/network/discover/discover_param.dart';
import 'package:flix/utils/net/net_utils.dart';
import 'package:lan_scanner/lan_scanner.dart';
import 'package:path_provider/path_provider.dart';

class PortDiscoverImpl extends DiscoverApi {
  bool isScanning = false;
  static const String tag = "PortDiscoverImpl";
  final scanner = LanScanner();

  @override
  String getFrom() {
    return "port";
  }

  @override
  Future<void> startScan(DiscoverParam param) async {
    var networkInterfaces = await getAvailableNetworkInterfaces();
    //扫描优先级，如果第一个没有扫描到，就是用后面的
    if (networkInterfaces.isEmpty) {
      talker.debug(tag, "startScan failed from = ${getFrom()}");
      return;
    }
    var subnet = ipToCSubnet(networkInterfaces[0].address);
    var hostList = [];
    scanner.icmpScan(subnet, timeout: const Duration(milliseconds: 40),
        progressCallback: (progress) {
      talker.debug(tag, "progress = $progress");
    }).listen((host) {
      talker.debug(tag, "port ip = ${host.internetAddress.address}");
      hostList.add(host.internetAddress.address);
      param.onData?.call(host.internetAddress.address, getFrom());
    }, onDone: () {
      param.onDone?.call(getFrom());
      talker.debug(tag, "startScan done");
    }, onError: (error) {
      param.onError?.call(getFrom(), 0, error);
      talker.debug(tag, "startScan error message = $error");
    });
  }

  @override
  Future<void> initConfig() async {
    DartPingIOS.register();
  }

  @override
  void stop() {}
}
