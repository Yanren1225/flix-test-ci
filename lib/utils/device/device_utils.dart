import 'package:flix/model/device_info.dart';
import 'package:flix/network/protocol/device_modal.dart';

extension DeviceUtils on DeviceModal {
  //   DeviceInfo("0", 0, 'Xiaomi 14', 'phone.webp'),
  //   DeviceInfo("1", 1, 'RedmiBook Pro 15 锐龙版', 'pc.webp'),
  //   DeviceInfo("2", 2, 'Xiaomi Pad 14 Max', 'pad.webp'),
  //   DeviceInfo("3", 3, 'Xiaomi Watch S3', 'watch.webp')
  DeviceInfo toDeviceInfo() {
    final int type;
    final String icon;
    switch (this.deviceType) {
      case null:
        type = 1;
        icon = 'pc.webp';
        break;
      case DeviceType.mobile:
        type = 0;
        icon = 'phone.webp';
        break;

      case DeviceType.desktop:
        type = 1;
        icon = 'pc.webp';
        break;

      case DeviceType.web:
        type = 0;
        icon = 'phone.webp';
        break;

      case DeviceType.headless:
        type = 1;
        icon = 'pc.webp';
        break;

      case DeviceType.server:
        type = 1;
        icon = 'pc.webp';
        break;
    }

    final String name;
    if (this.alias.isNotEmpty) {
      name = this.alias;
    } else {
      name = this.deviceModel ?? "Unknown";
    }

    return DeviceInfo(this.fingerprint, type, name, icon);
  }
}
