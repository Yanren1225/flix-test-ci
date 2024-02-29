import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:anydrop/domain/device/device_manager.dart';
import 'package:anydrop/network/multicast_api.dart';
import 'package:anydrop/network/multicast_util.dart';
import 'package:anydrop/network/protocol/device_modal.dart';
import 'package:anydrop/network/protocol/ping_pong.dart';
import 'package:anydrop/utils/logger.dart';
import 'package:dart_mappable/dart_mappable.dart';

typedef DeviceScanCallback = void Function(DeviceModal deviceModal, bool needPong);

class MultiCastImpl extends MultiCastApi {
  var _listening = false;
  final List<SocketResult> _sockets = [];

  @override
  void startScan(String multiGroup, int port,
      DeviceScanCallback deviceScanCallback) async {
    // if (_listening) {
    //   Logger.log('Already listening to multicast');
    //   return;
    // }
    // _listening = true;

    await MultiCastUtil.releaseMulticastLock();
    await MultiCastUtil.aquireMulticastLock();
    for (final socket in _sockets) {
      socket.socket.close();
    }
    _sockets.clear();
    final sockets = await MultiCastUtil.getSockets(multiGroup, port);
    _sockets.addAll(sockets);
    for (final socket in sockets) {
      socket.socket.listen((event) {
        switch (event) {
          case RawSocketEvent.read:
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
            break;
          case RawSocketEvent.write:
            Logger.log('===RawSocketEvent.write===');
            break;
          case RawSocketEvent.readClosed:
            Logger.log('===RawSocketEvent.readClosed===');
            break;
          case RawSocketEvent.closed:
            Logger.log('===RawSocketEvent.close===');
            break;
        }
      
      });
    }
  }

  @override
  void disconnect() {}

  @override
  Future<void> ping() async {
    await MultiCastUtil.ping(_sockets);
  }

  @override
  Future<void> pong(DeviceModal to) async {
    await MultiCastUtil.pong(_sockets, to);
  }

  @override
  Future<DeviceModal> getDeviceModal() async {
    return await MultiCastUtil.getDeviceModal();
  }
}
