import 'dart:math';

import 'package:flix/domain/device/device_manager.dart';
import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/model/device_info.dart';
import 'package:flix/model/ui_bubble/shared_file.dart';
import 'package:flix/network/protocol/device_modal.dart';
import 'package:flix/utils/device/device_utils.dart';
import 'package:flutter/material.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../../model/ui_bubble/ui_bubble.dart';
import 'concert_service.dart';

class ConcertProvider extends ChangeNotifier {
  DeviceInfo deviceInfo;
  late ValueNotifier<String> deviceName;
  late ConcertService _concertService;
  List<UIBubble> bubbles = [];
  final concertMainKey = GlobalKey();

  ConcertProvider({required this.deviceInfo}) {
    deviceName = ValueNotifier(deviceInfo.name);
    _concertService = ConcertService(collaboratorId: deviceInfo.id);
    _concertService.listenBubbles((bubbles) {
      this.bubbles = bubbles;
      _logLastProgress();
      notifyListeners();
    });
    DeviceManager.instance.addDeviceListChangeListener(_onDevicesChanged);
  }

  void _onDevicesChanged(Set<DeviceModal> devices) {
    final current = devices.firstWhereOrNull((element) => element.fingerprint == deviceInfo.id)?.toDeviceInfo();
    if (current != null && current.name != deviceInfo.name) {
      deviceInfo.name = current.name;
      deviceName.value = current.name;
      notifyListeners();
    }
  }

  Future<void> send(UIBubble uiBubble) async {
    return await _concertService.send(uiBubble);
  }

  Future<void> confirmReceive(UIBubble uiBubble) async {
    return await _concertService.confirmReceiveFile(uiBubble);
  }

  Future<void> cancel(UIBubble uiBubble) async {
    return await _concertService.cancel(uiBubble);
  }

  Future<void> resend(UIBubble uiBubble) async {
    return await _concertService.resend(uiBubble);
  }

  @override
  void dispose() {
    DeviceManager.instance.removeDeviceListChangeListener(_onDevicesChanged);
    _concertService.clear();
    super.dispose();
  }

  void _logLastProgress() {
    final last = this.bubbles.lastOrNull;
    if (last != null && last.shareable is SharedFile) {
      talker.debug('progress: ${(last.shareable as SharedFile).progress}');
    }
  }

}
