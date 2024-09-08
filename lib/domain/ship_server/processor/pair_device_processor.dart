import 'dart:collection';

import 'package:flix/domain/constants.dart';
import 'package:flix/domain/device/device_manager.dart';
import 'package:flix/domain/device/device_profile_repo.dart';
import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/domain/ship_server/ship_service_proxy.dart';
import 'package:flix/domain/ship_server/ship_url_helper.dart';
import 'package:flix/model/intent/trans_intent.dart';
import 'package:http/http.dart' as http;

class PairDeviceProcessor {
  Future<void> askPairDevice(String deviceId, String code) async {
    try {
      talker.debug("pairDevice askPairDevice net",
          "deviceId = $deviceId askPairDevice = $code");
      // 更新接收方状态为接收中
      var uri = Uri.parse(await ShipUrlHelper.intentUrl(deviceId));
      var response = await http.post(
        uri,
        body: TransIntent(
                deviceId: shipService.getDid(),
                bubbleId: '',
                action: TransAction.askPairDevice,
                extra: HashMap<String, String>()
                  ..[Constants.verifyCode] = code
                  ..[Constants.askCode] =
                      await DeviceProfileRepo.instance.getPairCode()
                  ..[Constants.askDevice] = shipService.getDid()
                  ..[Constants.verifyDevice] = deviceId)
            .toJson(),
        headers: {"Content-type": "application/json; charset=UTF-8"},
      );
      if (response.statusCode == 200) {
        talker.debug('请求配对成功: response: ${response.body}');
      } else {
        talker.error(
            '请求配对失败: status code: ${response.statusCode}, ${response.body}');
      }
    } catch (e, stackTrace) {
      talker.error('askPairDevice failed: ', e, stackTrace);
    }
  }

  Future<void> askDeletePairDevice(String deleteDeviceId) async {
    try {
      talker.debug("pairDevice deletePairDevice net",
          "deleteDeviceId = $deleteDeviceId");
      // 更新接收方状态为接收中
      var uri = Uri.parse(await ShipUrlHelper.intentUrl(deleteDeviceId));
      var response = await http.post(
        uri,
        body: TransIntent(
                deviceId: shipService.getDid(),
                bubbleId: '',
                action: TransAction.deletePairDevice,
                extra: HashMap<String, String>()
                  ..[Constants.deleteDeviceId] = deleteDeviceId)
            .toJson(),
        headers: {"Content-type": "application/json; charset=UTF-8"},
      );
      if (response.statusCode == 200) {
        talker.debug('删除配对成功: response: ${response.body}');
      } else {
        talker.error(
            '删除配对失败: status code: ${response.statusCode}, ${response.body}');
      }
    } catch (e, stackTrace) {
      talker.error('askPairDevice failed: ', e, stackTrace);
    }
  }

  Future<void> replyPairDevice(
      String from, String verifyDevice, String verifyCode) async {
    try {
      talker.debug("pairDevice",
          "_replyPairDevice from = $from verifyDevice = $verifyDevice verifyCode = $verifyCode");
      var uri = Uri.parse(await ShipUrlHelper.intentUrl(from));
      var response = await http.post(
        uri,
        body: TransIntent(
                bubbleId: '',
                action: TransAction.confirmPairDevice,
                deviceId: shipService.getDid(),
                extra: HashMap<String, String>()
                  ..[Constants.verifyCode] = verifyCode
                  ..[Constants.verifyDevice] = verifyDevice)
            .toJson(),
        headers: {"Content-type": "application/json; charset=UTF-8"},
      );
      if (response.statusCode == 200) {
        talker.debug('剪贴板配对请求回复成功: response: ${response.body}');
      } else {
        talker.error(
            '剪贴板配对请求回复失败: status code: ${response.statusCode}, ${response.body}');
      }
    } catch (e, stackTrace) {
      talker.error('_replyPairDevice failed: ', e, stackTrace);
    }
  }

  Future<void> replyDeletePairDevice(
      String toDeviceId, String deleteDeviceId) async {
    try {
      talker.debug("pairDevice",
          "_replyPairDevice from = $toDeviceId verifyDevice = $deleteDeviceId");
      var uri = Uri.parse(await ShipUrlHelper.intentUrl(toDeviceId));
      var response = await http.post(
        uri,
        body: TransIntent(
                bubbleId: '',
                action: TransAction.confirmDeletePairDevice,
                deviceId: shipService.getDid(),
                extra: HashMap<String, String>()
                  ..[Constants.deleteDeviceId] = deleteDeviceId)
            .toJson(),
        headers: {"Content-type": "application/json; charset=UTF-8"},
      );
      if (response.statusCode == 200) {
        talker.debug('删除配对请求回复成功: response: ${response.body}');
      } else {
        talker.error(
            '删除请求回复失败: status code: ${response.statusCode}, ${response.body}');
      }
    } catch (e, stackTrace) {
      talker.error('_replyPairDevice failed: ', e, stackTrace);
    }
  }

  Future<void> sendClipboard(String to, String lastText) async {
    try {
      talker.debug("pairDevice", "sendClipboard to = $to");
      var uri = Uri.parse(await ShipUrlHelper.intentUrl(to));
      var response = await http.post(
        uri,
        body: TransIntent(
                bubbleId: '',
                action: TransAction.clipboard,
                extra: HashMap()..[Constants.text] = lastText,
                deviceId: shipService.getDid())
            .toJson(),
        headers: {"Content-type": "application/json; charset=UTF-8"},
      );
      if (response.statusCode == 200) {
        talker.debug('剪贴板发送成功: response: ${response.body}');
      } else {
        talker.error(
            '剪贴板发送失败: status code: ${response.statusCode}, ${response.body}');
      }
    } catch (e, stackTrace) {
      talker.error('剪贴板发送失败 failed: ', e, stackTrace);
    }
  }

  Future<void> deletePairDevice(String deviceId) async {
    await DeviceManager.instance.deletePairDevice(deviceId);
  }
}
