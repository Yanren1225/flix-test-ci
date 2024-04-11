import 'package:flix/domain/device/device_manager.dart';
import 'package:flix/domain/device/device_profile_repo.dart';

import 'package:flix/model/device_info.dart';
import 'package:flix/utils/device/device_utils.dart';
import 'package:flutter/foundation.dart';

class AndropContext extends ChangeNotifier {
  String deviceId = DeviceProfileRepo.instance.did;
}