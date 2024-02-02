import 'package:androp/model/device_info.dart';
import 'package:flutter/material.dart';

import '../../model/bubble_entity.dart';
import '../../utils/bubble_convert.dart';
import 'concert_service.dart';

class ConcertProvider extends ChangeNotifier {
  final DeviceInfo deviceInfo;
  late ConcertService _concertService;
  List<BubbleEntity> bubbles = [];

  ConcertProvider({required this.deviceInfo}) {
    _concertService = ConcertService(collaboratorId: deviceInfo.id);
    _concertService.listenBubbles((bubbles) {
      this.bubbles = bubbles.map((bubble) => toBubbleEntity(bubble)).toList();
      notifyListeners();
    });
  }

  Future<void> send(BubbleEntity bubbleEntity) async {
    return await _concertService.send(bubbleEntity);
  }

  @override
  void dispose() {

    super.dispose();
  }

}
