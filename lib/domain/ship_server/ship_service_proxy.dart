import 'dart:async';

import 'package:flix/domain/bubble_pool.dart';
import 'package:flix/domain/device/ap_interface.dart';
import 'package:flix/domain/device/device_manager.dart';
import 'package:flix/domain/device/device_profile_repo.dart';
import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/domain/physical_lock.dart';
import 'package:flix/domain/ship_server/ship_service.dart';
import 'package:flix/model/ship/primitive_bubble.dart';
import 'package:flix/model/ui_bubble/shared_file.dart';
import 'package:flix/model/ui_bubble/ui_bubble.dart';
import 'package:flix/network/protocol/device_modal.dart';
import 'package:flix/utils/bubble_convert.dart';

import '../../utils/compat/compat_util.dart';

class ShipServiceProxy extends ApInterface {
  final syncTasks = <String, Completer>{};
  final _serverReadyTask = Completer<bool>();
  final ShipService _shipService =
      ShipService(did: DeviceProfileRepo.instance.did);

  ShipServiceProxy._internal();

  static final ShipServiceProxy _instance = ShipServiceProxy._internal();

  static final ShipServiceProxy instance = _instance;

  String getAddressByDeviceId(String deviceId) {
    return '${DeviceManager.instance.getNetAdressByDeviceId(deviceId)}';
  }

  Future<bool> startShipServer() async {
    talker.debug("startScan startShipServer");
    var isComplete = await _shipService.startShipService();
    _serverReadyTask.complete(isComplete);
    return isComplete;
  }

  @override
  void listenPingPong(PingPongListener listener) {
    _shipService.listenPingPong(listener);
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
    final bubble = fromUIBubble(uiBubble);
    await updateBubbleShareState(
        BubblePool.instance, bubble.id, FileState.cancelled,
        create: bubble);
  }

  Future<void> resend(UIBubble uiBubble) async {
    await _awaitServerReady();
    _shipService.resend(fromUIBubble(uiBubble));
  }

  Future<void> reReceive(UIBubble uiBubble) async {
    await _awaitServerReady();
    _shipService.reReceive(fromUIBubble(uiBubble));
  }

  Future<void> askPairDevice(String deviceId, String code) async {
    await _shipService.askPairDevice(deviceId, code);
  }

  Future<void> deletePairDevice(String deleteDeviceId) async {
    talker.debug(
        'pairDevice', "deletePairDevice deleteDeviceId = $deleteDeviceId ");
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
    talker.debug("cancelSend 3");
    await _awaitServerReady();
    await _shipService.cancelSend(fromUIBubble(uiBubble));
  }

  Future<bool> _awaitServerReady() async {
    return _serverReadyTask.future;
  }

  void notifyNewBubble(PrimitiveBubble bubble) {
    BubblePool.instance.notify(bubble);
  }

  bool supportBreakPoint(String fingerprint) {
    return CompatUtil.supportBreakPoint(fingerprint);
  }

  Future<void> markTaskStarted() async {
    PhysicalLock.acquirePhysicalLock();
  }

  Future<void> markTaskStopped() async {
    PhysicalLock.releasePhysicalLock();
  }

  void dispatcherClipboard(String lastText) {
    var pairDevices = DeviceManager.instance.pairDevices;
    var deviceList = DeviceManager.instance.deviceList;
    var pairDeviceIds = [];
    for (var element in pairDevices) {
      pairDeviceIds.add(element.fingerprint);
    }

    for (var element in deviceList) {
      if (pairDeviceIds.contains(element.fingerprint)) {
        _shipService.sendClipboard(element.fingerprint,lastText);
      }
    }
  }

  @override
  Future<void> ping(String ip, int port, DeviceModal from) async {
    await _shipService.ping(ip, port, from);
  }

  Future<String> intentUrl(String deviceId) async {
    return shipService.intentUrl(deviceId);
  }



  String getDid() {
    return shipService.getDid();
  }
}

final shipService = ShipServiceProxy.instance;
