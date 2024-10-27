import 'package:flix/domain/device/device_profile_repo.dart';
import 'package:flix/domain/ship_server/processor/ping_v2_processor.dart';
import 'package:flix/domain/ship_server/ship_service_proxy.dart';
import 'package:flix/network/discover/ping/ping_api.dart';
import 'package:flix/network/nearby_service_info.dart';
import 'package:flix/network/protocol/device_modal.dart';

class PingImpl extends PingApi {
  @override
  Future<DeviceModal?> ping(String ip,int port,String from) async {
    var deviceModal =
        await DeviceProfileRepo.instance.getDeviceModal(port);
    deviceModal.from = from;
    return PingV2Processor.pingV2(ip, port, deviceModal);
  }

  @override
  Future<DeviceModal?> pingWithTime(
      String ip, int port, String from, int time) async {
    var deviceModal = await DeviceProfileRepo.instance.getDeviceModal(port);
    deviceModal.from = from;
    return PingV2Processor.pingV2Time(ip, port, deviceModal, time);
  }
}
