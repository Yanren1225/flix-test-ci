import 'package:flix/network/multicast_impl.dart';
import 'package:flix/network/protocol/device_modal.dart';

abstract class MultiCastApi {
  Future<void> startScan(String multiGroup, int port,DeviceScanCallback deviceScanCallback);

  Future<void> stop();

  Future<void> ping();

  Future<void> pong(DeviceModal to);

}
