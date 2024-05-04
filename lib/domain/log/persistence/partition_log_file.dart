import 'dart:io';

import 'package:flix/domain/log/persistence/log_file.dart';
import 'package:intl/intl.dart';

class PartitionLogFile {
  /**
   * The directory where the log files are stored.
   */
  final String dir;

  /**
   * The maximum size of the log file in bytes.
   * 超出限制后新建文件
   */
  final int singleFileMaxSize;

  /**
   * 所有日志的最大大小 in bytes
   */
  final int maxSize;

  /**
   * 当前日志文件已经使用的大小
   */
  int _currentFileUsedSize = 0;

  /**
   * 所有日志使用的大小
   */
  int _usedSize = 0;

  /**
   * 当前日志文件
   */
  LogFile? logFile = null;

  PartitionLogFile({required this.dir, required this.singleFileMaxSize, required this.maxSize});

  void write(String message) {
    prepareLogFile();
    logFile?.write(message);
    _currentFileUsedSize = logFile?.size() ?? 0;
  }

  void prepareLogFile() {
    assert(maxSize > singleFileMaxSize, "maxSize must be greater than singleFileMaxSize");
    if (logFile == null) {
      List<File> fileEntities = _getAllLogFileEntities();
      final logFile = fileEntities.lastOrNull;
      if (logFile == null) {
        _setLogFile(_createLogFile());
      } else {
        final length = logFile.lengthSync();
        if (length >= singleFileMaxSize) {
          _setLogFile(_createLogFile());
        } else {
          _setLogFile(LogFile(logPath: logFile.path));
        }
      }
      _initUsedSize(fileEntities);
    } else {
      if (_currentFileUsedSize >= singleFileMaxSize) {
        _setLogFile(_createLogFile());
      }
      _usedSize += _currentFileUsedSize;
    }

    _tryCleanLogFile();
  }

  void _tryCleanLogFile() {
    if (_usedSize >= maxSize) {
      // 删除最早的文件
      final logFiles = _getAllLogFileEntities();
      final logFile = logFiles.firstOrNull;
      if (logFile != null) {
        _usedSize -= logFile.lengthSync();
        logFile.deleteSync();
      }
    }
  }

  void _initUsedSize(List<FileSystemEntity> logFileEntities) {
    _usedSize = logFileEntities.fold(0, (previousValue, element) => previousValue + element.statSync().size);
  }

  List<File> _getAllLogFileEntities() {
    return getAllLogFileEntities(dir);
  }

  LogFile _createLogFile() {
    final now = DateTime.now();
    final formatter = DateFormat("yyyy_MM_dd_HH_mm_ss");
    final nowString = formatter.format(now);
    final logFile = LogFile(logPath: "$dir/$nowString.log");
    logFile.create();
    return logFile;
  }

  void _setLogFile(LogFile logFile) {
    this.logFile = logFile;
    _currentFileUsedSize = logFile.size();
  }
}


List<File> getAllLogFileEntities(String dir) {
  final directory = Directory(dir);
  if (!directory.existsSync()) {
    return [];
  }
  final fileEntities =
  directory.listSync(followLinks: false);
  final files = fileEntities.whereType<File>().where((element) => element.path.endsWith(".log")).toList();
  files.sort((a, b) => a.path.compareTo(b.path));
  return files;
}


