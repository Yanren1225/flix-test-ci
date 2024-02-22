import 'dart:async';
import 'dart:developer';

import 'package:androp/domain/database/database.dart';
import 'package:androp/model/database/bubble_entity.dart';
import 'package:androp/model/database/text_content.dart';
import 'package:androp/model/ui_bubble/shared_file.dart';
import 'package:androp/model/ship/primitive_bubble.dart';

/// 承担bubble的传递、查找和缓存
/// TODO 传递deviceId. 实现持久化
class BubblePool {

  BubblePool._privateConstruct();

  static final BubblePool _instance = BubblePool._privateConstruct();
  static BubblePool get instance => _instance;

  PrimitiveBubble? _buffer;
  List<PrimitiveBubble> _cache = [];
  final _broadcast = StreamController<PrimitiveBubble>.broadcast();


  void _updateOrAddBubbleToCache(PrimitiveBubble bubble) {
    if (bubble is UpdateFileStateBubble) {
      final _updateStateBubble = bubble as UpdateFileStateBubble;
      final _bubble = findLastById(bubble.id);
      if (_bubble == null) {
        throw StateError('Can\'t find bubble by id: ${bubble.id}');
      }

      if (!(_bubble is PrimitiveFileBubble)) {
        throw StateError('The Bubble with id: ${bubble.id} is not a file bubble');
      }

      final _fileBubble = _bubble! as PrimitiveFileBubble;
      if (_fileBubble.content.state != FileState.receiveCompleted) {
        final updatedBubble = _fileBubble.copy(content: _fileBubble.content.copy(state: _updateStateBubble.content));
        _updateOrAddBubbleToCache(updatedBubble);
      }
    } else {
      var i = 0;
      for (i; i < _cache.length; i++) {
        final item = _cache[i];
        if (item.id == bubble.id) {
          break;
        }
      }
      if (i == _cache.length) {
        _cache.add(bubble);
      } else {
        _cache[i] = bubble;
      }
    }


  }

  Future<void> add(PrimitiveBubble bubble) async {
    log('add bubble ${bubble.id}, $bubble');
    await appDatabase.bubblesDao.insert(bubble);
  }

  StreamSubscription<PrimitiveBubble> listen(void onData(PrimitiveBubble bubble, List<PrimitiveBubble> buffer)?,
      {Function? onError, void onDone()?, bool? cancelOnError}) {
    if (_buffer != null) {
      onData?.call(_buffer!, _cache);
    }
    return _broadcast.stream.listen((bubble) => onData?.call(bubble, _cache), onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  Future<PrimitiveBubble?> findLastById(String id) async {
    return await appDatabase.bubblesDao.getPrimitiveBubbleById(id);
  }


}