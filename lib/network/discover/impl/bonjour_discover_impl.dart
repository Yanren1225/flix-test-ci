import 'package:flix/domain/device/device_profile_repo.dart';
import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/network/discover/discover_api.dart';
import 'package:flix/network/discover/discover_param.dart';
import 'package:flix/network/discover/helper/bonjour_helper.dart';

class BonjourDiscoverImpl extends DiscoverApi {
  static const tag = "BonjourDiscoverImpl";
  BonjourHelper bonjourHelper =
      BonjourHelper(deviceProfileRepo: DeviceProfileRepo.instance);

  @override
  Future<void> startScan(DiscoverParam param) async {
    talker.debug(tag, "startScan");
    await bonjourHelper.startScan(param);
  }

  @override
  String getFrom() {
    return "bonjour";
  }

  @override
  void initConfig() {}

  @override
  void stop() {
    talker.debug(tag, "stop");
    bonjourHelper.stop();
  }
}
