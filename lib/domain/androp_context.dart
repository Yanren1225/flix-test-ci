import 'package:flix/domain/device/device_profile_repo.dart';
import 'package:flutter/foundation.dart';

class AndropContext extends ChangeNotifier {
  String deviceId = DeviceProfileRepo.instance.did;
}