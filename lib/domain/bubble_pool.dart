import 'dart:async';
import 'dart:developer';

import 'package:flix/domain/database/database.dart';
import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/model/database/bubble_entity.dart';
import 'package:flix/model/database/text_content.dart';
import 'package:flix/model/ui_bubble/shared_file.dart';
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



  Future<void> add(PrimitiveBubble bubble) async {
    talker.debug('add bubble $bubble');
    try {
      _cache[bubble.id] = bubble;
      _buffer = bubble;
      _broadcast.add(bubble);
      await appDatabase.bubblesDao.insert(bubble);
    } catch (e) {
      talker.error('failed to insert bubble into database: $e', e);
    }

  }

  StreamSubscription<PrimitiveBubble> listen(void onData(PrimitiveBubble bubble)?,
      {Function? onError, void onDone()?, bool? cancelOnError}) {
    if (_buffer != null) {
      onData?.call(_buffer!);
    }
    return _broadcast.stream.listen((bubble) => onData?.call(bubble), onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  Future<PrimitiveBubble?> findLastById(String id) async {
    final cachedBubble = _cache[id];
    if (cachedBubble != null) {
      return cachedBubble;
    } else {
      final persistedBubble = await appDatabase.bubblesDao.getPrimitiveBubbleById(id);
      if (persistedBubble != null) {
        _cache[id] = persistedBubble;
      }
      return persistedBubble;
    }
  }

  Future<void> deleteBubble(UIBubble uiBubble) async {
    return await appDatabase.bubblesDao.deleteBubbleById(uiBubble.shareable.id);
  }

}