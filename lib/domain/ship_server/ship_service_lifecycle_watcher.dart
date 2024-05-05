import 'dart:ui';

import 'package:flix/domain/device/device_discover.dart';
import 'package:flix/domain/lifecycle/AppLifecycle.dart';
import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/domain/ship_server/ship_service.dart';
import 'package:flix/domain/ship_server/ship_service_proxy.dart';

class ShipServiceLifecycleWatcher extends LifecycleListener {
  @override
  void onLifecycleChanged(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
      // iOS在省电模式下，app切入后台一段时间后ship server会挂掉。
      // 等app返回前台时检测server状态，若server dead，则重新启动
        shipService.isServerLiving().then((isServerLiving) async {
          talker.debug('isServerLiving: $isServerLiving');
          if (!isServerLiving) {
            if (await shipService.restartShipServer()) {
              DeviceDiscover.instance.startScan(await shipService.getPort());
            }
          } else {
            DeviceDiscover.instance.startScan(await shipService.getPort());
          }
        }).catchError((error, stackTrace) =>
            talker.error('isServerLiving error', error, stackTrace));
        break;
      case AppLifecycleState.paused:
        DeviceDiscover.instance.stop();
        break;
      default:
        break;
    }
  }
}