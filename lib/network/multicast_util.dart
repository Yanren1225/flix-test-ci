import 'dart:convert';
import 'dart:io';

import 'package:androp/network/protocol/device_modal.dart';
import 'package:androp/utils/logger.dart';
import 'package:androp/utils/sleep.dart';

class MultiCastUtil {
  /// The default http server port and
  /// and multicast port.
  static const defaultPort = 53317;

  /// The default multicast group should be 224.0.0.0/24
  /// because on some Android devices this is the only IP range
  /// that can receive UDP multicast messages.
  static const defaultMulticastGroup = '224.0.0.167';

  static Future<List<_SocketResult>> getSockets(String multicastGroup,
      [int? port]) async {
    final interfaces = await NetworkInterface.list();
    final sockets = <_SocketResult>[];
    for (final interface in interfaces) {
      try {
        final socket =
            await RawDatagramSocket.bind(InternetAddress.anyIPv4, port ?? 0);
        socket.joinMulticast(InternetAddress(multicastGroup), interface);
        sockets.add(_SocketResult(interface, socket));
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
  static Future<void> sendAnnouncement() async {
    final sockets = await getSockets(defaultMulticastGroup);
    var deviceModal = DeviceModal(
        alias: '',
        deviceType: DeviceType.mobile,
        fingerprint: '111',
        port: defaultPort,
        deviceModel: 'macos');
    for (final wait in [100, 500, 2000]) {
      await sleepAsync(wait);
      for (final socket in sockets) {
        try {
          socket.socket.send(utf8.encode(jsonEncode(deviceModal.toJson())),
              InternetAddress(defaultMulticastGroup), defaultPort);
          socket.socket.close();
        } catch (e) {
          print(e.toString());
        }
      }
    }
  }
}

class _SocketResult {
  final NetworkInterface interface;
  final RawDatagramSocket socket;

  _SocketResult(this.interface, this.socket);
}
