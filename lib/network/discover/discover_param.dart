import 'package:flix/network/discover/discover_manager.dart';
import 'package:flix/network/nearby_service_info.dart';

class DiscoverParam {
  String group = defaultMulticastGroup;
  int port = 8891;
  DeviceDiscoverCallback? callback;
  String? from;

  DiscoverParam.name(this.callback, this.from);
}
