import 'package:flix/domain/device/device_profile_repo.dart';
import 'package:flix/model/ship/primitive_bubble.dart';
import 'package:flix/model/ui_bubble/shareable.dart';

class UIBubble {
  String from;
  String to;
  int time;
  BubbleType type;
  Shareable shareable;
  bool selectable;

  UIBubble({required this.from, required this.to, required this.type, required this.shareable,required this.time, this.selectable = true});

  bool isFromMe(String deviceId) {
    return from == deviceId;
  }

  /// 当前设备是否是发送方
  bool isSender() {
    return isFromMe(DeviceProfileRepo.instance.did);
  }
}
