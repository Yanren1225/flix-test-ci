import 'package:flix/domain/device/device_manager.dart';
import 'package:flix/model/device_info.dart';
import 'package:flix/network/protocol/device_modal.dart';

class CompatUtil {
  static bool supportBreakPoint(String fingerprint) {
    DeviceModal? deviceInfo =
        DeviceManager.instance.getDeviceModalById(fingerprint);
    return deviceInfo != null &&
        deviceInfo.version != null &&
        deviceInfo.version! >= 20;
  }

  static bool supportPairDevice(DeviceInfo deviceInfo) {
    return deviceInfo.version != null && deviceInfo.version! >= 20;
  }
}
