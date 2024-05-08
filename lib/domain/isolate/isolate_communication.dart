import 'dart:async';

import 'package:flix/domain/log/flix_log.dart';

void callback<T>(Map<String, Completer> taskMap, String key, T data) {
  final task = taskMap[key] as Completer<T>?;
  if (task != null) {
    task.complete(data);
    taskMap.remove(key);
  }
}


Future<T> executeTaskWithTalker<T>(
    Map<String, Completer> taskMap, String key, void Function() task) async {
  return await executeTask(taskMap, key, () {
    task();
  }, (msg, error, stack) => talker.error(msg, error, stack));
}

Future<T> executeTaskWithPrint<T>(
    Map<String, Completer> taskMap, String key, void Function() task) async {
  return await executeTask(taskMap, key, () {
    task();
  }, (msg, error, stack) => print("msg, $error\n $stack"));
}

Future<T> executeTask<T>(
    Map<String, Completer> taskMap, String key, void Function() task, void Function(String msg, Object error, StackTrace stack) onError) {
  if (taskMap.containsKey(key)) {
    return taskMap[key]!.future as Future<T>;
  } else {
    final completer = Completer<T>();
    taskMap[key] = completer;
    try {
      task();
    } catch (e, s) {
      onError('failed to execute task', e, s);
      taskMap.remove(key)?.completeError(e, s);
    }
    return completer.future;
  }
}