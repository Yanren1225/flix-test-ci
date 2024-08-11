import 'package:flix/network/protocol/device_modal.dart';
import 'package:flix/network/protocol/ping_pong.dart';

abstract class ApInterface {
  Future<void> ping(String ip, int port, DeviceModal from);
  Future<void> pong(DeviceModal from, DeviceModal to);

  void listenPingPong(PingPongListener listener);
}

abstract class PingPongListener {
  void onPing(Ping ping);

  void onPong(Pong pong);
}
