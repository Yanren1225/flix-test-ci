import 'dart:collection';

import 'package:dart_mappable/dart_mappable.dart';

part 'trans_intent.mapper.dart';

@MappableClass()
class TransIntent with TransIntentMappable {
  final String deviceId;
  final String bubbleId;
  final TransAction action;
  Map<String,Object>? extra = HashMap<String,Object>();
  TransIntent(
      {required this.deviceId, required this.bubbleId, required this.action,this.extra});

  static const fromJson = TransIntentMapper.fromJson;
}


@MappableEnum()
enum TransAction {
  confirmReceive,
  askBreakPoint,
  confirmBreakPoint,
  askPairDevice,
  confirmPairDevice,
  deletePairDevice,
  confirmDeletePairDevice,
  clipboard,
  // resend,
  reReceive,
  cancel,
}
