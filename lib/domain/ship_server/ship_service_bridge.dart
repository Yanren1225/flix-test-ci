import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:drift/isolate.dart';
import 'package:flix/domain/bubble_pool.dart';
import 'package:flix/domain/database/database.dart';
import 'package:flix/domain/ship_server/ship_command.dart';
import 'package:flix/domain/ship_server/ship_service.dart';
import 'package:flix/domain/ship_server/ship_service_proxy.dart';
import 'package:flix/model/ship/primitive_bubble.dart';
import 'package:flix/network/protocol/ping_pong.dart';
import 'package:flutter/services.dart';

abstract class ShipServiceDependency {
  Future<String> getNetAddressById(String deviceId);

  Future<bool> isAutoReceive();

  Future<String> getSaveDir();

  void notifyPong(Pong pong);

  void notifyNewBubble(PrimitiveBubble bubble);
}

class ShipServiceBridge extends ShipServiceDependency {
  final SendPort sendPort;
  final ReceivePort receivePort;
  late ShipService _shipService;
  final syncTasks = <String, Completer>{};

  ShipServiceBridge(String did, this.sendPort, this.receivePort) {
    _shipService = ShipService(did: did, dependency: this);
    _listenIsolateMessage();
  }

  Future<void> startServer() async {
    final result = await _shipService.startShipService();
    sendPort.send(ShipCommand('returnStartShipServer', result).toJson());
  }

  void _listenIsolateMessage() {
    receivePort.listen((message) async {
      final shipCommand = ShipCommand.fromJson(message);
      switch (shipCommand.command) {
        case 'isServerLiving':
          final result = await _shipService.isServerLiving();
          sendPort.send(ShipCommand('returnIsServerLiving', result).toJson());
          break;
        case 'startShipServer':
          final result = await _shipService.startShipService();
          sendPort.send(ShipCommand('returnStartShipServer', result).toJson());
          break;
        case 'send':
          final bubble =
              PrimitiveBubble.fromJson(jsonDecode(shipCommand.data!));
          await _shipService.send(bubble);
          break;
        case 'confirmReceiveFile':
          final data = jsonDecode(shipCommand.data!);
          await _shipService.confirmReceiveFile(data['from'], data['bubbleId']);
          break;
        case 'resend':
          final data = PrimitiveFileBubble.fromJson(jsonDecode(shipCommand.data!));
          await _shipService.resend(data);
          break;
        case 'cancelSend':
          final data = PrimitiveFileBubble.fromJson(jsonDecode(shipCommand.data!));
          await _shipService.cancelSend(data);
          break;
        case 'pong':
          final Pong data = Pong.fromJson(shipCommand.data!);
          await _shipService.pong(data.from, data.to);
          break;
        case 'returnNetAddress':
          final args = shipCommand.data as Map<String, dynamic>;
          final deviceId = args['deviceId'] as String;
          final address = args['address'] as String;
          final taskKey = 'getNetAddress-$deviceId';
          callback(syncTasks, taskKey, address);
          break;
        case 'returnIsAutoReceive':
          const taskKey = 'isAutoReceive';
          callback(syncTasks, taskKey, shipCommand.data as bool);
          break;
        case 'returnSaveDir':
          const taskKey = 'getSaveDir';
          callback(syncTasks, taskKey, shipCommand.data as String);
          break;
        case 'getPort':
          _sendServerPort();
          break;
      }
    });
  }

  void _sendServerPort() {
    sendPort.send(ShipCommand('returnPort', _shipService.port).toJson());
  }

  @override
  Future<String> getNetAddressById(String deviceId) async {
    final taskKey = 'getNetAddress-$deviceId';
    return await executeSyncTask(syncTasks, taskKey, () {
      sendPort.send(ShipCommand('getNetAddress', deviceId).toJson());
    });
  }

  @override
  Future<bool> isAutoReceive() async {
    const taskKey = 'isAutoReceive';
    return await executeSyncTask(syncTasks, taskKey, () {
      sendPort.send(ShipCommand('isAutoReceive').toJson());
    });
  }

  @override
  Future<String> getSaveDir() async {
    const taskKey = 'getSaveDir';
    return await executeSyncTask(syncTasks, taskKey, () {
      sendPort.send(ShipCommand('getSaveDir').toJson());
    });
  }

  @override
  void notifyNewBubble(PrimitiveBubble bubble) {
    sendPort.send(ShipCommand('notifyNewBubble', jsonEncode(bubble.toJson(full: true))).toJson());
  }

  @override
  void notifyPong(Pong pong) {
    sendPort.send(ShipCommand('receivePong', pong.toJson()).toJson());
  }
}

void callback<T>(Map<String, Completer> taskMap, String key, T data) {
  final task = taskMap[key] as Completer<T>?;
  if (task != null) {
    task.complete(data);
    taskMap.remove(key);
  }
}

void startServer(var args) async {
  final parentSendPort = args['sendPort'] as SendPort;
  final did = args['did'] as String;
  final _rootToken = args['rootToken'] as RootIsolateToken;
  final _connection = args['connection'] as DriftIsolate;
  BackgroundIsolateBinaryMessenger.ensureInitialized(_rootToken);
  BubblePool.instance.init(AppDatabase(await _connection.connect()));
  final childReceivePort = ReceivePort();
  final childSendPort = childReceivePort.sendPort;
  parentSendPort.send(childSendPort);
  ShipServiceBridge(did, parentSendPort, childReceivePort).startServer();
}
