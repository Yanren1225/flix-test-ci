import 'package:flix/utils/shared_preferences_portable.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class SettingProvider extends ChangeNotifier {
  static SettingProvider of(BuildContext context, {bool listen = false}) {
    return Provider.of<SettingProvider>(context, listen: listen);
  }

  Future<void> init() async {}

  static Future<String?> getDeviceId() async {
    var sharePreference = await SharedPreferences.getInstance();
    var deviceKey = "device_key";
    var did = const Uuid().v4();
    var saveDid = sharePreference.getString(deviceKey);
    if (saveDid == null || saveDid.isEmpty) {
      sharePreference.setString(deviceKey, did);
    }
    return sharePreference.getString(deviceKey);
  }


}
