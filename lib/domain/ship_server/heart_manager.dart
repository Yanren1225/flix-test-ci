import 'dart:collection';

import 'package:flix/domain/device/device_manager.dart';
import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/domain/ship_server/processor/ping_v2_processor.dart';
import 'package:flix/network/protocol/device_modal.dart';

class HeartManager {
  static const tag = "HeartManager";
  var ping = PingV2Processor();

  HeartManager._privateConstructor();

  static final HeartManager _instance = HeartManager._privateConstructor();

  static HeartManager get instance {
    return _instance;
  }

  static const heartTime = 30;
  var deviceTimeMap = <String, HeartData>{};
  var isStop = false;

  Future<void> startHeartTimer() async {
    try {
      await _startHeartTimerInternal();
    } catch (e, stack) {
      talker.debug("heart error msg = $e stack = $stack");
      await Future.delayed(const Duration(seconds: heartTime));
      startHeartTimer(); // 递归调用
    }
  }

  Future<void> _startHeartTimerInternal() async {
    var deleteDeviceList = [];
    for (var device in DeviceManager.instance.deviceList) {
      if (!deviceTimeMap.containsKey(device.fingerprint)) {
        deviceTimeMap.putIfAbsent(device.fingerprint, () {
          return HeartData(device, DateTime.timestamp().second, 0);
        });
      }
      var heartData = deviceTimeMap[device.fingerprint]!;
      //一次心跳成功
      if (await PingV2Processor.pingV2(heartData.deviceModal.ip,
              heartData.deviceModal.port!, heartData.deviceModal) !=
          null) {
        talker.debug(tag,
            '${heartData.deviceModal.deviceModel}   ${heartData.deviceModal.fingerprint} heartBeat success');
        heartData.loseCount = 0;
      } else {
        //一次心跳失败
        heartData.loseCount++;
        talker.debug(tag,
            '${heartData.deviceModal.deviceModel}   ${heartData.deviceModal.fingerprint} heartBeat failed count = ${heartData.loseCount}');
      }
      if (heartData.loseCount >= HeartData.maxLoseCount) {
        talker.debug(tag,
            '${heartData.deviceModal.deviceModel}   ${heartData.deviceModal.fingerprint} heartBeat remove device');
        deviceTimeMap.remove(device.fingerprint);
        deleteDeviceList.add(device);
      }
    }
    DeviceManager.instance.deviceList.removeAll(deleteDeviceList);
    DeviceManager.instance.notifyDeviceListChanged();
    if (isStop) {
      return;
    }
    // 等待30秒后再次执行
    await Future.delayed(const Duration(seconds: heartTime));
    startHeartTimer(); // 递归调用
  }

  void updateDeviceTime(String fingerPrint) {
    deviceTimeMap[fingerPrint]?.loseCount = 0;
    deviceTimeMap[fingerPrint]?.time = DateTime.timestamp().second;
  }

  void stopTimer() {
    isStop = true;
  }
}

class HeartData {
  static const maxLoseCount = 4;
  DeviceModal deviceModal;
  int time;
  int loseCount;

  HeartData(this.deviceModal, this.time, this.loseCount);
}
