import 'dart:async';
import 'dart:convert';

import 'package:androp/network/multicast_api.dart';
import 'package:androp/network/multicast_util.dart';
import 'package:androp/network/protocol/device_modal.dart';
import 'package:androp/utils/logger.dart';

typedef DeviceScanCallback = void Function(DeviceModal deviceModal);

class MultiCastImpl extends MultiCastApi {
  var _listening = false;

  @override
  void startScan(String multiGroup, int port,
      DeviceScanCallback deviceScanCallback) async {
    if (_listening) {
      Logger.log('Already listening to multicast');
      return;
    }
    _listening = true;
    final sockets = await MultiCastUtil.getSockets(multiGroup, port);
    for (final socket in sockets) {
      socket.socket.listen((_) {
        final datagram = socket.socket.receive();
        if (datagram == null) {
          return;
        }
        var data = jsonDecode(utf8.decode(datagram.data));
        Logger.log('receive data:$data');
        final deviceModal = DeviceModal.fromJson(data);
        final ip = datagram.address.address;
        deviceModal.ip = ip;
        deviceScanCallback(deviceModal);
      });
    }
  }

  @override
  void disconnect() {}

  @override
  Future<void> sendAnnouncement() async {
    await MultiCastUtil.sendAnnouncement();
  }
}
