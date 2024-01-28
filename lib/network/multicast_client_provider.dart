import 'package:androp/network/multicast_impl.dart';
import 'package:androp/network/multicast_util.dart';
import 'package:androp/network/protocol/device_modal.dart';
import 'package:androp/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum MultiState { idle, scanning, connect, failure }

class MultiCastClientProvider extends ChangeNotifier {
  var deviceList = <DeviceModal>{};
  var multiCastApi = MultiCastImpl();
  var state = MultiState.idle;

  static MultiCastClientProvider of(BuildContext context,
      {bool listen = false}) {
    return Provider.of<MultiCastClientProvider>(context, listen: listen);
  }

  Future<void> startScan() async {
    multiCastApi.sendAnnouncement();
    state = MultiState.idle;
    await multiCastApi
        .startScan(
            MultiCastUtil.defaultMulticastGroup, MultiCastUtil.defaultPort)
        .listen((event) {
      Logger.log(event.toString());
    }, onDone: () {
      Logger.log("done");
    });
    notifyListeners();
  }
}
