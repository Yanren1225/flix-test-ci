import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:drift/isolate.dart';
import 'package:flix/domain/bubble_pool.dart';
import 'package:flix/domain/database/database.dart';
import 'package:flix/domain/log/persistence/log_persistence_proxy.dart';
import 'package:flix/model/isolate/isolate_command.dart';
import 'package:flix/domain/ship_server/ship_service.dart';
import 'package:flix/domain/ship_server/ship_service_proxy.dart';
import 'package:flix/model/ship/primitive_bubble.dart';
import 'package:flix/network/protocol/ping_pong.dart';
import 'package:flutter/services.dart';

import '../isolate/isolate_communication.dart';

abstract class ShipServiceDependency {
  Future<String> getNetAddressById(String deviceId);

  Future<bool> isAutoReceive();

  Future<String> getSaveDir();

  void notifyPong(Pong pong);

  void notifyNewBubble(PrimitiveBubble bubble);

  Future<void> markTaskStarted();

  Future<void> markTaskStopped();
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
    sendPort.send(IsolateCommand('returnStartShipServer', result).toJson());
  }

  void _listenIsolateMessage() {
    receivePort.listen((message) async {
      final shipCommand = IsolateCommand.fromJson(message);
      switch (shipCommand.command) {
        case 'isServerLiving':
          final result = await _shipService.isServerLiving();
          sendPort.send(IsolateCommand('returnIsServerLiving', result).toJson());
          break;
        case 'startShipServer':
          final result = await _shipService.startShipService();
          sendPort.send(IsolateCommand('returnStartShipServer', result).toJson());
          break;
        case 'restartShipServer':
          final result = await _shipService.restartShipServer();
          sendPort.send(IsolateCommand('returnRestartShipServer', result).toJson());
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
        case "returnMarkTaskStarted":
          callback<void>(syncTasks, "markTaskStarted", null);
          break;
        case "returnMarkTaskStopped":
          callback<void>(syncTasks, "markTaskStopped", null);
          break;
      }
    });
  }

  void _sendServerPort() {
    sendPort.send(IsolateCommand('returnPort', _shipService.port).toJson());
  }

  @override
  Future<String> getNetAddressById(String deviceId) async {
    final taskKey = 'getNetAddress-$deviceId';
    return await executeTaskWithTalker(syncTasks, taskKey, () {
      sendPort.send(IsolateCommand('getNetAddress', deviceId).toJson());
    });
  }

  @override
  Future<bool> isAutoReceive() async {
    const taskKey = 'isAutoReceive';
    return await executeTaskWithTalker(syncTasks, taskKey, () {
      sendPort.send(IsolateCommand('isAutoReceive').toJson());
    });
  }

  @override
  Future<String> getSaveDir() async {
    const taskKey = 'getSaveDir';
    return await executeTaskWithTalker(syncTasks, taskKey, () {
      sendPort.send(IsolateCommand('getSaveDir').toJson());
    });
  }

  @override
  void notifyNewBubble(PrimitiveBubble bubble) {
    sendPort.send(IsolateCommand('notifyNewBubble', jsonEncode(bubble.toJson(full: true))).toJson());
  }

  @override
  void notifyPong(Pong pong) {
    sendPort.send(IsolateCommand('receivePong', pong.toJson()).toJson());
  }

  @override
  Future<void> markTaskStarted() async {
    return await executeTask(syncTasks, "markTaskStarted", () {
      sendPort.send(IsolateCommand("markTaskStarted").toJson());
    }, (msg, error, stack) { });
  }

  @override
  Future<void> markTaskStopped() async {
    return await executeTask(syncTasks, "markTaskStopped", () {
      sendPort.send(IsolateCommand("markTaskStopped").toJson());
    }, (msg, error, stack) { });
  }
}

void startServer(var args) async {
  final parentSendPort = args['sendPort'] as SendPort;
  final did = args['did'] as String;
  final _rootToken = args['rootToken'] as RootIsolateToken;
  final _connection = args['connection'] as DriftIsolate;
  final _logSender = args['logSender'] as SendPort?;
  BackgroundIsolateBinaryMessenger.ensureInitialized(_rootToken);
  BubblePool.instance.init(AppDatabase(await _connection.connect()));
  logPersistence.init(sender: _logSender);
  final childReceivePort = ReceivePort();
  final childSendPort = childReceivePort.sendPort;
  parentSendPort.send(childSendPort);
  ShipServiceBridge(did, parentSendPort, childReceivePort).startServer();
}
