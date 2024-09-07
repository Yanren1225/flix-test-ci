import 'dart:collection';

import 'package:flix/domain/bubble_pool.dart';
import 'package:flix/domain/constants.dart';
import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/domain/settings/settings_repo.dart';
import 'package:flix/domain/ship_server/ship_service.dart';
import 'package:flix/domain/ship_server/ship_service_proxy.dart';
import 'package:flix/model/intent/trans_intent.dart';
import 'package:flix/model/ship/primitive_bubble.dart';
import 'package:flix/utils/file/file_utils.dart';
import 'package:http/http.dart' as http;

import '../../../model/ui_bubble/shared_file.dart';

class BreakPointProcessor {
  Future<void> askBreakPoint(PrimitiveBubble bubble) async {
    try {
      talker.debug("breakPoint=>", "askBreakPoint = ${bubble.to}");
      // 更新接收方状态为接收中
      await updateBubbleShareState(
          BubblePool.instance, bubble.id, FileState.inTransit,
          waitingForAccept: true);
      var uri = Uri.parse(await shipService.intentUrl(bubble.to));

      var response = await http.post(
        uri,
        body: TransIntent(
                deviceId: shipService.getDid(),
                bubbleId: bubble.id,
                action: TransAction.askBreakPoint,
                extra: HashMap<String, Object>())
            .toJson(),
        headers: {"Content-type": "application/json; charset=UTF-8"},
      );

      if (response.statusCode == 200) {
        talker.debug('接收成功: response: ${response.body}');
      } else {
        talker.error(
            '接收失败: status code: ${response.statusCode}, ${response.body}');
      }
    } catch (e, stackTrace) {
      talker.error('confirmReceiveFile failed: ', e, stackTrace);
    }
  }

  Future<void> confirmBreakPoint(String from, String bubbleId) async {
    try {
      await updateBubbleShareState(
          BubblePool.instance, bubbleId, FileState.inTransit,
          waitingForAccept: false);
      var uri = Uri.parse(await shipService.intentUrl(from));
      var bubble = (await BubblePool.instance.findLastById(bubbleId));
      var receiveBytesMap = HashMap<String, Object>();
      if (bubble is PrimitiveFileBubble) {
        await _confirmBreakPointFileCreate(bubble, receiveBytesMap);
      } else if (bubble is PrimitiveDirectoryBubble) {
        var filesMaps = HashMap<String, Object>();
        for (var fileBubble in bubble.content.fileBubbles) {
          final HashMap<String, Object> temp = HashMap<String, Object>();
          await _confirmBreakPointFileCreate(fileBubble, temp);
          filesMaps[fileBubble.id] = temp;
        }
        receiveBytesMap[Constants.receiveMaps] = filesMaps;
      } else {
        talker.error('confirmBreakPoint 接收失败: 异常类型 = $bubble');
        return;
      }
      talker.debug(
          "breakPoint", "confirmBreakPoint receiveBytes = $receiveBytesMap");
      var response = await http.post(
        uri,
        body: TransIntent(
                bubbleId: bubbleId,
                action: TransAction.confirmBreakPoint,
                extra: receiveBytesMap,
                deviceId: from)
            .toJson(),
        headers: {"Content-type": "application/json; charset=UTF-8"},
      );

      if (response.statusCode == 200) {
        talker.debug('接收成功: response: ${response.body}');
      } else {
        talker.error(
            '接收失败: status code: ${response.statusCode}, ${response.body}');
      }
    } catch (e, stackTrace) {
      talker.error('confirmReceiveFile failed: ', e, stackTrace);
    }
  }

  Future<void> _confirmBreakPointFileCreate(PrimitiveFileBubble fileBubble,
      HashMap<String, Object> receiveBytesMap) async {
    var filePath = fileBubble.content.meta.path ?? "";
    filePath = SettingsRepo.instance.savedDir + filePath;
    if (filePath.isNotEmpty == true) {
      var tempFile = await FileUtils.getOrCreateTempWithFolder(
          filePath, fileBubble.content.meta.name);
      int fileLen = 0;
      if (await tempFile.exists()) {
        fileLen = await tempFile.length();
      }
      receiveBytesMap[Constants.receiveBytes] = fileLen;
      fileBubble.content.receiveBytes = fileLen;
      BubblePool.instance.add(fileBubble);
    }
  }
}
