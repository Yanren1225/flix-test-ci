import 'dart:convert';
import 'dart:io';

import 'package:flix/domain/device/device_profile_repo.dart';
import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/network/discover/discover_manager.dart';
import 'package:flix/network/discover/discover_param.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class MultiDiscoverHelper {
  static final List<SocketResult> _sockets = [];

  static List<SocketResult> getAliveSockets() {
    return _sockets;
  }

  static Future<List<SocketResult>> getSockets(
      String multicastGroup, int multicastPort) async {
    try {
      final interfaces = await NetworkInterface.list();
      final sockets = <SocketResult>[];
      for (final interface in interfaces) {
        try {
          final socket = await RawDatagramSocket.bind(
              InternetAddress.anyIPv4, multicastPort,reuseAddress: true,reusePort: true);
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
    } catch (e, s) {
      talker.error("failed to get network interfaces", e, s);
      return [];
    }
  }

  static Future<void> startScan(DiscoverParam param) async {
    // if (_listening) {
    //   Logger.log('Already listening to multicast');
    //   return;
    // }
    // _listening = true;
    String group = param.group;
    int port = param.port;
    if (Platform.isIOS) {
      await startScanOnIOS(group, port, param.callback!);
    } else {
      await MultiDiscoverHelper.releaseMulticastLock();
      await MultiDiscoverHelper.aquireMulticastLock();
      for (final socket in _sockets) {
        socket.socket.close();
      }
      _sockets.clear();
      final sockets = await MultiDiscoverHelper.getSockets(group, port);
      _sockets.addAll(sockets);
      for (final socket in sockets) {
        socket.socket.listen((event) async {
          switch (event) {
            case RawSocketEvent.read:
              final datagram = socket.socket.receive();

              if (datagram != null) {
                param.callback?.call(datagram.address.address, "multi");
              }
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

  // static Future<void> _receiveMessage(String fromIp, String message,
  //     DeviceDiscoverCallback deviceScanCallback) async {
  //   DeviceModal deviceModal;
  //   bool needPong = false;
  //   try {
  //     final ping = Ping.fromJson(message);
  //     deviceModal = ping.deviceModal;
  //     if (MultiDiscoverHelper.isFromSelf(deviceModal.fingerprint)) {
  //       talker.debug("_receiveMessage myself return");
  //       return;
  //     }
  //     needPong = true;
  //   } catch(e,stack) {
  //     talker.debug("_receiveMessage failed",stack);
  //     final pong = Pong.fromJson(message);
  //     if (MultiDiscoverHelper.isFromSelf(pong.from.fingerprint)) {
  //       talker.debug("_receiveMessage myself return");
  //       return;
  //     }
  //     if (pong.to.fingerprint == DeviceProfileRepo.instance.did) {
  //       deviceModal = pong.from;
  //       needPong == false;
  //     } else {
  //       talker.debug("_receiveMessage did error not correct",stack);
  //       return;
  //     }
  //   }
  //   talker.debug("_receiveMessage perfect right");
  //   // final deviceModal = DeviceModal.fromJson(message);
  //   deviceModal.ip = fromIp;
  // }

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
      DeviceDiscoverCallback deviceDiscoverCallback) async {
    MULTICAST_IOS_CHANNEL.setMethodCallHandler((call) async {
      try {
        if (call.method == "receiveMulticastMessage") {
          final args = call.arguments as Map;
          deviceDiscoverCallback.call(args["fromIp"], "multi");
        }
      } catch (e) {
        talker.debug('receive message on iOS failed: ', e);
      }
    });

    return await MULTICAST_IOS_CHANNEL
        .invokeMethod('scan', {"host": multiGroup, "port": port});
  }

  static Future<void> pingOnIOS(String content) async {
    return await MULTICAST_IOS_CHANNEL.invokeMethod('ping', content);
  }

  static Future<void> pongOnIOS(String content) async {
    return await MULTICAST_IOS_CHANNEL.invokeMethod('pong', content);
  }
}

class SocketResult {
  final NetworkInterface interface;
  final RawDatagramSocket socket;

  SocketResult(this.interface, this.socket);
}
