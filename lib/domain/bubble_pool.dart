import 'dart:async';

import 'package:androp/model/ship/primitive_bubble.dart';

/// 每个会话一个BubblePool, 用户承担bubble的传递、查找和缓存
/// TODO 传递deviceId.
class BubblePool {
  PrimitiveBubble? _buffer;
  List<PrimitiveBubble> _cache = [];
  final _broadcast = StreamController<PrimitiveBubble>.broadcast();

  void _updateOrAddBubbleToCache(PrimitiveBubble bubble) {
    var i = 0;
    for (i; i < _cache.length; i++) {
      final bubble = _cache[i];
      if (bubble.id == bubble.id) {
        break;
      }
    }
    if (i == _cache.length) {
      _cache.add(bubble);
    } else {
      _cache[i] = bubble;
    }

  }

  void add(PrimitiveBubble bubble) {
    _buffer = bubble;
    _updateOrAddBubbleToCache(bubble);
    _broadcast.add(bubble);
  }

  StreamSubscription<PrimitiveBubble> listen(void onData(PrimitiveBubble bubble, List<PrimitiveBubble> buffer)?,
      {Function? onError, void onDone()?, bool? cancelOnError}) {
    if (_buffer != null) {
      onData?.call(_buffer!, _cache);
    }
    return _broadcast.stream.listen((bubble) => onData?.call(bubble, _cache), onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  PrimitiveBubble? findLastById(String id) {
    PrimitiveBubble? result = null;
    for (final bubble in _cache) {
      if (bubble.id == id) {
        result = bubble;
      }
    }

    return result;
  }
}