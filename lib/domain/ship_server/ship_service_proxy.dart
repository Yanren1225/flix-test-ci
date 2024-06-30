import 'dart:async';

import 'package:flix/domain/bubble_pool.dart';
import 'package:flix/domain/constants.dart';
import 'package:flix/domain/database/database.dart';
import 'package:flix/domain/device/ap_interface.dart';
import 'package:flix/domain/device/device_profile_repo.dart';
import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/domain/ship_server/ship_service.dart';
import 'package:flix/model/ship/primitive_bubble.dart';
import 'package:flix/model/ui_bubble/shared_file.dart';
import 'package:flix/model/ui_bubble/ui_bubble.dart';
import 'package:flix/network/protocol/device_modal.dart';
import 'package:flix/network/protocol/ping_pong.dart';
import 'package:flix/utils/bubble_convert.dart';

class ShipServiceProxy extends ApInterface {
  final syncTasks = <String, Completer>{};
  PongListener? _pongListener;
  final _serverReadyTask = Completer<bool>();
  final ShipService _shipService =
      ShipService(did: DeviceProfileRepo.instance.did);

  ShipServiceProxy._internal();

  static final ShipServiceProxy _instance = ShipServiceProxy._internal();

  static final ShipServiceProxy instance = _instance;

  Future<bool> startShipServer() async {
    talker.debug("startScan startShipServer");
    var isComplete = await _shipService.startShipService();
    _serverReadyTask.complete(isComplete);
    return isComplete;
  }

  @override
  void listenPong(PongListener listener) {
    _shipService.listenPong(listener);
  }

  @override
  Future<void> pong(DeviceModal from, DeviceModal to) async {
    await _awaitServerReady();
    _shipService.pong(from, to);
  }

  Future<void> send(UIBubble uiBubble) async {
    await _awaitServerReady();
    final primitiveBubble = fromUIBubble(uiBubble);
    _shipService.send(primitiveBubble);
  }

  Future<void> confirmReceive(String from, String bubbleId) async {
    await _awaitServerReady();
    _shipService.confirmReceiveBubble(from, bubbleId);
  }

  Future<int> getPort() async {
    await _awaitServerReady();
    return _shipService.port;
  }

  Future<void> cancelReceive(UIBubble uiBubble) async {
    final bubble = fromUIBubble(uiBubble) as PrimitiveFileBubble;
    await updateBubbleShareState(
        BubblePool.instance, bubble.id, FileState.cancelled,
        create: bubble);
  }

  Future<void> resend(UIBubble uiBubble) async {
    await _awaitServerReady();
    _shipService.resend(fromUIBubble(uiBubble));
  }

  Future<void> askPairDevice(String deviceId, String code) async {
    await _shipService.askPairDevice(deviceId, code);
  }


  Future<void> deletePairDevice(String deleteDeviceId) async {
    talker.debug('pairDevice', "deletePairDevice deleteDeviceId = $deleteDeviceId ");
    await _awaitServerReady();
    _shipService.askDeletePairDevice(deleteDeviceId);
  }

  Future<bool> isServerLiving() async {
    await _awaitServerReady();
    return _shipService.isServerLiving();
  }

  Future<bool> restartShipServer() async {
    await _awaitServerReady();
    return _shipService.restartShipServer();
  }

  Future<void> cancelSend(UIBubble uiBubble) async {
    await _awaitServerReady();
    _shipService.cancelSend(fromUIBubble(uiBubble));
  }

  void receivePong(Pong pong) {
    _pongListener?.call(pong);
  }

  Future<bool> _awaitServerReady() async {
    return _serverReadyTask.future;
  }
}

final shipService = ShipServiceProxy.instance;
