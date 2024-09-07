import 'dart:io';

import 'package:flix/domain/device/ap_interface.dart';
import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/domain/ship_server/ship_service_proxy.dart';
import 'package:flix/domain/ship_server/ship_url_helper.dart';
import 'package:flix/network/protocol/device_modal.dart';
import 'package:flix/network/protocol/ping_pong.dart';
import 'package:shelf/shelf.dart';
import 'package:http/http.dart' as http;
class PingPongProcessor {
  List<PingPongListener> _pingPongListeners = [];
  Future<void> ping(String ip, int port, DeviceModal from) async {
    try {
      var uri = Uri.parse(await ShipUrlHelper.pingUrl(ip, port));

      var response = await http.post(
        uri,
        body: Ping(from).toJson(),
        headers: {"Content-type": "application/json; charset=UTF-8"},
      );

      if (response.statusCode == 200) {
        talker.debug('ping success: response: ${response.body}');
      } else {
        talker.error(
            'ping failed: status code: ${response.statusCode}, ${response.body}');
      }
    } catch (e, stackTrace) {
      talker.error('ping failed: ', e, stackTrace);
    }
  }

  @override
  Future<void> pong(DeviceModal from, DeviceModal to) async {
    try {
      final message = Pong(from, to).toJson();
      var uri = Uri.parse(await ShipUrlHelper.pongUrl(to.fingerprint));
      var response = await http.post(
        uri,
        body: message,
        headers: {"Content-type": "application/json; charset=UTF-8"},
      );

      if (response.statusCode == 200) {
        talker.debug('pong success: response: ${response.body}');
      } else {
        talker.debug(
            'pong failed: status code: ${response.statusCode}, ${response.body}');
      }
    } catch (e, stackTrace) {
      talker.error('pong failed', e, stackTrace);
    }
  }

  Future<Response> receivePing(Request request) async {
    try {
      final body = await request.readAsString();
      final ping = Ping.fromJson(body);
      final ip =
          (request.context['shelf.io.connection_info'] as HttpConnectionInfo?)
              ?.remoteAddress
              .address;
      if (ip != null) {
        ping.deviceModal.ip = ip;
        talker.debug('receive tcp ping: $ping');
        notifyPing(ping);
      } else {
        talker.error('receive tcp ping, but can\'t get ip');
      }
      return Response.ok('ok');
    } on Exception catch (e, stack) {
      talker.error('receive ping error: ', e, stack);
      return Response.badRequest();
    }
  }

  Future<Response> receivePong(Request request) async {
    try {
      final body = await request.readAsString();
      talker.debug('receive pong $body');
      final pong = Pong.fromJson(body);
      final ip =
          (request.context['shelf.io.connection_info'] as HttpConnectionInfo?)
              ?.remoteAddress
              .address;
      if (ip != null) {
        pong.from.ip = ip;
        talker.debug('receive tcp pong: $pong');
        notifyPong(pong);
      } else {
        talker.error('receive tcp pong, but can\'t get ip');
      }
      return Response.ok('ok');
    } on Exception catch (e, stack) {
      talker.error('receive pong error: ', e, stack);
      return Response.badRequest();
    }
  }

  @override
  void listenPingPong(PingPongListener listener) {
    _pingPongListeners.add(listener);
  }

  void notifyPing(Ping ping) {
    for (var value in _pingPongListeners) {
      value.onPing(ping);
    }
  }

  void notifyPong(Pong pong) {
    for (var value in _pingPongListeners) {
      value.onPong(pong);
    }
  }
}
