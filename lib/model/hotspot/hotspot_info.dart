import 'package:dart_mappable/dart_mappable.dart';

part 'hotspot_info.mapper.dart';

@MappableClass()
class HotspotInfo with HotspotInfoMappable  {
  final String ssid;
  final String key;

  HotspotInfo({required this.ssid, required this.key});

  static const fromJson =  HotspotInfoMapper.fromJson;


}