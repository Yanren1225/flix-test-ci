
import 'package:dart_mappable/dart_mappable.dart';

part 'reception_notification.mapper.dart';


@MappableClass()
class ReceptionNotification with ReceptionNotificationMappable {
  final String from;
  final String bubbleId;

  ReceptionNotification({required this.from, required this.bubbleId});

  static const fromJson = ReceptionNotificationMapper.fromJson;
}