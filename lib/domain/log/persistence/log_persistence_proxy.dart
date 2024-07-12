import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:flix/domain/isolate/isolate_communication.dart';
import 'package:flix/domain/lifecycle/app_lifecycle.dart';
import 'package:flix/domain/log/persistence/log_persistence.dart';
import 'package:flix/model/isolate/isolate_command.dart';
import 'package:flutter/services.dart';

class LogPersistenceProxy extends LifecycleListener {
  late SendPort _sender;
  final ReceivePort _receiver = ReceivePort();
  final Completer<void> _initWait = Completer();
  bool? _isInitSuccess = false;
  final syncTasks = <String, Completer>{};

  /// 存放未初始化完成前写入的日志
  StringBuffer? _buffer;

  Future<void> init({SendPort? sender}) async {
    _receiver.listen(_receiveMessageFromChild);
    if (sender == null) {
      RootIsolateToken? token = RootIsolateToken.instance;
      print('${DateTime.now()} LogPersistenceProxy init');
      await Isolate.spawn(_startChild, [_receiver.sendPort, token]);
      Future.delayed(const Duration(seconds: 30), () {
        if (_isInitSuccess == null) {
          _isInitSuccess = false;
          _initWait.complete();
        }
      });
    } else {
      _sender = sender;
      _isInitSuccess = true;
      _initWait.complete();
    }
  }

  void _receiveMessageFromChild(var message) {
    if (message is SendPort) {
      _sender = message;
      print('${DateTime.now()} LogPersistenceProxy _receiveMessageFromChild');
      _isInitSuccess = true;
      _initWait.complete();
      return;
    } else if (message is String) {
      final IsolateCommand command = IsolateCommand.fromJson(message);
      final taskKey = command.command;
      callback<void>(syncTasks, taskKey, null);
    }
  }

  void write(String message) {
    if (_isInitSuccess == true) {
      _flushBuffer();
      _sender.send(message);
    } else {
      _buffer ??= StringBuffer();
      _buffer?.write(message);
    }
  }

  void flush() {
    _flush(wait: false);
  }

  Future<void> waitFlush() async {
    await executeTaskWithPrint(syncTasks, 'waitFlush', () async {
      await _initWait.future;
      _flush(wait: true);
    });
  }

  void _flush({bool wait = false}) {
    if (_isInitSuccess == true) {
      _flushBuffer();
      _sender.send(
          wait ? LogPersistenceBridge.WAIT_FLUSH : LogPersistenceBridge.FLUSH);
    }
  }

  @override
  void onLifecycleChanged(AppLifecycleState state) {
    if (_isInitSuccess == true) {
      _flushBuffer();
      _sender.send(state);
    }
  }

  void _flushBuffer() {
    assert(_isInitSuccess == true, 'LogPersistenceProxy is not initialized');
    if (_buffer != null) {
      _sender.send(_buffer.toString());
      _buffer?.clear();
      _buffer = null;
    }
  }

  Future<SendPort?> getLogSender() async {
    await _initWait.future;
    if (_isInitSuccess == true) {
      return _sender;
    } else {
      return null;
    }
  }
}

class LogPersistenceBridge {
  static const FLUSH = 1;
  static const WAIT_FLUSH = 2;

  final LogPersistence _logPersistence = LogPersistence();
  late SendPort _sendPort;

  LogPersistenceBridge(SendPort sendPort) {
    _sendPort = sendPort;
    final ReceivePort receivePort = ReceivePort();
    receivePort.listen(_receiveMessage);
    sendPort.send(receivePort.sendPort);
  }

  void _receiveMessage(var message) {
    if (message is String) {
      _logPersistence.write(message);
    } else if (message is int) {
      if (message == FLUSH) {
        _logPersistence.flush();
      } else if (message == WAIT_FLUSH) {
        _logPersistence
            .flush()
            .then((value) => _sendPort.send(IsolateCommand('waitFlush').toJson()))
            .catchError(() => _sendPort.send(IsolateCommand('waitFlush').toJson()));
      }
    } else if (message is AppLifecycleState) {
      _logPersistence.onLifecycleChanged(message);
    }
  }
}

void _startChild(var message) {
  final childSendPort = message[0] as SendPort;
  final token = message[1] as RootIsolateToken?;
  BackgroundIsolateBinaryMessenger.ensureInitialized(token!);
  LogPersistenceBridge(childSendPort);
}

final logPersistence = LogPersistenceProxy();
