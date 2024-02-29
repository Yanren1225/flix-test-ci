import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';

import 'package:anydrop/domain/bubble_pool.dart';
import 'package:anydrop/domain/database/database.dart';
import 'package:anydrop/domain/ship_server/ship_service.dart';
import 'package:anydrop/utils/stream_progress.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:macos_secure_bookmarks/macos_secure_bookmarks.dart';

import '../../model/ui_bubble/ui_bubble.dart';
import '../../model/ship/primitive_bubble.dart';
import '../../model/ui_bubble/shared_file.dart';
import '../../utils/bubble_convert.dart';
import '../device/device_manager.dart';
import 'package:async/async.dart' show StreamGroup;

/// Concert：表示设备间文件互传的会话
/// 负责：
/// 持久化层和表示层的通信，
/// 文件传输服务和表示层的通信
class ConcertService {
  // 负责承载底层的互传消息
  final String collaboratorId;
  // final _bubblePool = BubblePool.instance;

  StreamSubscription<List<UIBubble>>? streamSubscription;

  ConcertService({required this.collaboratorId});

  void listenBubbles(void Function(List<UIBubble> bubbles) onData) {
    streamSubscription = appDatabase.bubblesDao
        .watchBubblesByCid(collaboratorId)
        .map((bubbles) => bubbles.map((e) => toUIBubble(e)).toList())
        .listen(onData);
  }

  void clear() {
    streamSubscription?.cancel();
  }


  Future<void> send(UIBubble uiBubble) async {
    return await ShipService.instance.send(uiBubble);
  }

  Future<void> confirmReceiveFile(UIBubble uiBubble) async {
    return await ShipService.instance.confirmReceiveFile(uiBubble.from, uiBubble.shareable.id);
  }

  Future<void> cancel(UIBubble uiBubble) async {
    return await ShipService.instance.cancel(uiBubble);
  }

  Future<void> resend(UIBubble uiBubble) async {
    return await ShipService.instance.resend(uiBubble);
  }
}
