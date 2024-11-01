import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/domain/ship_server/ship_url_helper.dart';
import 'package:flix/model/ship/primitive_bubble.dart';
import 'package:flix/model/ui_bubble/shared_file.dart';
import 'package:flix/utils/compat/compat_util.dart';
import 'package:flix/utils/stream_cancelable.dart';
import 'package:flix/utils/stream_progress.dart';
import 'package:uri_content/uri_content.dart';

typedef CheckCancelCallback = Future<void> Function(String id);

class FileSendState {
  final String id;
  final FileState state;
  final String? path;

  FileSendState({
    required this.id,
    required this.state,
    this.path,
  });
}

class FileSendTask {
  final PrimitiveFileBubble fileBubble;

  String get id => fileBubble.id;

  final _completer = Completer<FileSendState>();

  Future<FileSendState> get wait => _completer.future;

  FileSendTask({
    required this.fileBubble,
  });

  void _complete({
    required FileState state,
    String? path,
  }) {
    _completer.complete(FileSendState(
      id: id,
      state: state,
      path: path,
    ));
  }

  @override
  String toString() {
    return 'FileSendTask{id: $id}';
  }
}

class FileSendQueue {
  static const tag = 'FileSendQueue';

  final _queue = <FileSendTask>[];

  StreamSubscription? _subscription;

  bool get running => _subscription != null;

  int get length => _queue.length;

  final CheckCancelCallback checkCancelCallback;

  FileSendQueue({
    required this.checkCancelCallback,
  });

  Future<void> addTask(FileSendTask task) {
    return addTasks([task]);
  }

  Future<void> addTasks(List<FileSendTask> tasks) async {
    for (final task in tasks) {
      _queue.add(task);
      _subscription ??= _handleQueue().listen((event) {
        talker.info('文件发送队列剩余: $length, 当前: $event');
      });
    }
  }

  void cancelTask(String id) {
    _queue.removeWhere((element) => element.id == id);
  }

  void cancelAllTask() {
    _queue.clear();
  }

  Stream<String> _handleQueue() async* {
    while (_queue.isNotEmpty) {
      final task = _queue.removeAt(0);
      try {
        await _sendFile(task);
        yield task.id;
      } catch (e, stackTrace) {
        talker.error('文件队列发送异常', e, stackTrace);
        yield task.id;
      }
    }
    _subscription?.cancel();
    _subscription = null;
  }

  Future<void> _sendFile(FileSendTask task) async {
    final fileBubble = task.fileBubble;
    try {
      talker.debug(tag, "start=>$fileBubble");
      await _checkCancel(fileBubble.id);
      final shardFile = fileBubble.content.meta;

      await shardFile.resolveFileUri((uri) async {
        var fileSize = shardFile.size;
        final parameters = {
          'share_id': fileBubble.id,
          'file_name': shardFile.name,
        };
        var receiveBytes = 0;
        var supportBreakPoint = CompatUtil.supportBreakPoint(fileBubble.to);
        if (supportBreakPoint) {
          final String mode;
          receiveBytes = fileBubble.content.receiveBytes;
          if (receiveBytes > 0) {
            mode = FileMode.append.toString();
          } else {
            mode = FileMode.write.toString();
          }
          parameters['mode'] = mode;
        }

        String path = "";
        dynamic data;

        if (uri.isScheme("content") && Platform.isAndroid) {
          final uriContent = UriContent();
          data = uriContent.getContentStream(uri).chain((stream) async {
            await _checkCancel(fileBubble.id);
          }).progress(fileBubble, receiveBytes);
        } else {
          path = uri.toFilePath(windows: Platform.isWindows);
          data =
              File(path).openRead(receiveBytes, fileSize).chain((stream) async {
            await _checkCancel(fileBubble.id);
          }).progress(fileBubble, receiveBytes);
        }

        final response = await dio.Dio(dio.BaseOptions(
          baseUrl: ShipUrlHelper.getBaseUrl(fileBubble.to),
          contentType: "application/octet-stream",
        )).post(
          '/file',
          queryParameters: parameters,
          data: data,
        );

        if (response.statusCode == 200) {
          talker.debug(tag, '发送成功 ${response.data.toString()}');
          task._complete(
            state: FileState.sendCompleted,
            path: path,
          );
        } else {
          talker.error(
            tag,
            '发送失败: status code: ${response.statusCode}, ${response.data.toString()}',
          );
          task._complete(state: FileState.sendFailed);
        }
      });
    } on CancelException catch (e, stackTrace) {
      talker.warning('发送取消: ', e, stackTrace);
    } catch (e, stackTrace) {
      talker.error('发送异常: ', e, stackTrace);
      task._complete(state: FileState.sendFailed);
    }
  }

  Future<void> _checkCancel(String id) async {
    await checkCancelCallback(id);
  }
}
