import 'dart:math';

import 'package:androp/model/device_info.dart';
import 'package:androp/model/ui_bubble/shared_file.dart';
import 'package:flutter/material.dart';

import '../../model/ui_bubble/ui_bubble.dart';
import '../../utils/bubble_convert.dart';
import 'concert_service.dart';
import 'dart:developer' as dev;

class ConcertProvider extends ChangeNotifier {
  final DeviceInfo deviceInfo;
  late ConcertService _concertService;
  List<UIBubble> bubbles = [];

  ConcertProvider({required this.deviceInfo}) {
    _concertService = ConcertService(collaboratorId: deviceInfo.id);
    _concertService.listenBubbles((bubbles) {
      this.bubbles = bubbles;
      _logLastProgress();
      notifyListeners();
    });
  }

  Future<void> send(UIBubble uiBubble) async {
    return await _concertService.send(uiBubble);
  }

  @override
  void dispose() {
    _concertService.clear();
    super.dispose();
  }

  void _logLastProgress() {
    final last = this.bubbles.lastOrNull;
    if (last != null && last.shareable is SharedFile) {
      dev.log('progress: ${(last.shareable as SharedFile).progress}');
    }
  }

}
