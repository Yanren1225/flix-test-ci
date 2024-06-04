import 'dart:async';

import 'package:flix/domain/database/database.dart';
import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/model/ship/primitive_bubble.dart';
import 'package:flix/model/ui_bubble/ui_bubble.dart';
import 'package:quiver/collection.dart';

/// 承担bubble的传递、查找和缓存、订阅分发
class BubblePool {
  BubblePool._privateConstruct();

  static final BubblePool _instance = BubblePool._privateConstruct();

  static BubblePool get instance => _instance;

  static final Map<String, PrimitiveBubble> _cache = LruMap(maximumSize: 60);
  PrimitiveBubble? _buffer;
  final _broadcast = StreamController<PrimitiveBubble>.broadcast();
  late AppDatabase _appDatabase;

  void init(AppDatabase appDatabase) {
    this._appDatabase = appDatabase;
  }

  Future<void> add(PrimitiveBubble bubble) async {
    talker.debug('add bubble $bubble');
    try {
      notify(bubble);
      await _appDatabase.bubblesDao.insert(bubble);
    } catch (e) {
      talker.error('failed to insert bubble into database: ', e);
    }
  }

  void notify(PrimitiveBubble bubble) {
    _cache[bubble.id] = bubble;
    _buffer = bubble;
    _broadcast.add(bubble);
  }

  StreamSubscription<PrimitiveBubble> listen(
      void onData(PrimitiveBubble bubble)?,
      {Function? onError,
      void onDone()?,
      bool? cancelOnError}) {
    if (_buffer != null) {
      onData?.call(_buffer!);
    }
    return _broadcast.stream.listen((bubble) => onData?.call(bubble),
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  Future<PrimitiveBubble?> findLastById(String id) async {
    final cachedBubble = _cache[id];
    if (cachedBubble != null) {
      return cachedBubble;
    } else {
      final persistedBubble =
          await _appDatabase.bubblesDao.getPrimitiveBubbleById(id);
      if (persistedBubble != null) {
        _cache[id] = persistedBubble;
      }
      return persistedBubble;
    }
  }

  Future<void> deleteBubble(UIBubble uiBubble) async {
    return await _appDatabase.bubblesDao
        .deleteBubbleById(uiBubble.shareable.id);
  }
}
