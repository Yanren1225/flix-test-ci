import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:androp/domain/device/device_manager.dart';
import 'package:androp/network/multicast_api.dart';
import 'package:androp/network/multicast_util.dart';
import 'package:androp/network/protocol/device_modal.dart';
import 'package:androp/network/protocol/ping_pong.dart';
import 'package:androp/utils/logger.dart';
import 'package:dart_mappable/dart_mappable.dart';

typedef DeviceScanCallback = void Function(DeviceModal deviceModal, bool needPong);

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
    await MultiCastUtil.aquireMulticastLock();
    final sockets = await MultiCastUtil.getSockets(multiGroup, port);
    for (final socket in sockets) {
      socket.socket.listen((_) {
        final datagram = socket.socket.receive();
        if (datagram == null) {
          return;
        }
        var data = jsonDecode(utf8.decode(datagram.data));
        Logger.log('receive data:$data');
        DeviceModal deviceModal;
        bool needPong = false;
        try {
          final ping = Ping.fromJson(data);
          deviceModal = ping.deviceModal;
          needPong = true;
        } on MapperException catch (e) {
          final pong = Pong.fromJson(data);
          if (pong.to.fingerprint == DeviceManager.instance.did) {
            deviceModal = pong.from;
            needPong == false;
          } else {
            return;
          }
        }
        // final deviceModal = DeviceModal.fromJson(data);
        final ip = datagram.address.address;
        deviceModal.ip = ip;
        deviceScanCallback(deviceModal, needPong);
      });
    }
  }

  @override
  void disconnect() {}

  @override
  Future<void> ping() async {
    await MultiCastUtil.ping();
  }

  @override
  Future<void> pong(DeviceModal to) async {
    await MultiCastUtil.pong(to);
  }

  @override
  Future<DeviceModal> getDeviceModal() async {
    return await MultiCastUtil.getDeviceModal();
  }
}
