import 'dart:async';
import 'dart:developer';

import 'package:flix/domain/database/database.dart';
import 'package:flix/model/database/bubble_entity.dart';
import 'package:flix/model/database/text_content.dart';
import 'package:flix/model/ui_bubble/shared_file.dart';
import 'package:flix/model/ship/primitive_bubble.dart';

/// 承担bubble的传递、查找和缓存、订阅分发
class BubblePool {

  BubblePool._privateConstruct();

  static final BubblePool _instance = BubblePool._privateConstruct();
  static BubblePool get instance => _instance;

  PrimitiveBubble? _buffer;
  final _broadcast = StreamController<PrimitiveBubble>.broadcast();



  Future<void> add(PrimitiveBubble bubble) async {
    log('add bubble $bubble');
    try {
      _buffer = bubble;
      _broadcast.add(bubble);
      await appDatabase.bubblesDao.insert(bubble);
    } catch (e) {
      log('failed to insert bubble into database: $e');
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
    return await appDatabase.bubblesDao.getPrimitiveBubbleById(id);
  }


}