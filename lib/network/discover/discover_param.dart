import 'package:flix/network/discover/discover_manager.dart';
import 'package:flix/network/nearby_service_info.dart';

class DiscoverParam {
  String group = defaultMulticastGroup;
  int port = 8891;
  DeviceDiscoverCallback? onData;
  DeviceDiscoverFinishCallback? onDone;
  DeviceDiscoverErrorCallback? onError;
  String? from;

  DiscoverParam.name(this.onData, this.from);

  DiscoverParam(this.group, this.port, this.onData,
      this.onDone,this.onError, this.from);
}
