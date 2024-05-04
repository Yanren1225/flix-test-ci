import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:flix/domain/lifecycle/AppLifecycle.dart';
import 'package:flix/domain/log/persistence/log_persistence.dart';
import 'package:flutter/services.dart';

class LogPersistenceProxy extends LifecycleListener {
  late SendPort _sender;
  late ReceivePort _receiver;
  bool? _isInitSuccess = false;

  /**
   * 存放未初始化完成前写入的日志
   */
  StringBuffer? _buffer;

  Future<void> init() async {
    _receiver = ReceivePort();
    _receiver.listen(_receiveMessageFromChild);
    RootIsolateToken? token = RootIsolateToken.instance;
    print('${DateTime.now()} LogPersistenceProxy init');
    await Isolate.spawn(_startChild, [_receiver.sendPort, token]);
    Future.delayed(const Duration(seconds: 30), () {
      _isInitSuccess ??= false;
    });
  }
  
  void _receiveMessageFromChild(var message) {
    if (message is SendPort) {
      _sender = message;
      print('${DateTime.now()} LogPersistenceProxy _receiveMessageFromChild');
      _isInitSuccess = true;
      return;
    }
  }

  void write(String message) {
    if (_isInitSuccess == true) {
      _flushBuffer();
      _sender.send(message);
    } else {
      if (_buffer == null) {
        _buffer = StringBuffer();
      }
      _buffer?.write(message);
    }
  }

  Future<void> flush() async {
    if (_isInitSuccess == true) {
      _flushBuffer();
      _sender.send(LogPersistenceBridge.FLUSH);
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
}

class LogPersistenceBridge {
  static const FLUSH = 1;

  final LogPersistence _logPersistence = LogPersistence();

  LogPersistenceBridge(SendPort _sendPort) {
    final ReceivePort _receivePort = ReceivePort();
    _receivePort.listen(_receiveMessage);
    _sendPort.send(_receivePort.sendPort);
  }

  void _receiveMessage(var message) {
    if (message is String) {
      _logPersistence.write(message);
    } else if (message is int) {
      if (message == FLUSH) {
        _logPersistence.flush();
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