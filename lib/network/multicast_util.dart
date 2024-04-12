import 'dart:convert';
import 'dart:io';

import 'package:dart_mappable/dart_mappable.dart';
import 'package:flix/domain/device/device_manager.dart';
import 'package:flix/domain/device/device_profile_repo.dart';

import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/network/multicast_impl.dart';
import 'package:flix/network/protocol/device_modal.dart';
import 'package:flix/network/protocol/ping_pong.dart';
import 'package:flix/utils/sleep.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'nearby_service_info.dart';

class MultiCastUtil {

  static final List<SocketResult> _sockets = [];

  static Future<List<SocketResult>> getSockets(String multicastGroup,
      int multicastPort) async {
    final interfaces = await NetworkInterface.list();
    final sockets = <SocketResult>[];
    for (final interface in interfaces) {
      try {
        final socket =
            await RawDatagramSocket.bind(InternetAddress.anyIPv4, multicastPort);
        // 不允许接收自己发送的消息
        // socket.multicastLoopback = false;
        socket.joinMulticast(InternetAddress(multicastGroup), interface);
        // 不允许接收自己发送的消息
        socket.multicastLoopback = false;
        sockets.add(SocketResult(interface, socket));
        talker.debug('$socket $interface');
      } catch (e) {
        talker.error(
            'Could not bind UDP multicast port (ip: ${interface.addresses.map((a) => a.address).toList()}, group: $multicastGroup, port: $multicastPort)',
            e);
      }
    }
    return sockets;
  }


  static Future<void> startScan(String group, int port, DeviceScanCallback deviceScanCallback) async {
    // if (_listening) {
    //   Logger.log('Already listening to multicast');
    //   return;
    // }
    // _listening = true;

    if (Platform.isIOS) {
      await startScanOnIOS(group, port, deviceScanCallback);
    } else {
      await MultiCastUtil.releaseMulticastLock();
      await MultiCastUtil.aquireMulticastLock();
      for (final socket in _sockets) {
        socket.socket.close();
      }
      _sockets.clear();
      final sockets = await MultiCastUtil.getSockets(group, port);
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
              talker.debug('receive data:$data');
              _receiveMessage(
                  datagram.address.address, data, deviceScanCallback);
              break;
            case RawSocketEvent.write:
              talker.debug('===RawSocketEvent.write===');
              break;
            case RawSocketEvent.readClosed:
              talker.debug('===RawSocketEvent.readClosed===');
              break;
            case RawSocketEvent.closed:
              talker.debug('===RawSocketEvent.close===');
              break;
          }
        }, onError: (e) {
          talker.error('[multicast] multicast error: ', e);
        });
      }
    }
  }

  static Future<void> _receiveMessage(String fromIp, String message,
      DeviceScanCallback deviceScanCallback) async {
    DeviceModal deviceModal;
    bool needPong = false;
    try {
      final ping = Ping.fromJson(message);
      deviceModal = ping.deviceModal;
      if (MultiCastUtil.isFromSelf(deviceModal.fingerprint)) {
        return;
      }
      needPong = true;
    } on MapperException catch (e) {
      final pong = Pong.fromJson(message);
      if (MultiCastUtil.isFromSelf(pong.from.fingerprint)) {
        return;
      }
      if (pong.to.fingerprint == DeviceProfileRepo.instance.did) {
        deviceModal = pong.from;
        needPong == false;
      } else {
        return;
      }
    }
    // final deviceModal = DeviceModal.fromJson(message);
    deviceModal.ip = fromIp;
    deviceScanCallback(deviceModal, needPong);
  }

  /// Sends an announcement which triggers a response on every LocalSend member of the network.
  static Future<void> ping(String group, int port, DeviceModal deviceModal) async {
    // final sockets = await getSockets(defaultMulticastGroup);
    final message = jsonEncode(Ping(deviceModal).toJson());
    if (Platform.isIOS) {
      pingOnIOS(message);
    } else {
      for (final wait in [100, 500, 2000]) {
        await sleepAsync(wait);
        for (final socket in _sockets) {
          try {
            socket.socket.send(utf8.encode(message),
                InternetAddress(group), port);
            // socket.socket.close();
          } catch (e, stackTrace) {
            talker.error('ping failed', e, stackTrace);
          }
        }
      }
    }
  }

  // 通过AP接口发送的multicast是不可靠的，
  // 实测Android开启热点其他设备无法接收到AP设备的组播数据
  // 见 https://forum.mikrotik.com/viewtopic.php?t=28756
  static Future<void> pong(String group, int port, DeviceModal from, DeviceModal to) async {
    // final sockets = await getSockets(defaultMulticastGroup);
    final message = jsonEncode(Pong(from, to).toJson());
    if (Platform.isIOS) {
      pongOnIOS(message);
    } else {
      for (final socket in _sockets) {
        try {
          socket.socket.send(utf8.encode(message),
              InternetAddress(group), port);
          // socket.socket.close();
        } catch (e, stackTrace) {
          talker.error('pong failed', e, stackTrace);
        }
      }
    }
  }

  static const MULTICAST_LOCK_CHANNEL =
      MethodChannel('com.ifreedomer.flix/multicast-lock');
  static const MULTICAST_IOS_CHANNEL =
      MethodChannel("com.ifreedomer.flix/multicast");

  static Future aquireMulticastLock() async {
    if (Platform.isAndroid) {
      talker.debug("locking multicast lock");
      MULTICAST_LOCK_CHANNEL.invokeMethod('aquire');
    }
  }

  static Future releaseMulticastLock() async {
    if (Platform.isAndroid) {
      talker.debug("releasing multicast lock");
      MULTICAST_LOCK_CHANNEL.invokeMethod('release');
    }
  }

  static bool isFromSelf(String from) {
    // ⚠️debug模式下用自己作为测试设备⚠️
    if (kDebugMode) return false;
    if (from == DeviceProfileRepo.instance.did) {
      talker.debug('receive self datagram');
      return true;
    }
    return false;
  }

  static Future<void> startScanOnIOS(String multiGroup, int port,
      DeviceScanCallback deviceScanCallback) async {
    MULTICAST_IOS_CHANNEL.setMethodCallHandler((call) async {
      try {
        if (call.method == "receiveMulticastMessage") {
          final args = call.arguments as Map;
          await onReceiveMessageOnIOS(args["fromIp"] as String,
              jsonDecode(args["message"] as String), deviceScanCallback);
        }
      } catch (e) {
        talker.debug('receive message on iOS failed: ', e);
      }
    });

// await MULTICAST_IOS_CHANNEL
//     .invokeMethod('startMulticast', {"host": multiGroup, "port": port});
    return await MULTICAST_IOS_CHANNEL
        .invokeMethod('scan', {"host": multiGroup, "port": port});
  }

  static Future<void> pingOnIOS(String content) async {
    return await MULTICAST_IOS_CHANNEL.invokeMethod('ping', content);
  }

  static Future<void> pongOnIOS(String content) async {
    return await MULTICAST_IOS_CHANNEL.invokeMethod('pong', content);
  }

  static Future<void> onReceiveMessageOnIOS(String fromIp, String message,
      DeviceScanCallback deviceScanCallback) async {
    await _receiveMessage(fromIp, message, deviceScanCallback);
  }
}

class SocketResult {
  final NetworkInterface interface;
  final RawDatagramSocket socket;

  SocketResult(this.interface, this.socket);
}
