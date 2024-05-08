// 3分钟写入一次/应用切到后台时立即写入
import 'dart:async';
import 'dart:developer';
import 'dart:ui';

import 'package:flix/domain/lifecycle/AppLifecycle.dart';
import 'package:flix/domain/log/persistence/partition_log_file.dart';
import 'package:path_provider/path_provider.dart';

class LogPersistence extends LifecycleListener {
  final StringBuffer buffer = StringBuffer();
  PartitionLogFile? _logFile;
  Completer<PartitionLogFile>? _logFileCompleter;

  LogPersistence._privateConstruct() {
    Timer.periodic(const Duration(minutes: 3), (timer) {
      _batchWrite();
    });
  }

  static final LogPersistence _instance = LogPersistence._privateConstruct();

  factory LogPersistence() {
    return _instance;
  }

  void write(String message) {
    buffer.write(message);
  }

  /**
   * Flush the buffer to the log file
   */
  Future<void> flush() async {
    await _batchWrite();
  }

  Future<void> _batchWrite() async {
    if (buffer.isNotEmpty) {
      final _buffer = buffer.toString();
      buffer.clear();
      await _prepareLogFile();
      _logFile?.write(_buffer);
      buffer.clear();
    } else {
      buffer.clear();
    }
  }

  // android: /data/user/0/com.ifreedomer.flix/files
  // macos: /Users/heiha/Library/Application Support/com.ifreedomer.flix.mac
  // windows: C:\Users\world\AppData\Roaming\com.ifreedomer\flix
  Future<void> _prepareLogFile() async {
    if (_logFile != null) return;
    if (_logFileCompleter == null) {
      _logFileCompleter = Completer();
      final dir = (await getApplicationSupportDirectory()).path;

      log('log dir: $dir');
      _logFile = PartitionLogFile(dir: '$dir/log', singleFileMaxSize: 1024 * 1024, maxSize: 10 * 1024 * 1024);
      // _logFile = PartitionLogFile(dir: '$dir/log', singleFileMaxSize: 100 * 1024, maxSize: 500 * 1024);
      _logFileCompleter?.complete(_logFile!);
    } else {
      await _logFileCompleter?.future;
    }
  }

  @override
  void onLifecycleChanged(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      _batchWrite();
    }
  }
}
