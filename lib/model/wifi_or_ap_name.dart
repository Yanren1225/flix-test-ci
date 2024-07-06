
import 'package:dart_mappable/dart_mappable.dart';

part 'wifi_or_ap_name.mapper.dart';

@MappableClass()
class WifiOrApName with WifiOrApNameMappable {
  final bool isAp;
  final String name;

  WifiOrApName({required this.isAp, required this.name});

  static const fromJson =  WifiOrApNameMapper.fromJson;

}