import 'package:flix/network/protocol/device_modal.dart';
import 'package:flix/network/protocol/ping_pong.dart';

abstract class ApInterface {
  Future<void> pong(DeviceModal from, DeviceModal to);

  void listenPong(PongListener listener);
}

typedef PongListener = void Function(Pong pong);