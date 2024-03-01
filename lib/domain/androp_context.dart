import 'package:anydrop/domain/device/device_manager.dart';
import 'package:anydrop/model/device_info.dart';
import 'package:anydrop/utils/device/device_utils.dart';
import 'package:flutter/foundation.dart';

class AndropContext extends ChangeNotifier {
  String deviceId = DeviceManager.instance.did;
}