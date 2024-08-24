import 'package:flix/network/discover/discover_api.dart';
import 'package:flix/network/discover/discover_param.dart';
import 'package:flix/network/discover/helper/multi_discover_helper.dart';

class MultiDiscoverImpl extends DiscoverApi {
  static const String tag = "MultiDiscoverImpl";

  @override
  String getFrom() {
    return "multi";
  }

  @override
  Future<void> startScan(DiscoverParam param) async {
    await MultiDiscoverHelper.startScan(param);
  }

  @override
  void initConfig() {}

  @override
  Future<void> stop() async {
    // talker.debug(tag,"=====stop====");
    // await MultiDiscoverHelper.releaseMulticastLock();
    // var aliveSockets = MultiDiscoverHelper.getAliveSockets();
    // for (var socket in aliveSockets) {
    //   try {
    //     socket.socket.close();
    //   } catch (e, stack) {
    //     talker.debug(tag, "close socket error = $e  stack = $stack");
    //   }
    // }
    // aliveSockets.clear();
  }
}
