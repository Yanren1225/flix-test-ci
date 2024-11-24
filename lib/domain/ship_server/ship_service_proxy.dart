import 'dart:async';
import 'dart:io';

import 'package:flix/domain/bubble_pool.dart';
import 'package:flix/domain/device/device_manager.dart';
import 'package:flix/domain/device/device_profile_repo.dart';
import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/domain/physical_lock.dart';
import 'package:flix/domain/ship_server/ship_service.dart';
import 'package:flix/model/ship/primitive_bubble.dart';
import 'package:flix/model/ui_bubble/shared_file.dart';
import 'package:flix/model/ui_bubble/ui_bubble.dart';
import 'package:flix/network/discover/network_connect_manager.dart';
import 'package:flix/network/multicast_client_provider.dart';
import 'package:flix/network/protocol/device_modal.dart';
import 'package:flix/presentation/widgets/flix_toast.dart';
import 'package:flix/utils/bubble_convert.dart';
import 'package:flix/utils/device/device_utils.dart';
import 'package:flix/utils/platform_utils.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../utils/compat/compat_util.dart';

class ShipServiceProxy {
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

  String getAddressWithoutPort(String deviceId){
    return '${DeviceManager.instance.getNetAdressByDeviceIdWithoutPort(deviceId)}';
  }

  Future<bool> startShipServer() async {
    talker.debug("startScan startShipServer");
    var isComplete = await _shipService.startShipService();
    _serverReadyTask.complete(isComplete);
    return isComplete;
  }

  Future<void> send(UIBubble uiBubble) async {
    await _awaitServerReady();
    final primitiveBubble = fromUIBubble(uiBubble);
    showBigFileToast(primitiveBubble);
    var isAlive =
        await checkAlive("sendBubble", getAddressWithoutPort(uiBubble.to));
    talker.debug("sendBubble", "${uiBubble.from} is Alive = $isAlive");
    if (!isAlive) {
      showNotAliveToast();
      return;
    }
    _shipService.send(primitiveBubble);
  }

  void showBigFileToast(PrimitiveBubble<dynamic> primitiveBubble) {
    if (primitiveBubble is PrimitiveFileBubble) {
      var meta = primitiveBubble.content.meta;
      if (meta != null && meta.size > 1024 * 1024 * 1024 * 2 && isMobile()) {
        FlixToast.instance.info("文件较大，传输时请不要关闭软件");
      }
    }
  }

  void showNotAliveToast() {
    FlixToast.instance.info("接收设备不活跃，刷新一下它～");
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
        _shipService.sendClipboard(element.fingerprint, lastText);
      }
    }
  }

  String getDid() {
    return _shipService.did;
  }

  Future<bool> checkAlive(String from, String ip) async {
    return await NetworkConnectManager.instance.pingApi.pingWithTime(ip,_shipService.port,"checkAlive_$from",2000) != null;
  }
}

final shipService = ShipServiceProxy.instance;
