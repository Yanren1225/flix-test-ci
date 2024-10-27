import 'package:flix/network/protocol/device_modal.dart';

abstract class PingApi {
  Future<DeviceModal?> ping(String ip, int port, String from);

  Future<DeviceModal?> pingWithTime(String ip, int port, String from, int time);
}
