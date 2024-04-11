import 'package:flix/network/nearby_service_info.dart';

String toNetAddress(String ip, int? port) {
  return '$ip:${port ?? defaultPort}';
}