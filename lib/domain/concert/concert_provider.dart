import 'package:androp/model/device_info.dart';
import 'package:flutter/material.dart';

import '../../model/ui_bubble/ui_bubble.dart';
import '../../utils/bubble_convert.dart';
import 'concert_service.dart';

class ConcertProvider extends ChangeNotifier {
  final DeviceInfo deviceInfo;
  late ConcertService _concertService;
  List<UIBubble> bubbles = [];

  ConcertProvider({required this.deviceInfo}) {
    _concertService = ConcertService(collaboratorId: deviceInfo.id);
    _concertService.listenBubbles((bubbles) {
      this.bubbles = bubbles.map((bubble) => toBubbleEntity(bubble)).toList();
      notifyListeners();
    });
  }

  Future<void> send(UIBubble bubbleEntity) async {
    return await _concertService.send(bubbleEntity);
  }

  @override
  void dispose() {

    super.dispose();
  }

}
