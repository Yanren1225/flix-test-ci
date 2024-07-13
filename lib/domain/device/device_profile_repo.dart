import 'dart:async';

import 'package:flix/network/protocol/device_modal.dart';
import 'package:flix/utils/device_info_helper.dart' as device_utils;
import 'package:flix/utils/device_info_helper.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class DeviceProfileRepo {
  static const deviceNameKey = 'device_name_key';

  DeviceProfileRepo._privateConstructor();

  static final DeviceProfileRepo _instance =
      DeviceProfileRepo._privateConstructor();

  static DeviceProfileRepo get instance {
    return _instance;
  }

  /// 当前设备的id
  late String did;

  String deviceName = '';
  final deviceNameBroadcast = StreamController<String>.broadcast();

  Future<DeviceInfoResult> initDeviceInfo() async {
    var sharePreference = await SharedPreferences.getInstance();
    var deviceKey = "device_key";
    var saveDid = sharePreference.getString(deviceKey);
    if (saveDid == null || saveDid.isEmpty) {
      saveDid = const Uuid().v4();
      sharePreference.setString(deviceKey, saveDid);
    }
    did = saveDid;

    final deviceInfo = await device_utils.getDeviceInfo();
    var savedDeviceName = sharePreference.getString(deviceNameKey);
    if (savedDeviceName == null || savedDeviceName.isEmpty) {
      savedDeviceName = deviceInfo.alias ?? deviceInfo.deviceModel ?? '';
      sharePreference.setString(deviceNameKey, savedDeviceName);
    }

    deviceName = savedDeviceName;
    return device_utils.DeviceInfoResult(
        alias: deviceName,
        deviceType: deviceInfo.deviceType,
        deviceModel: deviceInfo.deviceModel,
        androidSdkInt: deviceInfo.androidSdkInt);
  }

  Future<device_utils.DeviceInfoResult> getDeviceInfo() async {
    final deviceInfo = await device_utils.getDeviceInfo();
    return device_utils.DeviceInfoResult(
        alias: deviceName,
        deviceType: deviceInfo.deviceType,
        deviceModel: deviceInfo.deviceModel,
        androidSdkInt: deviceInfo.androidSdkInt);
  }

  Future<DeviceModal> getDeviceModal(int port) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    var deviceInfo = await getDeviceInfo();
    var deviceModal = DeviceModal(
        alias: deviceInfo.alias ?? '',
        deviceType: deviceInfo.deviceType,
        fingerprint: DeviceProfileRepo.instance.did,
        port: port,
        version: int.parse(packageInfo.buildNumber),
        deviceModel: deviceInfo.deviceModel);
    return deviceModal;
  }

  Future<bool> renameDevice(String name) async {
    final sp = await SharedPreferences.getInstance();
    final result = await sp.setString(deviceNameKey, name);
    if (result) {
      deviceName = name;
      deviceNameBroadcast.add(name);
    }
    return result;
  }

}
