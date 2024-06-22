import 'package:shared_preferences/shared_preferences.dart';

class FlixPermissionTape {
  static SharedPreferences? _sp ;

  static Future<SharedPreferences> _getSp() async {
    _sp ??= await SharedPreferences.getInstance();
    return _sp!;
  }

  static Future<bool> applied(ApplyPermissionReason wifiName) async {
    return (await _getSp()).setBool(wifiName.name, true);
  }

  static Future<bool> isApplied(ApplyPermissionReason wifiName) async {
    return (await _getSp()).getBool(wifiName.name) ?? false;
  }

}

enum ApplyPermissionReason {
  wifiName
}