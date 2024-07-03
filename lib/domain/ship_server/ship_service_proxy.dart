import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:drift/isolate.dart';
import 'package:flix/domain/bubble_pool.dart';
import 'package:flix/domain/database/database.dart';
import 'package:flix/domain/device/ap_interface.dart';
import 'package:flix/domain/device/device_manager.dart';
import 'package:flix/domain/device/device_profile_repo.dart';
import 'package:flix/domain/foreground_service/flix_foreground_service.dart';
import 'package:flix/domain/isolate/isolate_communication.dart';
import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/domain/log/persistence/log_persistence_proxy.dart';
import 'package:flix/domain/physical_lock.dart';
import 'package:flix/domain/settings/SettingsRepo.dart';
import 'package:flix/model/isolate/isolate_command.dart';
import 'package:flix/domain/ship_server/ship_service.dart';
import 'package:flix/model/ship/primitive_bubble.dart';
import 'package:flix/model/ui_bubble/shared_file.dart';
import 'package:flix/model/ui_bubble/ui_bubble.dart';
import 'package:flix/network/protocol/device_modal.dart';
import 'package:flix/network/protocol/ping_pong.dart';
import 'package:flix/utils/bubble_convert.dart';
import 'package:flix/utils/compat/CompatUtil.dart';
import 'package:flix/utils/file/file_helper.dart';
import 'package:flutter/services.dart';

class ShipServiceProxy extends ApInterface {
  late ReceivePort receivePort;
  late SendPort sendPort;
  final syncTasks = <String, Completer>{};
  PongListener? _pongListener;
  final _serverReadyTask = Completer<bool>();
  final ShipService _shipService  = ShipService(did:DeviceProfileRepo.instance.did);

  ShipServiceProxy._internal();

  static final ShipServiceProxy _instance = ShipServiceProxy._internal();

  static final ShipServiceProxy instance = _instance;


  String getAddressByDeviceId(String deviceId) {
    return '${DeviceManager.instance.getNetAdressByDeviceId(deviceId)}';
  }

  Future<bool> startShipServer() async {
    talker.debug("startScan startShipServer");
    var _rootToken = RootIsolateToken.instance!;
    BackgroundIsolateBinaryMessenger.ensureInitialized(_rootToken);
    var isComplete = await _shipService.startShipService();
    _serverReadyTask.complete(isComplete);
    // logPersistence.init(sender: logSender);
    return isComplete;
    // const taskKey = 'startShipServer';
    // return await executeTaskWithTalker(syncTasks, taskKey, () async {
    //   receivePort = ReceivePort();
    //   receivePort.listen((message) async {
    //     if (message is SendPort) {
    //       sendPort = message;
    //       _serverReadyTask.complete(true);
    //     } else {
    //       final shipCommand = IsolateCommand.fromJson(message);
    //       switch (shipCommand.command) {
    //         case 'getNetAddress':
    //           final address = getAddressByDeviceId(shipCommand.data!);
    //           final Map<String, String> args = {
    //             'deviceId': shipCommand.data as String,
    //             'address': address
    //           };
    //           sendPort.send(IsolateCommand('returnNetAddress', args).toJson());
    //           break;
    //         case 'isAutoReceive':
    //           final isAutoReceive =
    //               await SettingsRepo.instance.getAutoReceiveAsync();
    //           sendPort.send(IsolateCommand('returnIsAutoReceive', isAutoReceive)
    //               .toJson());
    //           break;
    //         case 'getSaveDir':
    //           sendPort.send(IsolateCommand(
    //                   'returnSaveDir', SettingsRepo.instance.savedDir)
    //               .toJson());
    //           break;
    //         case 'returnStartShipServer':
    //           callback<bool>(syncTasks, 'startShipServer', shipCommand.data);
    //           break;
    //         case 'returnRestartShipServer':
    //           callback<bool>(syncTasks, 'restartShipServer', shipCommand.data);
    //           break;
    //         case 'returnIsServerLiving':
    //           callback<bool>(syncTasks, 'isServerLiving', shipCommand.data);
    //           break;
    //         case 'returnPort':
    //           callback<int>(syncTasks, 'getPort', shipCommand.data);
    //           break;
    //         case 'receivePong':
    //           final Pong pong = Pong.fromJson(shipCommand.data!);
    //           receivePong(pong);
    //           break;
    //         case 'notifyNewBubble':
    //           final bubble =
    //               PrimitiveBubble.fromJson(jsonDecode(shipCommand.data!));
    //           BubblePool.instance.notify(bubble);
    //           break;
    //         case "markTaskStarted":
    //           PhysicalLock.acquirePhysicalLock();
    //           sendPort.send(IsolateCommand('returnMarkTaskStarted').toJson());
    //           break;
    //         case "markTaskStopped":
    //           PhysicalLock.releasePhysicalLock();
    //           sendPort.send(IsolateCommand('returnMarkTaskStopped').toJson());
    //           break;
    //         case "supportBreakPoint":
    //           sendPort.send(IsolateCommand('returnSupportBreakPoint', _supportBreakPoint(shipCommand.data!)).toJson());
    //           break;
    //       }
    //     }
    //   });
    //   final _sendPort = receivePort.sendPort;
    //   final rootToken = RootIsolateToken.instance!;
    //   final connection = await appDatabase.serializableConnection();
    //   final logSender = await logPersistence.getLogSender();
    //   if (logSender == null) {
    //     talker.error('logSender is null');
    //   }
    //   await Isolate.spawn(startServer, {
    //     'sendPort': _sendPort,
    //     'did': DeviceProfileRepo.instance.did,
    //     'rootToken': rootToken,
    //     'connection': connection,
    //     'logSender': logSender
    //   });
    // });
  }

  @override
  void listenPong(PongListener listener) {
    this._pongListener = listener;
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

  Future<bool> isServerLiving() async {
    await _awaitServerReady();
    return _shipService.isServerLiving();
  }

  Future<bool> restartShipServer() async {
    await _awaitServerReady();
    return _shipService.restartShipServer();
    // return await executeTaskWithTalker(syncTasks, 'restartShipServer', () {
    //   sendPort.send(IsolateCommand('restartShipServer').toJson());
    // });
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

  void notifyNewBubble(PrimitiveBubble bubble){
    BubblePool.instance.notify(bubble);
  }

  bool supportBreakPoint(String fingerprint) {
    return CompatUtil.supportBreakPoint(fingerprint);
  }

  Future<void> markTaskStarted() async {
    PhysicalLock.acquirePhysicalLock();
  }

  Future<void> markTaskStopped() async{
    PhysicalLock.releasePhysicalLock();
  }
}

final shipService = ShipServiceProxy.instance;
