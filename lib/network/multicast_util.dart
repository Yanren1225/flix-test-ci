import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flix/domain/device/device_manager.dart';
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

  /// Sends an announcement which triggers a response on every LocalSend member of the network.
  static Future<void> ping(List<SocketResult> sockets) async {
    // final sockets = await getSockets(defaultMulticastGroup);
    DeviceModal deviceModal = await getDeviceModal();
    for (final wait in [100, 500, 2000]) {
      await sleepAsync(wait);
      for (final socket in sockets) {
        try {
          socket.socket.send(
              utf8.encode(jsonEncode(Ping(deviceModal).toJson())),
              InternetAddress(defaultMulticastGroup),
              defaultPort);
          // socket.socket.close();
        } catch (e) {
          print(e.toString());
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

  static Future<void> pong(List<SocketResult> sockets, DeviceModal to) async {
    // final sockets = await getSockets(defaultMulticastGroup);
    DeviceModal deviceModal = await getDeviceModal();
    for (final wait in [100, 500, 2000]) {
      await sleepAsync(wait);
      for (final socket in sockets) {
        try {
          socket.socket.send(
              utf8.encode(jsonEncode(Pong(deviceModal, to).toJson())),
              InternetAddress(defaultMulticastGroup),
              defaultPort);
          // socket.socket.close();
        } catch (e) {
          print(e.toString());
        }
      }
    }
  }

  static const multicastLock = MethodChannel('com.ifreedomer.flix/multicast-lock');

  static Future aquireMulticastLock() async {
    if (Platform.isAndroid) {
      log("locking multicast lock");
      multicastLock.invokeMethod('aquire');
    }

  }

  static Future releaseMulticastLock() async {
    if (Platform.isAndroid) {
      log("releasing multicast lock");
      multicastLock.invokeMethod('release');
    }

  }

  static bool isFromSelf(String from) {
    if (from == DeviceManager.instance.did) {
      log('receive self datagram');
      return true;
    }
    return false;
  }
}

class SocketResult {
  final NetworkInterface interface;
  final RawDatagramSocket socket;

  SocketResult(this.interface, this.socket);
}
