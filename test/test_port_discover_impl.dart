import 'package:flix/network/discover/discover_param.dart';
import 'package:flix/network/discover/impl/port_discover_impl.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("port_discover", () async {
    var discoverApi = PortDiscoverImpl();
    discoverApi.initConfig();
    var param = DiscoverParam.name((String ip, String from) {
      print('ip = $ip  from = $from');
    }, "port");
    await discoverApi.startScan(param);
  });
}
