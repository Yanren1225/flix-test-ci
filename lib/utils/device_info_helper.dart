import 'package:flix/network/protocol/device_modal.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:slang/builder/model/enums.dart';
import 'package:slang/builder/utils/string_extensions.dart';


class DeviceInfoResult {
  final String? alias;
  final DeviceType deviceType;
  final String? deviceModel;

  // Used to properly set Edge-to-Edge mode on Android
  // See https://github.com/flutter/flutter/issues/90098
  final int? androidSdkInt;

  DeviceInfoResult({
    required this.alias,
    required this.deviceType,
    required this.deviceModel,
    required this.androidSdkInt,
  });
}

Future<DeviceInfoResult> getDeviceInfo() async {
  final plugin = DeviceInfoPlugin();
  String? alias = null;
  final DeviceType deviceType;
  final String? deviceModel;
  int? androidSdkInt;

  if (kIsWeb) {
    deviceType = DeviceType.web;
    final deviceInfo = await plugin.webBrowserInfo;
    deviceModel = deviceInfo.browserName.humanName;
  } else {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
        deviceType = DeviceType.mobile;
        break;
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.fuchsia:
        deviceType = DeviceType.desktop;
        break;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        final deviceInfo = await plugin.androidInfo;
        // print('version: ${deviceInfo.version}');
        // print('board: ${deviceInfo.board}');
        // print('bootloader: ${deviceInfo.bootloader}');
        // print('brand: ${deviceInfo.brand}');
        // print('device: ${deviceInfo.device}');
        // print('display: ${deviceInfo.display}');
        // print('fingerprint: ${deviceInfo.fingerprint}');
        // print('hardware: ${deviceInfo.hardware}');
        // print('host: ${deviceInfo.host}');
        // print('id: ${deviceInfo.id}');
        // print('manufacturer: ${deviceInfo.manufacturer}');
        // print('model: ${deviceInfo.model}');
        // print('product: ${deviceInfo.product}');
        // print('supported32BitAbis: ${deviceInfo.supported32BitAbis}');
        // print('supported64BitAbis: ${deviceInfo.supported64BitAbis}');
        // print('supportedAbis: ${deviceInfo.supportedAbis}');
        // print('tags: ${deviceInfo.tags}');
        // print('isPhysicalDevice: ${deviceInfo.isPhysicalDevice}');
        // print('systemFeatures: ${deviceInfo.systemFeatures}');
        // print('displayMetrics: ${deviceInfo.displayMetrics}');
        // print('serialNumber: ${deviceInfo.serialNumber}');



        deviceModel = '${deviceInfo.brand} ${deviceInfo.model}';
        androidSdkInt = deviceInfo.version.sdkInt;
        break;
      case TargetPlatform.iOS:
        final deviceInfo = await plugin.iosInfo;
        // 打印iosInfo
        // print('name: ${deviceInfo.name}');
        // print('systemName: ${deviceInfo.systemName}');
        // print('systemVersion: ${deviceInfo.systemVersion}');
        // print('model: ${deviceInfo.model}');
        // print('localizedModel: ${deviceInfo.localizedModel}');
        // print('identifierForVendor: ${deviceInfo.identifierForVendor}');
        // print('isPhysicalDevice: ${deviceInfo.isPhysicalDevice}');
        // print('utsname: ${deviceInfo.utsname}');

        alias = deviceType.name;
        deviceModel = deviceInfo.localizedModel;
        break;
      case TargetPlatform.linux:
        final deviceInfo = await plugin.linuxInfo;
        // 打印linuxInfo
        // print('id: ${deviceInfo.id}');
        // print('idLike: ${deviceInfo.idLike}');
        // print('name: ${deviceInfo.name}');
        // print('prettyName: ${deviceInfo.prettyName}');
        // print('version: ${deviceInfo.version}');
        // print('versionId: ${deviceInfo.versionId}');
        alias = deviceInfo.prettyName;
        deviceModel = deviceInfo.name;
        break;
      case TargetPlatform.macOS:
        final deviceInfo = await plugin.macOsInfo;
        // // 打印macosInfo
        // print('computerName: ${deviceInfo.computerName}');
        // print('hostName: ${deviceInfo.hostName}');
        // print('arch: ${deviceInfo.arch}');
        // print('model: ${deviceInfo.model}');
        // print('kernelVersion: ${deviceInfo.kernelVersion}');
        // print('osRelease: ${deviceInfo.osRelease}');
        alias = deviceInfo.computerName;
        deviceModel = deviceInfo.model;
        break;
      case TargetPlatform.windows:
        final deviceInfo = await plugin.windowsInfo;
        // 打印windowsInfo
        // print('computerName: ${deviceInfo.computerName}');
        // print('windowsEdition: ${deviceInfo.windowsEdition}');
        // print('windowsVersion: ${deviceInfo.windowsVersion}');
        // print('windowsVersionNumber: ${deviceInfo.windowsVersionNumber}');
        // print('windowsBuildNumber: ${deviceInfo.windowsBuildNumber}');
        // print('windowsUBR: ${deviceInfo.windowsUBR}');


        alias = deviceInfo.computerName;
        // deviceModel = deviceInfo.model;
        deviceModel = 'Windows';
        break;
      case TargetPlatform.fuchsia:
        deviceModel = 'Fuchsia';
        break;
    }
  }

  return DeviceInfoResult(
    alias: alias,
    deviceType: deviceType,
    deviceModel: deviceModel,
    androidSdkInt: androidSdkInt,
  );
}

extension on BrowserName {
  String? get humanName {
    switch (this) {
      case BrowserName.firefox:
        return 'Firefox';
      case BrowserName.samsungInternet:
        return 'Samsung Internet';
      case BrowserName.opera:
        return 'Opera';
      case BrowserName.msie:
        return 'Internet Explorer';
      case BrowserName.edge:
        return 'Microsoft Edge';
      case BrowserName.chrome:
        return 'Google Chrome';
      case BrowserName.safari:
        return 'Safari';
      case BrowserName.unknown:
        return null;
    }
  }
}
