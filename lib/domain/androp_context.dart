import 'package:androp/domain/device/device_manager.dart';
import 'package:flutter/foundation.dart';

class AndropContext extends ChangeNotifier {
  String deviceId = DeviceManager.instance.did;
}