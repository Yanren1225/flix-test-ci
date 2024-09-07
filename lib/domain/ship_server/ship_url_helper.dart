import 'package:flix/domain/device/device_manager.dart';
import 'package:flix/domain/log/flix_log.dart';

class ShipUrlHelper {
  static Future<String> pingUrl(String ip, int port) async {
    var pongUrl = 'http://$ip:$port/ping';
    return pongUrl;
  }

  static Future<String> pingV2Url(String ip, int port) async {
    var pongUrl = 'http://$ip:$port/ping_v2';
    return pongUrl;
  }

  static Future<String> pongUrl(String deviceId) async {
    var pongUrl = 'http://${getAddressByDeviceId(deviceId)}/pong';
    talker.debug("url==>", "_pongUrl = $pongUrl");
    return pongUrl;
  }

  static Future<String> intentUrl(String deviceId) async {
    var intentUrl = 'http://${getAddressByDeviceId(deviceId)}/intent';
    talker.debug("url==>", "_intentUrl = $intentUrl");
    return intentUrl;
  }

  static String getAddressByDeviceId(String deviceId) {
    return '${DeviceManager.instance.getNetAdressByDeviceId(deviceId)}';
  }
}
