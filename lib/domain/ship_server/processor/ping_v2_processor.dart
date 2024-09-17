import 'dart:convert';
import 'dart:io';

import 'package:flix/domain/device/device_manager.dart';
import 'package:flix/domain/device/device_profile_repo.dart';
import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/domain/ship_server/ship_service.dart';
import 'package:flix/domain/ship_server/ship_service_proxy.dart';
import 'package:flix/domain/ship_server/ship_url_helper.dart';
import 'package:flix/network/protocol/device_modal.dart';
import 'package:flix/network/protocol/ping_pong.dart';
import 'package:flix/utils/net/net_utils.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:http/http.dart' as http;

//ping v2
//A ack B  deviceModel
//B answer A device Model
class PingV2Processor {
  static const String tag = "PingV2Processor";

  static Future<DeviceModal?> pingV2Time(
      String ip, int port, DeviceModal from, int time) async {
    try {
      var uri = Uri.parse(await ShipUrlHelper.pingV2Url(ip, port));
      var response = await http.post(
        uri,
        body: Ping(from).toJson(),
        headers: {"Content-type": "application/json; charset=UTF-8"},
      ).timeout(Duration(milliseconds: time));
      if (response.statusCode == 200) {
        talker.debug('ping success: response: ${response.body}');
        DeviceModal deviceModal =
            DeviceModal.fromJson(jsonDecode(response.body));
        if (deviceModal != null) {
          deviceModal.port = port;
          deviceModal.ip = ip;
        }
        return deviceModal;
      } else {
        talker.error(
            'ping failed: status code: ${response.statusCode}, ${response.body}');
      }
    } catch (e, stackTrace) {
      talker.error('ping failed: ', e, stackTrace);
    }
    return null;
  }

  static Future<DeviceModal?> pingV2(String ip, int port, DeviceModal from) {
    return pingV2Time(ip, port, from, 200);
  }

  static Future<shelf.Response> receivePingV2(shelf.Request request) async {
    try {
      final body = await request.readAsString();
      talker.debug("_receivePingV2 from $body");
      final ping = Ping.fromJson(body);

      final clientAddress =
          (request.context['shelf.io.connection_info'] as HttpConnectionInfo?)
              ?.remoteAddress
              .address;
      talker.debug(tag, "receivePingV2 clientAddress = $clientAddress");
      if (clientAddress != null) {
        ping.deviceModal.ip = clientAddress;
      }
      DeviceManager.instance.addDevice(ping.deviceModal);
      return shelf.Response.ok(jsonEncode(await DeviceProfileRepo.instance
          .getDeviceModal(await shipService.getPort())));
    } on Exception catch (e, stack) {
      talker.error('receive ping error: ', e, stack);
      return shelf.Response.badRequest();
    }
  }
}
