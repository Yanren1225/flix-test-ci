import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:drift/isolate.dart';
import 'package:flix/domain/bubble_pool.dart';
import 'package:flix/domain/database/database.dart';
import 'package:flix/domain/device/ap_interface.dart';
import 'package:flix/domain/device/device_manager.dart';
import 'package:flix/domain/device/device_profile_repo.dart';
import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/domain/settings/SettingsRepo.dart';
import 'package:flix/domain/ship_server/ship_command.dart';
import 'package:flix/domain/ship_server/ship_service.dart';
import 'package:flix/domain/ship_server/ship_service_bridge.dart';
import 'package:flix/model/ship/primitive_bubble.dart';
import 'package:flix/model/ui_bubble/shared_file.dart';
import 'package:flix/model/ui_bubble/ui_bubble.dart';
import 'package:flix/network/protocol/device_modal.dart';
import 'package:flix/network/protocol/ping_pong.dart';
import 'package:flix/utils/bubble_convert.dart';
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
    return await executeSyncTask(syncTasks, taskKey, () async {
      receivePort = ReceivePort();
      receivePort.listen((message) async {
        if (message is SendPort) {
          sendPort = message;
          _serverReadyTask.complete(true);
        } else {
          final shipCommand = ShipCommand.fromJson(message);
          switch (shipCommand.command) {
            case 'getNetAddress':
              final address = _getAddressByDeviceId(shipCommand.data!);
              final Map<String, String> args = {'deviceId': shipCommand.data as String, 'address': address};
              sendPort.send(ShipCommand('returnNetAddress', args).toJson());
              break;
            case 'isAutoReceive':
              final isAutoReceive =
              await SettingsRepo.instance.getAutoReceiveAsync();
              sendPort.send(
                  ShipCommand('returnIsAutoReceive', isAutoReceive).toJson());
              break;
            case 'getSaveDir':
              sendPort.send(
                  ShipCommand('returnSaveDir', SettingsRepo.instance.savedDir)
                      .toJson());
              break;
            case 'returnStartShipServer':
              callback<bool>(syncTasks, 'startShipServer', shipCommand.data);
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
              final bubble = PrimitiveBubble.fromJson(jsonDecode(shipCommand.data!));
              await BubblePool.instance.notify(bubble);
              break;
          }
        }
      });
      final _sendPort = receivePort.sendPort;
      final rootToken = RootIsolateToken.instance!;
      final connection = await appDatabase.serializableConnection();
      await Isolate.spawn(startServer, {'sendPort': _sendPort, 'did': DeviceProfileRepo.instance.did, 'rootToken': rootToken, 'connection': connection});
    });
  }

  @override
  void listenPong(PongListener listener) {
    this._pongListener = listener;
  }

  @override
  Future<void> pong(DeviceModal from, DeviceModal to) async {
    await _awaitServerReady();
    sendPort.send(ShipCommand('pong', Pong(from, to).toJson()).toJson());
  }

  Future<void> send(UIBubble uiBubble) async {
    await _awaitServerReady();
    final primitiveBubble = fromUIBubble(uiBubble);
    sendPort.send(ShipCommand('send', jsonEncode(primitiveBubble.toJson(full: true))).toJson());
  }

  Future<void> confirmReceiveFile(String from, String bubbleId) async {
    await _awaitServerReady();
    sendPort.send(ShipCommand(
        'confirmReceiveFile',
        jsonEncode({
          'from': from,
          'bubbleId': bubbleId,
        })).toJson());
  }

  Future<int> getPort() async {
    await _awaitServerReady();
    return await executeSyncTask(syncTasks, 'getPort', () {
      sendPort.send(ShipCommand('getPort').toJson());
    });
  }

  Future<void> cancelReceive(UIBubble uiBubble) async {
    final bubble = fromUIBubble(uiBubble) as PrimitiveFileBubble;
    await updateFileShareState(BubblePool.instance, bubble.id, FileState.cancelled, create: bubble);
  }

  Future<void> resend(UIBubble uiBubble) async {
    await _awaitServerReady();
    sendPort.send(ShipCommand('resend', jsonEncode(fromUIBubble(uiBubble).toJson(full: true))).toJson());
  }

  Future<bool> isServerLiving() async {
    await _awaitServerReady();
    return await executeSyncTask(syncTasks, 'isServerLiving', () {
      sendPort.send(ShipCommand('isServerLiving').toJson());
    });
  }

  Future<bool> restartShipServer() async {
    await _awaitServerReady();
    return await executeSyncTask(syncTasks, 'restartShipServer', () {
      sendPort.send(ShipCommand('restartShipServer').toJson());
    });
  }
  Future<void> cancelSend(UIBubble uiBubble) async {
    await _awaitServerReady();
    sendPort.send(ShipCommand('cancelSend', jsonEncode(fromUIBubble(uiBubble).toJson(full: true))).toJson());
  }

  void _receivePong(Pong pong) {
    _pongListener?.call(pong);
  }

  Future<bool> _awaitServerReady() async {
    return _serverReadyTask.future;
  }

}

Future<T> executeSyncTask<T>(
    Map<String, Completer> taskMap, String key, void Function() task) {
  if (taskMap.containsKey(key)) {
    return taskMap[key]!.future as Future<T>;
  } else {
    final completer = Completer<T>();
    taskMap[key] = completer;
    try {
      task();
    } catch (e, s) {
      talker.error('failed to execute task', e, s);
      taskMap.remove(key)?.completeError(e, s);
    }
    return completer.future;
  }
}

final shipService = ShipServiceProxy.instance;
