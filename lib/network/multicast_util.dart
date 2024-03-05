import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:flix/domain/device/device_manager.dart';
import 'package:flix/network/multicast_impl.dart';
import 'package:flix/network/protocol/device_modal.dart';
import 'package:flix/network/protocol/ping_pong.dart';
import 'package:flix/setting/setting_provider.dart';
import 'package:flix/utils/device_info_helper.dart';
import 'package:flix/utils/logger.dart';
import 'package:flix/utils/sleep.dart';
import 'package:flutter/services.dart';

class MultiCastUtil {
  /// The default http server port and
  /// and multicast port.
  static const defaultPort = 8891;

  /// The default multicast group should be 224.0.0.0/24
  /// because on some Android devices this is the only IP range
  /// that can receive UDP multicast messages.
  static const defaultMulticastGroup = '224.0.0.168';

  static final List<SocketResult> _sockets = [];

  static Future<List<SocketResult>> getSockets(String multicastGroup,
      [int? port]) async {
    final interfaces = await NetworkInterface.list();
    final sockets = <SocketResult>[];
    for (final interface in interfaces) {
      try {
        final socket =
            await RawDatagramSocket.bind(InternetAddress.anyIPv4, port ?? 0);
        // 不允许接收自己发送的消息
        // socket.multicastLoopback = false;
        socket.joinMulticast(InternetAddress(multicastGroup), interface);
        // 不允许接收自己发送的消息
        socket.multicastLoopback = false;
        sockets.add(SocketResult(interface, socket));
        Logger.log('$socket $interface');
      } catch (e) {
        Logger.logException(
          'Could not bind UDP multicast port (ip: ${interface.addresses.map((a) => a.address).toList()}, group: $multicastGroup, port: $port)',
          e,
        );
      }
    }
    return sockets;
  }

  static Future<void> startScan(String multiGroup, int port,
      DeviceScanCallback deviceScanCallback) async {
    // if (_listening) {
    //   Logger.log('Already listening to multicast');
    //   return;
    // }
    // _listening = true;

    if (Platform.isIOS) {
      await startScanOnIOS(multiGroup, port, deviceScanCallback);
    } else {
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
              _receiveMessage(
                  datagram.address.address, data, deviceScanCallback);
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
        }, onError: (e) {
          Logger.log('[multicast] multicast error: $e');
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
      if (pong.to.fingerprint == DeviceManager.instance.did) {
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
  static Future<void> ping() async {
    // final sockets = await getSockets(defaultMulticastGroup);
    DeviceModal deviceModal = await getDeviceModal();
    final message = jsonEncode(Ping(deviceModal).toJson());
    if (Platform.isIOS) {
      pingOnIOS(message);
    } else {
      for (final wait in [100, 500, 2000]) {
        await sleepAsync(wait);
        for (final socket in _sockets) {
          try {
            socket.socket.send(utf8.encode(message),
                InternetAddress(defaultMulticastGroup), defaultPort);
            // socket.socket.close();
          } catch (e) {
            print(e.toString());
          }
        }
      }
    }
  }

  static Future<void> pong(DeviceModal to) async {
    // final sockets = await getSockets(defaultMulticastGroup);
    DeviceModal deviceModal = await getDeviceModal();
    final message = jsonEncode(Ping(deviceModal).toJson());
    if (Platform.isIOS) {
      pongOnIOS(message);
    } else {
      for (final wait in [100, 500, 2000]) {
        await sleepAsync(wait);
        for (final socket in _sockets) {
          try {
            socket.socket.send(utf8.encode(message),
                InternetAddress(defaultMulticastGroup), defaultPort);
            // socket.socket.close();
          } catch (e) {
            print(e.toString());
          }
        }
      }
    }
  }

  static Future<DeviceModal> getDeviceModal() async {
    final deviceId = DeviceManager.instance.did;
    var deviceInfo = await getDeviceInfo();
    var deviceModal = DeviceModal(
        alias: '',
        deviceType: deviceInfo.deviceType,
        fingerprint: deviceId!,
        port: defaultPort,
        deviceModel: deviceInfo.deviceModel);
    return deviceModal;
  }

  static const MULTICAST_LOCK_CHANNEL =
      MethodChannel('com.ifreedomer.flix/multicast-lock');
  static const MULTICAST_IOS_CHANNEL =
      MethodChannel("com.ifreedomer.flix/multicast");

  static Future aquireMulticastLock() async {
    if (Platform.isAndroid) {
      log("locking multicast lock");
      MULTICAST_LOCK_CHANNEL.invokeMethod('aquire');
    }
  }

  static Future releaseMulticastLock() async {
    if (Platform.isAndroid) {
      log("releasing multicast lock");
      MULTICAST_LOCK_CHANNEL.invokeMethod('release');
    }
  }

  static bool isFromSelf(String from) {
    if (from == DeviceManager.instance.did) {
      log('receive self datagram');
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
          await onReceiveMessageOnIOS(args["fromIp"] as String, jsonDecode(args["message"] as String), deviceScanCallback);
        }
      } catch (e) {
        Logger.log('receive message on iOS failed: $e');
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
