import 'package:androp/model/ship/primitive_bubble.dart';
import 'package:androp/model/ui_bubble/shareable.dart';

class UIBubble {
  String from;
  String to;
  BubbleType type;
  Shareable shareable;

  UIBubble({required this.from, required this.to, required this.type, required this.shareable});

  bool isFromMe(String deviceId) {
    return from == deviceId;
  }
}
