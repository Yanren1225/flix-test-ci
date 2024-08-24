import 'dart:async';

import 'package:dart_ping_ios/dart_ping_ios.dart';
import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/network/discover/discover_api.dart';
import 'package:flix/network/discover/discover_param.dart';
import 'package:flix/utils/net/net_utils.dart';
import 'package:lan_scanner/lan_scanner.dart';
import 'package:path_provider/path_provider.dart';

class PortDiscoverImpl extends DiscoverApi {
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
      talker.debug("startScan failed from = ${getFrom()}");
      return;
    }
    for (var networkInter in networkInterfaces) {
      var subnet = ipToCSubnet(networkInter.address);
      var hostList = await scanner.quickIcmpScanAsync(subnet);
      talker.debug("hostList is $hostList");
      if (hostList.isNotEmpty) {
        for (var host in hostList) {
          talker.debug("port ip = ${host.internetAddress.address}");
          param.callback?.call(host.internetAddress.address, getFrom());
        }
        break;
      }
    }
  }

  @override
  Future<void> initConfig() async {
    DartPingIOS.register();
  }

  @override
  void stop() {}
}
