import 'package:androp/network/protocol/device_modal.dart';
import 'package:dart_mappable/dart_mappable.dart';

part 'trans_intent.mapper.dart';

@MappableClass()
class TransIntent with TransIntentMappable {
  final String deviceId;
  final String bubbleId;
  final TransAction action;

  TransIntent(
      {required this.deviceId, required this.bubbleId, required this.action});

  static const fromJson = TransIntentMapper.fromJson;
}


@MappableEnum()
enum TransAction {
  confirmReceive;
}
