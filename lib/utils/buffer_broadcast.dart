

import 'dart:async';

/// 带有buffer的broadcast
class BufferBroadcast<E> {
  E? _buffer;
  final _broadcast = StreamController<E>.broadcast();

  BufferBroadcast([Future<E> Function()? init]) {
    init?.call().then((value) => add(value));
  }

  void add(E e) {
    _buffer = e;
    _broadcast.add(e);
  }

  StreamSubscription<E> listen(void Function(E e)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    if (_buffer != null) {
      onData?.call(_buffer as E);
    }
    return _broadcast.stream.listen((e) => onData?.call(e), onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }
}