
import 'package:dart_mappable/dart_mappable.dart';

part 'reception_notification.mapper.dart';


@MappableClass()
class MessageNotification with MessageNotificationMappable {
  final String from;
  final String bubbleId;

  MessageNotification({required this.from, required this.bubbleId});

  static const fromJson = MessageNotificationMapper.fromJson;
}