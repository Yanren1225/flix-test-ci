

import 'dart:async';

/// 带有buffer的broadcast
class BufferBroadcast<E> {
  E? _buffer;
  final _broadcast = StreamController<E>.broadcast();


  void add(E e) {
    _buffer = e;
    _broadcast.add(e);
  }

  StreamSubscription<E> listen(void onData(E e)?,
      {Function? onError, void onDone()?, bool? cancelOnError}) {
    if (_buffer != null) {
      onData?.call(_buffer!);
    }
    return _broadcast.stream.listen((e) => onData?.call(e), onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }
}