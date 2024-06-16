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
import 'package:flix/domain/ship_server/ship_service_bridge.dart';
import 'package:flix/model/ship/primitive_bubble.dart';
import 'package:flix/model/ui_bubble/shared_file.dart';
import 'package:flix/model/ui_bubble/ui_bubble.dart';
import 'package:flix/network/protocol/device_modal.dart';
import 'package:flix/network/protocol/ping_pong.dart';
import 'package:flix/utils/bubble_convert.dart';
import 'package:flix/utils/compat/CompatUtil.dart';
import 'package:flutter/services.dart';

class ShipServiceProxy extends ApInterface {
  late ReceivePort receivePort;
  late SendPort sendPort;
  final syncTasks = <String, Completer>{};
  PongListener? _pongListener;
  final _serverReadyTask = Completer<bool>();

  ShipServiceProxy._internal();

  static final ShipServiceProxy _instance = ShipServiceProxy._internal();

  static final ShipServiceProxy instance = _instance;

  String _getAddressByDeviceId(String deviceId) {
    return '${DeviceManager.instance.getNetAdressByDeviceId(deviceId)}';
  }

  Future<bool> startShipServer() async {
    const taskKey = 'startShipServer';
    return await executeTaskWithTalker(syncTasks, taskKey, () async {
      receivePort = ReceivePort();
      receivePort.listen((message) async {
        if (message is SendPort) {
          sendPort = message;
          _serverReadyTask.complete(true);
        } else {
          final shipCommand = IsolateCommand.fromJson(message);
          switch (shipCommand.command) {
            case 'getNetAddress':
              final address = _getAddressByDeviceId(shipCommand.data!);
              final Map<String, String> args = {
                'deviceId': shipCommand.data as String,
                'address': address
              };
              sendPort.send(IsolateCommand('returnNetAddress', args).toJson());
              break;
            case 'isAutoReceive':
              final isAutoReceive =
                  await SettingsRepo.instance.getAutoReceiveAsync();
              sendPort.send(IsolateCommand('returnIsAutoReceive', isAutoReceive)
                  .toJson());
              break;
            case 'getSaveDir':
              sendPort.send(IsolateCommand(
                      'returnSaveDir', SettingsRepo.instance.savedDir)
                  .toJson());
              break;
            case 'returnStartShipServer':
              callback<bool>(syncTasks, 'startShipServer', shipCommand.data);
              break;
            case 'returnRestartShipServer':
              callback<bool>(syncTasks, 'restartShipServer', shipCommand.data);
              break;
            case 'returnIsServerLiving':
              callback<bool>(syncTasks, 'isServerLiving', shipCommand.data);
              break;
            case 'returnPort':
              callback<int>(syncTasks, 'getPort', shipCommand.data);
              break;
            case 'receivePong':
              final Pong pong = Pong.fromJson(shipCommand.data!);
              _receivePong(pong);
              break;
            case 'notifyNewBubble':
              final bubble =
                  PrimitiveBubble.fromJson(jsonDecode(shipCommand.data!));
              BubblePool.instance.notify(bubble);
              break;
            case "markTaskStarted":
              PhysicalLock.acquirePhysicalLock();
              sendPort.send(IsolateCommand('returnMarkTaskStarted').toJson());
              break;
            case "markTaskStopped":
              PhysicalLock.releasePhysicalLock();
              sendPort.send(IsolateCommand('returnMarkTaskStopped').toJson());
              break;
            case "supportBreakPoint":
              sendPort.send(IsolateCommand('returnSupportBreakPoint', _supportBreakPoint(shipCommand.data!)).toJson());
              break;
          }
        }
      });
      final _sendPort = receivePort.sendPort;
      final rootToken = RootIsolateToken.instance!;
      final connection = await appDatabase.serializableConnection();
      final logSender = await logPersistence.getLogSender();
      if (logSender == null) {
        talker.error('logSender is null');
      }
      await Isolate.spawn(startServer, {
        'sendPort': _sendPort,
        'did': DeviceProfileRepo.instance.did,
        'rootToken': rootToken,
        'connection': connection,
        'logSender': logSender
      });
    });
  }

  @override
  void listenPong(PongListener listener) {
    this._pongListener = listener;
  }

  @override
  Future<void> pong(DeviceModal from, DeviceModal to) async {
    await _awaitServerReady();
    sendPort.send(IsolateCommand('pong', Pong(from, to).toJson()).toJson());
  }

  Future<void> send(UIBubble uiBubble) async {
    await _awaitServerReady();
    final primitiveBubble = fromUIBubble(uiBubble);
    sendPort.send(
        IsolateCommand('send', jsonEncode(primitiveBubble.toJson(full: true)))
            .toJson());
  }

  Future<void> confirmReceiveFile(String from, String bubbleId) async {
    await _awaitServerReady();
    sendPort.send(IsolateCommand(
        'confirmReceiveFile',
        jsonEncode({
          'from': from,
          'bubbleId': bubbleId,
        })).toJson());
  }

  Future<int> getPort() async {
    await _awaitServerReady();
    return await executeTaskWithTalker(syncTasks, 'getPort', () {
      sendPort.send(IsolateCommand('getPort').toJson());
    });
  }

  Future<void> cancelReceive(UIBubble uiBubble) async {
    final bubble = fromUIBubble(uiBubble) as PrimitiveFileBubble;
    await updateFileShareState(
        BubblePool.instance, bubble.id, FileState.cancelled,
        create: bubble);
  }

  Future<void> resend(UIBubble uiBubble) async {
    await _awaitServerReady();
    sendPort.send(IsolateCommand(
            'resend', jsonEncode(fromUIBubble(uiBubble).toJson(full: true)))
        .toJson());
  }

  Future<bool> isServerLiving() async {
    await _awaitServerReady();
    return await executeTaskWithTalker(syncTasks, 'isServerLiving', () {
      sendPort.send(IsolateCommand('isServerLiving').toJson());
    });
  }

  Future<bool> restartShipServer() async {
    await _awaitServerReady();
    return await executeTaskWithTalker(syncTasks, 'restartShipServer', () {
      sendPort.send(IsolateCommand('restartShipServer').toJson());
    });
  }

  Future<void> cancelSend(UIBubble uiBubble) async {
    await _awaitServerReady();
    sendPort.send(IsolateCommand(
            'cancelSend', jsonEncode(fromUIBubble(uiBubble).toJson(full: true)))
        .toJson());
  }

  void _receivePong(Pong pong) {
    _pongListener?.call(pong);
  }

  Future<bool> _awaitServerReady() async {
    return _serverReadyTask.future;
  }

  bool _supportBreakPoint(String fingerprint) {
    return CompatUtil.supportBreakPoint(fingerprint);
  }
}

final shipService = ShipServiceProxy.instance;
