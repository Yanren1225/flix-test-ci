import 'dart:async';
import 'dart:convert';

import 'package:androp/network/multicast_api.dart';
import 'package:androp/network/multicast_util.dart';
import 'package:androp/network/protocol/device_modal.dart';
import 'package:androp/utils/logger.dart';

class MultiCastImpl extends MultiCastApi {
  var _listening = false;

  @override
  Stream<DeviceModal> startScan(String multiGroup, [int? port]) async* {
    if (_listening) {
      Logger.log('Already listening to multicast');
      return;
    }
    _listening = true;
    final streamController = StreamController<DeviceModal>();
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
        streamController.add(deviceModal);
      });
    }
    yield* streamController.stream;
  }

  @override
  void disconnect() {}

  @override
  Future<void> sendAnnouncement() async {
    await MultiCastUtil.sendAnnouncement();
  }
}
