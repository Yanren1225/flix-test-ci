import 'package:flix/network/multicast_impl.dart';
import 'package:flix/network/protocol/device_modal.dart';

abstract class MultiCastApi {
  void startScan(String multiGroup, int port,DeviceScanCallback deviceScanCallback);

  void disconnect();

  Future<void> ping();

  Future<void> pong(DeviceModal to);

  Future<DeviceModal> getDeviceModal();
}
