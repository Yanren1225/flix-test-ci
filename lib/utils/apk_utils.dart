import 'package:device_apps/device_apps.dart';

Future<List<Application>> getInstalledApps() async {
  final apps = await DeviceApps.getInstalledApplications(
    includeAppIcons: false, // Set to true if you want to include app icons
  );
  return apps;
}
