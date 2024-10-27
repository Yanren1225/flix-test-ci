import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart' as dio;
import 'package:flix/domain/bubble_pool.dart';
import 'package:flix/domain/clipboard/flix_clipboard_manager.dart';
import 'package:flix/domain/constants.dart';
import 'package:flix/domain/device/device_manager.dart';
import 'package:flix/domain/device/device_profile_repo.dart';
import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/domain/physical_lock.dart';
import 'package:flix/domain/settings/settings_repo.dart';
import 'package:flix/domain/ship_server/processor/ping_v2_processor.dart';
import 'package:flix/domain/ship_server/ship_url_helper.dart';
import 'package:flix/domain/ship_server/simple_resource_entity.dart';
import 'package:flix/model/intent/trans_intent.dart';
import 'package:flix/model/ship/primitive_bubble.dart';
import 'package:flix/model/ui_bubble/shared_file.dart';
import 'package:flix/network/discover/network_connect_manager.dart';
import 'package:flix/network/nearby_service_info.dart';
import 'package:flix/network/protocol/device_modal.dart';
import 'package:flix/utils/compat/compat_util.dart';
import 'package:flix/utils/drawin_file_security_extension.dart';
import 'package:flix/utils/file/file_helper.dart';
import 'package:flix/utils/file/file_utils.dart';
import 'package:flix/utils/stream_cancelable.dart';
import 'package:flix/utils/stream_progress.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:mutex/mutex.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:uri_content/uri_content.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import 'processor/break_point_processor.dart';
import 'processor/pair_device_processor.dart';

class ShipService{
  final String sendTag = "SendFile";
  final String did;
  final _bubblePool = BubblePool.instance;
  final lock = Mutex();
  var _longTaskCount = 0;
  HttpServer? _server;
  int port = defaultPort;
  var breakPointProcessor = BreakPointProcessor();
  var pairDeviceProcessor = PairDeviceProcessor();
  ShipService({required this.did}) {
    talker.debug("ShipService", "did = $did");
  }


  Future<bool> startShipService() async {
    try {
      return await lock.protect(() async {
        return await _startShipServer();
      });
    } catch (e, stackTrace) {
      talker.error('start ship server failed', e, stackTrace);
      return false;
    }
  }

  Future<bool> isServerLiving() async {
    try {
      var uri = Uri.parse('http://127.0.0.1:$port/heartbeat');
      var response = await http
          .post(
            uri,
          )
          .timeout(const Duration(seconds: 1));
      if (response.statusCode == 200) {
        return true;
      } else {
        talker.debug(
            'isServerLiving pong failed: status code: ${response.statusCode}, ${response.body}');
        return false;
      }
    } on TimeoutException catch (_) {
      talker.error('check server living timeout');
      return false;
    } catch (e, stackTrace) {
      talker.error('check server living error: ', e, stackTrace);
      return false;
    }
  }

  Future<bool> restartShipServer() async {
    try {
      return await lock.protect(() async {
        talker.debug('restart sever: $_server');
        await _server?.close(force: true);
        return await _startShipServer();
      });
    } catch (e, stacktrace) {
      talker.error('restart server failed: ', e, stacktrace);
    }
    return false;
  }

  Future<void> send(PrimitiveBubble primitiveBubble) async {
    try {
      // await checkCancel(uiBubble.shareable.id);
      talker.debug(sendTag,"send primitiveBubble = $primitiveBubble");
      switch (primitiveBubble.type) {
        case BubbleType.Text:
          await _bubblePool.add(primitiveBubble);
          await _sendBasicBubble(primitiveBubble);
          break;
        case BubbleType.Image:
        case BubbleType.Video:
        case BubbleType.File:
        case BubbleType.App:
          await _sendFileBubble(primitiveBubble as PrimitiveFileBubble);
          break;
        case BubbleType.Directory:
          await _sendDirectoryBubble(primitiveBubble as PrimitiveDirectoryBubble);
        default:
          throw UnimplementedError();
      }
    } on CancelException catch (e, stackTrace) {
      talker.warning('outer 取消发送: ', e, stackTrace);
    } catch (e, stackTrace) {
      talker.error('outer send failed: ', e, stackTrace);
    }
  }

  Future<void> confirmReceiveBubble(String from, String bubbleId) async {
    try {
      // 更新接收方状态为接收中
      await updateBubbleShareState(_bubblePool, bubbleId, FileState.inTransit,
          waitingForAccept: false);
      var uri = Uri.parse(await ShipUrlHelper.intentUrl(from));

      var response = await http.post(
        uri,
        body: TransIntent(
                deviceId: did,
                bubbleId: bubbleId,
                action: TransAction.confirmReceive,
                extra: HashMap<String, Object>())
            .toJson(),
        headers: {"Content-type": "application/json; charset=UTF-8"},
      );

      if (response.statusCode == 200) {
        talker.debug('$bubbleId confirm receive: response: ${response.body}');
      } else {
        talker.error(
            '$bubbleId comfirm receive: status code: ${response.statusCode}, ${response.body}');
      }
    } catch (e, stackTrace) {
      talker.error('confirmReceiveFile failed: ', e, stackTrace);
    }
  }

  Future<void> cancelSend(PrimitiveBubble bubble) async {
    talker.debug("cancelSend4 =>$bubble");
    await updateBubbleShareState(_bubblePool, bubble.id, FileState.cancelled,
        create: bubble);
    await _sendCancelMessage(bubble.id, bubble.to);
  }

  Future<void> resend(PrimitiveBubble bubble) async {
    await updateBubbleShareState(
        _bubblePool, bubble.id, FileState.waitToAccepted,
        create: bubble);
    //已经发送过，c/s都有此记录
    talker.debug("resend",
        "getBreakPoint receiveBytes = ${bubble.content.progress}");
    if (bubble is PrimitiveFileBubble) {
      if (CompatUtil.supportBreakPoint(bubble.to) &&
          bubble.content.progress > 0) {
        talker.debug("breakPoint", "start ask");
        breakPointProcessor.askBreakPoint(bubble);
        return;
      }
      var state = FileState.waitToAccepted;
      if (bubble.groupId?.isNotEmpty == true) {
        await updateBubbleShareState(_bubblePool, bubble.id, FileState.inTransit,
            waitingForAccept: true);
        state = FileState.inTransit;
      }
      await _sendBasicBubble(
          bubble.copy(content: bubble.content.copy(state: state)));
    } else if (bubble is PrimitiveDirectoryBubble) {
      if (CompatUtil.supportBreakPoint(bubble.to) &&
          bubble.content.progress > 0) {
        talker.debug("breakPoint", "start dir ask");
        breakPointProcessor.askBreakPoint(bubble);
        return;
      }
      var state = FileState.waitToAccepted;
      if (bubble.groupId?.isNotEmpty == true) {
        await updateBubbleShareState(_bubblePool, bubble.id, FileState.inTransit,
            waitingForAccept: true);
        state = FileState.inTransit;
      }
      await _sendBasicBubble(bubble.copy(
          content: bubble.content.copy(state: state),groupId: bubble.groupId));
    }
  }

  Future<void> reReceive(PrimitiveBubble bubble) async {
    try {
      await updateBubbleShareState(_bubblePool, bubble.id, FileState.waitToAccepted);
      var uri = Uri.parse(await ShipUrlHelper.intentUrl(bubble.to));

      var response = await http.post(
        uri,
        body: TransIntent(
            deviceId: did,
            bubbleId: bubble.id,
            action: TransAction.reReceive,
            extra: {}).toJson(),
        headers: {"Content-type": "application/json; charset=UTF-8"},
      );

      if (response.statusCode == 200) {
        talker.debug('reReceive发送成功: response: ${response.body}');
      } else {
        talker.error(
            'reReceive 发送失败: status code: ${response.statusCode}, ${response.body}');
      }
    } catch (e, stackTrace) {
      talker.error('reReceive failed: ', e, stackTrace);
    }
  }

  Future<void> _sendCancelMessage(String bubbleId, String to) async {
    try {
      talker.debug("cancelSend 5");
      talker.debug('_sendCancelMessage=> to = $to intent = ${ShipUrlHelper.intentUrl(to)}');
      var uri = Uri.parse(await ShipUrlHelper.intentUrl(to));

      var response = await http.post(
        uri,
        body: TransIntent(
            deviceId: did,
            bubbleId: bubbleId,
            action: TransAction.cancel,
            extra: {}).toJson(),
        headers: {"Content-type": "application/json; charset=UTF-8"},
      );

      if (response.statusCode == 200) {
        talker.debug('sendCancelMessage发送成功: response: ${response.body}');
      } else {
        talker.error(
            'sendCancelMessage发送失败: status code: ${response.statusCode}, ${response.body}');
      }
    } catch (e, stackTrace) {
      talker.error('sendCancelMessage failed: ', e, stackTrace);
    }
  }

  Future<bool> _startShipServer() async {
    var app = Router();
    app.post('/bubble', _receiveBubble);
    app.post('/intent', _receiveIntent);
    app.post('/file', _receiveFile);
    app.post('/ping_v2', PingV2Processor.receivePingV2);
    app.post('/heartbeat', _heartbeat);

    // 尝试三次启动
    final tmp =
        await _startShipServerInner(app, defaultPort, 'first', () async {
      return await _startShipServerInner(app, defaultPort + 1, 'second',
          () async {
        return await _startShipServerInner(app, defaultPort + 2, 'third', () async {
          return null;
        });
      });
    });

    if (tmp != null) {
      _server = tmp;
      return true;
    }
    return false;
  }

  Future<HttpServer?> _startShipServerInner(Router app, int serverPort,
      String tag, Future<HttpServer?> Function() onFailed) async {
    try {
      final server = await io.serve(app, '0.0.0.0', serverPort, shared: true);
      talker.debug('Serving at http://0.0.0.0:$serverPort');
      port = serverPort;
      return server;
    } catch (e, stack) {
      talker.error('$tag start server at http://0.0.0.0:$serverPort failed ', e, stack);
      return await onFailed();
    }
  }

  Future<void> _sendBasicBubble(PrimitiveBubble primitiveBubble) async {
    try {
      await _checkCancel(primitiveBubble.id);
      var uri = Uri.parse(await ShipUrlHelper.getSendBubbleUrl(primitiveBubble));

      final body = jsonEncode(
          primitiveBubble.toJson(pathSaveType: FilePathSaveType.relative));
      talker.debug("_sendBasicBubble body=$body");
      var response = await http.post(
        uri,
        body: body,
        headers: {"Content-type": "application/json; charset=UTF-8"},
      );

      if (response.statusCode == 200) {
        talker.debug('发送成功: response: ${response.body}');
      } else {
        talker.debug(
            '发送失败: status code: ${response.statusCode}, ${response.body}');
      }
    } on CancelException catch (e, stackTrace) {
      talker.warning('取消发送 bubble: ', e, stackTrace);
    } catch (e, stackTrace) {
      talker.error('send bubble failed', e, stackTrace);
    }
  }

  Future<void> _sendFileBubble(PrimitiveFileBubble fileBubble,
      {FileState? fileState = FileState.waitToAccepted}) async {
    try {
      var fileBubble0 = fileBubble.copy(content: fileBubble.content.copy(state: fileState));
      await _bubblePool.add(fileBubble0);
      await _checkCancel(fileBubble.id);
      // send with no path
      await _sendBasicBubble(fileBubble0.copy(
          content: fileBubble0.content
              .copy(meta: fileBubble0.content.meta.copy(path: fileBubble0.content.meta.path))));
    } on CancelException catch (e, stackTrace) {
      talker.warning('取消发送文件: ', e, stackTrace);
    } catch (e, stackTrace) {
      talker.error('发送异常: ', e, stackTrace);
      updateBubbleShareState(_bubblePool, fileBubble.id, FileState.sendFailed);
    }
  }

  Future<void> _sendDirectoryBubble(PrimitiveDirectoryBubble directoryBubble) async {
    try {
      var directoryBubble0 = directoryBubble.copy(
          content: directoryBubble.content.copy(state: FileState.waitToAccepted));
      await _bubblePool.add(directoryBubble0);
      await _checkCancel(directoryBubble.id);
      await _sendBasicBubble(directoryBubble0.copy(
          content: directoryBubble0.content.copy(
              meta: directoryBubble0.content.meta.copy(path: directoryBubble0.content.meta.path))));
    } on CancelException catch (e, stackTrace) {
      talker.warning('取消发送文件夹: ', e, stackTrace);
    } catch (e, stackTrace) {
      talker.error('发送异常: ', e, stackTrace);
      updateBubbleShareState(_bubblePool, directoryBubble.id, FileState.sendFailed);
    }
  }

  Future<void> _checkCancel(String bubbleId,
      [void Function()? onCanceled]) async {
    final bubble = await _bubblePool.findLastById(bubbleId);
    if (bubble is PrimitiveFileBubble) {
      if (bubble.content.state == FileState.cancelled) {
        onCanceled?.call();
        throw CancelException();
      }
    } else if (bubble is PrimitiveDirectoryBubble) {
      if (bubble.content.state == FileState.cancelled) {
        onCanceled?.call();
        throw CancelException();
      }
    } else if (bubble == null) {
      throw CancelException('bubble: $bubbleId deleted');
    }
  }

  Future<Response> _receiveBubble(Request request) async {
    try {
      var body = await request.readAsString();
      var data = jsonDecode(body) as Map<String, dynamic>;
      var bubble = PrimitiveBubble.fromJson(data);
      talker.debug("_receiveBubble===>", data);
      // _notifyNewBubble(bubble);
      if (await SettingsRepo.instance.getAutoReceiveAsync() &&
          (bubble is PrimitiveFileBubble || bubble.type == BubbleType.Directory)) {
        await _bubblePool.add(bubble);
        await confirmReceiveBubble(bubble.from, bubble.id);
      } else if (bubble is PrimitiveFileBubble) {
        final before = await _bubblePool.findLastById(bubble.id);
        if (before is PrimitiveFileBubble) {
          // 如果是重新发送，判断是否已经接收，已经接受直接确认接受，否则继续等待接受。
          if (!before.content.waitingForAccept) {
            await _bubblePool.add(bubble);
            await confirmReceiveBubble(bubble.from, bubble.id);
          } else {
            await _bubblePool.add(bubble.copy(
                content: bubble.content.copy(state: FileState.waitToAccepted)));
          }
        } else {
          await _bubblePool.add(bubble);
        }
      } else if (bubble is PrimitiveDirectoryBubble) {
        final before = await _bubblePool.findLastById(bubble.id);
        if (before is PrimitiveDirectoryBubble) {
          // 如果是重新发送，判断是否已经接收，已经接受直接确认接受，否则继续等待接受。
          if (!before.content.waitingForAccept) {
            await _bubblePool.add(bubble);
            await confirmReceiveBubble(bubble.from, bubble.id);
          } else {
            await _bubblePool.add(bubble.copy(
                content: bubble.content.copy(state: FileState.waitToAccepted),groupId: bubble.groupId));
          }
        } else {
          await _bubblePool.add(bubble);
        }
      } else {
        await _bubblePool.add(bubble);
      }
      return Response.ok('received bubble');
    } catch (e, stackTrace) {
      talker.error('receive bubble failed', e, stackTrace);
      return Response.internalServerError(body: 'receive bubble failed');
    }
  }

  Future<void> _sendFileReal(PrimitiveFileBubble fileBubble) async {
    if (fileBubble.content.state == FileState.sendCompleted) {
      talker.debug(sendTag, "_sendFileReal sendCompleted");
      return;
    }
    _addLongTask();
    try {
      talker.debug(sendTag,"start=>$fileBubble");
      await _checkCancel(fileBubble.id);
      final shardFile = fileBubble.content.meta;

      await shardFile.resolveFileUri((uri) async {
        var fileSize = shardFile.size;

        final parameters = {
          'share_id': fileBubble.id,
          'file_name': shardFile.name,
        };
        var receiveBytes = 0;
        var supportBreakPoint = CompatUtil.supportBreakPoint(fileBubble.to);
        if (supportBreakPoint) {
          final String mode;
          receiveBytes = fileBubble.content.receiveBytes;
          if (receiveBytes > 0) {
            mode = FileMode.append.toString();
          } else {
            mode = FileMode.write.toString();
          }
          parameters['mode'] = mode;
        }

        String path = "";
        dynamic data;

        if (uri.isScheme("content") && Platform.isAndroid) {
          final uriContent = UriContent();
          data = uriContent.getContentStream(uri).chain((stream) async {
            await _checkCancel(fileBubble.id);
          }).progress(fileBubble, receiveBytes);


        } else {
          path = uri.toFilePath(windows: Platform.isWindows);

          data = File(path).openRead(receiveBytes, fileSize).chain((stream) async {
            await _checkCancel(fileBubble.id);
          }).progress(fileBubble, receiveBytes);
        }

        final response = await dio.Dio(dio.BaseOptions(baseUrl: ShipUrlHelper.getBaseUrl(fileBubble.to),contentType: "application/octet-stream"))
            .post(
          '/file',
          queryParameters: parameters,
          data: data,
        );

        if (response.statusCode == 200) {
          talker.debug(sendTag, '发送成功 ${response.data.toString()}');
          updateBubbleShareState(
              _bubblePool, fileBubble.id, FileState.sendCompleted);
          if (path.isNotEmpty) {
            _deleteCachedFile(fileBubble, path);
          }
        } else {
          talker.error(sendTag,
              '发送失败: status code: ${response.statusCode}, ${response.data.toString()}');
          updateBubbleShareState(
              _bubblePool, fileBubble.id, FileState.sendFailed);
        }

      });
    } on CancelException catch (e, stackTrace) {
      talker.warning('发送取消: ', e, stackTrace);
    } catch (e, stackTrace) {
      talker.error('发送异常: ', e, stackTrace);
      updateBubbleShareState(_bubblePool, fileBubble.id, FileState.sendFailed);
    }
    _removeLongTask();
  }

  Future<void> _deleteCachedFile(
      PrimitiveFileBubble fileBubble, String path) async {
    try {
      if (await isInCacheOrTmpDir(path) && (fileBubble.type == BubbleType.File || fileBubble.type == BubbleType.Directory)) {
        talker.info('delete cached file: $path');
        await File(path).delete();
        talker.info('delete cached file successfully: $path');
      }
    } catch (e, stackTrace) {
      talker.error('delete cached file failed', e, stackTrace);
    }
  }

  Future<Response> _receiveFile(Request request) async {
    _addLongTask();
    PrimitiveFileBubble? bubble;
    String? shareId;
    try {
      shareId = request.requestedUri.queryParameters['share_id'];
      assert(shareId != null, 'shareId can\'t be null');
      final bubble0 = await _bubblePool.findLastById(shareId!);
      if (bubble0 == null) {
        throw StateError(
            '$shareId Primitive Bubble with id: $shareId should not null.');
      }

      if (bubble0 is! PrimitiveFileBubble) {
        throw StateError('${bubble0.id} Primitive Bubble should be PrimitiveFileBubble');
      }
      if (bubble0.content.waitingForAccept) {
        throw StateError('${bubble0.id} $bubble0 Bubble should be accept');
      }
      bubble = bubble0;
      await _checkCancel(bubble.id);
      final fileName = request.requestedUri.queryParameters['file_name'];
      assert(fileName != null, '$shareId filename can\'t be null');
      bubble = (await _bubblePool.findLastById(bubble.id)) as PrimitiveFileBubble?;
      await _checkCancel(bubble!.id);
      try {
        final String desDir = SettingsRepo.instance.savedDir;
        await resolvePathOnMacOS(desDir, (desDir) async {
          assert(fileName != null, "$shareId filename can't be null");
          // safeJoinPaths 相对路径拼接，文件夹发送处理
          await _saveFileAndAddBubble(
              safeJoinPaths(desDir, bubble?.content.meta.path ?? ''), request, bubble!);
        });
      } on Error catch (e, s) {
        talker.error('receive file error: ', e, s);
        final updatedBubble = bubble.copy(
            content: bubble.content
                .copy(state: FileState.receiveFailed, progress: 1.0));
        // removeBubbleById(updatedBubble.id);
        await _bubblePool.add(updatedBubble);
        _removeLongTask();
        return Response.internalServerError();
      }

      _removeLongTask();
      return Response.ok('$shareId $fileName received');
    } on CancelException catch (e, stacktrace) {
      talker.warning('$shareId _receiveFile canceled, ', e, stacktrace);
      setBubbleReceiveFailed(bubble, FileState.cancelled);
      _removeLongTask();
      return Response.ok('$shareId canceled');
    } catch (e, stackTrace) {
      talker.error('$shareId _receiveFile failed, ', e, stackTrace);
      _removeLongTask();
      setBubbleReceiveFailed(bubble, FileState.receiveFailed);
      return Response.internalServerError(body: "$shareId failed");
    }
  }

  void setBubbleReceiveFailed(PrimitiveFileBubble? bubble, FileState state) {
    if (bubble != null) {
      bubble.content.state = state;
      _bubblePool.add(bubble);
    }
  }

  Future<Response> _receiveIntent(Request request) async {
    try {
      final body = await request.readAsString();
      final intent = TransIntent.fromJson(body);
      final bubble = await _bubblePool.findLastById(intent.bubbleId);
      talker.debug("_receiveIntent","action = ${intent.action}, bubble = $bubble");
      switch (intent.action) {
        case TransAction.confirmReceive:
          if (bubble == null ||
              (bubble is! PrimitiveFileBubble &&
                  bubble is! PrimitiveDirectoryBubble)) {
            return Response.notFound('bubble not found');
          }
          if (bubble is PrimitiveFileBubble) {
            final updatedBubble = await updateBubbleShareState(
                    _bubblePool, intent.bubbleId, FileState.inTransit,
                create: bubble) as PrimitiveFileBubble;
            _sendFileReal(updatedBubble);
          } else if (bubble is PrimitiveDirectoryBubble) {
            final updatedBubble = await updateBubbleShareState(
                    _bubblePool, intent.bubbleId, FileState.inTransit,
                create: bubble) as PrimitiveDirectoryBubble;
            talker.debug(sendTag,"confirmReceive");
            for (var element in updatedBubble.content.fileBubbles) {
              talker.debug(sendTag,
                  "confirmed start send = $element");
              await _sendFileReal(element);
            }
          }
          await _checkCancel(bubble.id);
          break;
        case TransAction.cancel:
          if (bubble == null ||
              (bubble is! PrimitiveFileBubble &&
                  bubble is! PrimitiveDirectoryBubble)) {
            return Response.notFound('bubble not found');
          }
          await updateBubbleShareState(
              _bubblePool, intent.bubbleId, FileState.cancelled);
          await _checkCancel(intent.bubbleId);
          break;
        case TransAction.confirmBreakPoint:
          if (bubble == null ||
              (bubble is! PrimitiveFileBubble &&
                  bubble is! PrimitiveDirectoryBubble)) {
            return Response.notFound('bubble not found');
          }
          final updatedBubble = await updateBubbleShareState(
              _bubblePool, intent.bubbleId, FileState.inTransit);
          if (updatedBubble is PrimitiveFileBubble) {
            var receiveBytes = intent.extra?[Constants.receiveBytes];
            _confirmBreakPointFileReal(updatedBubble, receiveBytes);
          } else if (updatedBubble is PrimitiveDirectoryBubble) {
            var receiveMaps = intent.extra?[Constants.receiveMaps];
            if (receiveMaps is Map<String, dynamic>) {
              receiveMaps.forEach((key, value) async {
                final fileUpdateBubble = await updateBubbleShareState(
                    _bubblePool, key, FileState.inTransit);
                _confirmBreakPointFileReal(
                    fileUpdateBubble as PrimitiveFileBubble,
                    value[Constants.receiveBytes]);
              });
            } else {
              talker.error("confirmBreakPoint type=${receiveMaps.runtimeType}");
            }
          }
          break;
        case TransAction.askBreakPoint:
          final bubble = await _bubblePool.findLastById(intent.bubbleId);
          if (bubble == null ||
              bubble is! PrimitiveFileBubble &&
                  bubble is! PrimitiveDirectoryBubble) {
            return Response.notFound('bubble not found');
          }
          breakPointProcessor.confirmBreakPoint(bubble.from, bubble.id);
          break;
        case TransAction.askPairDevice:
          var verifyCode = intent.extra?[Constants.verifyCode].toString();
          var verifyDevice = intent.extra?[Constants.verifyDevice].toString();
          var askCode = intent.extra?[Constants.askCode].toString();
          var askDevice = intent.extra?[Constants.askDevice].toString();
          talker.debug('pairDevice',
              'askPairDevice verifyDevice = $verifyDevice verifyCode = $verifyCode askCode = $askCode  askDevice = $askDevice' );
          if(verifyDevice == null || verifyDevice != did){
            return Response.forbidden('device not match return  verifyDevice = $verifyDevice did = $did');
          }
          var curDevicePairCode = await DeviceProfileRepo.instance.getPairCode();
          if(verifyCode == null || curDevicePairCode != verifyCode){
            talker.debug('pairDevice','code = $verifyCode verifyCode = $curDevicePairCode');
            return Response.forbidden('verifyCode not match return  verifyCode = $verifyCode code = $curDevicePairCode');
          }
          if(askCode == null || askDevice == null){
            return Response.forbidden('code value is not match  askCode = $askCode  askDevice = $askDevice');
          }
          //接收方匹配成功，保存询问的设备
          await DeviceManager.instance.addPairDevice(askDevice, askCode);
          //确认成功，并返回请求的验证信息
          await pairDeviceProcessor.replyPairDevice(intent.deviceId,verifyDevice,verifyCode);
          break;
        case TransAction.confirmPairDevice:
          var verifyCode = intent.extra?[Constants.verifyCode].toString();
          var verifyDevice = intent.extra?[Constants.verifyDevice].toString();
          talker.debug('pairDevice',
              'confirmPairDevice verifyDevice = ${verifyDevice}  verifyCode = $verifyCode');
          //发起方确认匹配成功
          if (verifyCode != null && verifyDevice != null) {
             await DeviceManager.instance.addPairDevice(verifyDevice, verifyCode);
          }
          break;
        case TransAction.deletePairDevice:
          var deleteDeviceId = intent.extra?[Constants.deleteDeviceId].toString();
          talker.debug("deletePairDevice","deletePairDevice deleteDeviceId = $deleteDeviceId");
          if (deleteDeviceId == null) {
            return Response.forbidden(
                'askDevice is invalid  askDevice = $deleteDeviceId ');
          }
          //接收端删除发送者的 id
          await pairDeviceProcessor.deletePairDevice(intent.deviceId);
          //告诉发送端自己的 id
          await pairDeviceProcessor.replyDeletePairDevice(intent.deviceId,deleteDeviceId);
          break;
        case TransAction.confirmDeletePairDevice:
          talker.debug("deletePairDevice","confirmDeletePairDevice");
          var deleteDeviceId = intent.extra?[Constants.deleteDeviceId].toString();
          if(deleteDeviceId == null){
            return Response.forbidden(
                'device not match return  verifyDevice = $deleteDeviceId did = $did');
          }
          //发送端收到确认删除
          await pairDeviceProcessor.deletePairDevice(deleteDeviceId);
          break;
        case TransAction.clipboard:
          var text = intent.extra?[Constants.text].toString();
          FlixClipboardManager.instance.stopWatcher();
          Clipboard.setData(ClipboardData(text: text.toString()));
          FlixClipboardManager.instance.startWatcher();
          break;
        case TransAction.reReceive:
          if (bubble == null) {
            return Response.notFound('bubble not found');
          }
          resend(bubble);
          break;
      }

      return Response.ok('ok');
    } on Exception catch (e, stackTrace) {
      talker.error('receive intent error: ', e, stackTrace);
      return Response.badRequest();
    }
  }

  void _confirmBreakPointFileReal(PrimitiveFileBubble updatedBubble, Object? receiveBytes) {
     updatedBubble.content.waitingForAccept = false;
    updatedBubble.content.receiveBytes = receiveBytes as int;
    _sendFileReal(updatedBubble);
  }

  Future<void> _saveFileAndAddBubble(
      String desDir, Request request, PrimitiveFileBubble bubble) async {
    talker.debug("_saveFileAndAddBubble=>", "dir =$desDir  bubble = $bubble");
    File outFile = await _saveFile(desDir, request, bubble);
    String? path = bubble.content.meta.path;
    String? resourceId;
    if (bubble.type == BubbleType.Image || bubble.type == BubbleType.Video) {
      final entity = await _saveMediaToAlbumOnMobile(
          outFile, bubble.type == BubbleType.Image,
          tag: bubble.id);
      resourceId = entity?.id;
      path = entity?.path ?? path;
    }

    //路径为空时，证明不是文件夹传输，无相对路径，直接填充文件路径
    if(path == null || path == ""){
      path = outFile.path;
    }

    talker.debug("_saveFileAndAddBubble path = $path");

    final updatedBubble = bubble.copy(
        content: bubble.content.copy(
            state: FileState.receiveCompleted,
            progress: 1.0,
            meta:
                bubble.content.meta.copy(resourceId: resourceId, path: path)));
    await _bubblePool.add(updatedBubble);
  }

  Future<SimpleResourceEntity?> _saveMediaToAlbumOnMobile(File outFile, bool isImage,
      {String? tag}) async {
    try {
      if (Platform.isAndroid) {
        if (SettingsRepo.instance.autoSaveToGallery) {
          final AssetEntity? entity;
          if (isImage) {
            entity = await PhotoManager.plugin.saveImageWithPath(outFile.path,
                title: outFile.path.split("/").last, relativePath: "Pictures/flix");
          } else {
            entity = await PhotoManager.plugin
                .saveVideo(outFile, title: outFile.path.split("/").last, relativePath: "Movies/flix");
          }
          if (entity == null) {
            talker.error("save to gallery failed");
            return null;
          } else {

            final file = await entity.file;
            if (file != null && await file.exists()) {
              // 保证写入相册成功后才删除
              outFile.delete(recursive: true);
            }
            return SimpleResourceEntity(entity.id, file?.path);
          }

        }

      } else if (Platform.isIOS) {
        final result = await ImageGallerySaver.saveFile(outFile.path,
            isReturnPathOfIOS: true);
        talker.debug("$tag ios save file result: $result");
        if (result["isSuccess"]) {
          return SimpleResourceEntity(result["resourceId"] as String, null);
        } else {
          talker.error("$tag ios save file failed");
        }
      }
    } catch (e, s) {
      talker.error("$tag failed to save to gallery", e, s);
    }
    return null;
  }

  Future<File> _saveFile(
      String desDir, Request request, PrimitiveFileBubble bubble) async {
    var fileMode = FileMode.write;
    var receiveBytes = bubble.content.receiveBytes;
    if (receiveBytes > 0 || receiveBytes != bubble.content.meta.size) {
      fileMode = FileMode.append;
    }
    talker.debug("sendFile",'_saveFile is append = ${fileMode == FileMode.append} receiveBytes = $receiveBytes');
    //需要传入文件夹，因为文件夹传输需要用到
    final outFile = await FileUtils.getOrCreateTempWithFolder(desDir,bubble.content.meta.name);
    final out = outFile.openWrite(mode: fileMode);
    talker.debug('writing file to ${outFile.path}');
    await request
        .read()
        .chain((Stream<List<int>> stream) async {
          await _checkCancel(bubble.id);
        })
        .progress(bubble, receiveBytes)
        .pipe(out);
    out.flush();
    out.close();
    var targetFile = await FileUtils.getTargetFile(desDir, bubble.content.meta.name);
    String targetPath = targetFile.path;
    talker.debug("_saveFile","before rename ${outFile.path} => ${targetFile.path}");
    targetFile = await outFile.rename(targetPath);
    talker.debug("_saveFile","rename ${outFile.path} => ${targetFile.path}");
    return targetFile;
  }

  Future<Response> _heartbeat(Request request) async {
    return Response.ok('I\'m living');
  }

  Future<void> _addLongTask() async {
    _longTaskCount++;
    if (!(await WakelockPlus.enabled)) {
      await WakelockPlus.enable();
    }
    markTaskStarted();
  }

  Future<void> _removeLongTask() async {
    _longTaskCount--;
    if (_longTaskCount <= 0) {
      _longTaskCount = 0;
      await Future.delayed(const Duration(seconds: 2));
      if (_longTaskCount <= 0 && await WakelockPlus.enabled) {
        await WakelockPlus.disable();
      }
      if (_longTaskCount <= 0) {
        markTaskStopped();
      }
    }
  }

  Future<void> askPairDevice(String deviceId, String code) async {
    pairDeviceProcessor.askPairDevice(deviceId, code);
  }

  Future<void> askDeletePairDevice(String deleteDeviceId) async {
    pairDeviceProcessor.askDeletePairDevice(deleteDeviceId);
  }

  Future<void> sendClipboard(String to, String lastText) async {
    pairDeviceProcessor.sendClipboard(to, lastText);
  }

  static String getAddressByDeviceId(String deviceId) {
    return '${DeviceManager.instance.getNetAdressByDeviceId(deviceId)}';
  }

  Future<void> markTaskStarted() async {
    PhysicalLock.acquirePhysicalLock();
  }

  Future<void> markTaskStopped() async {
    PhysicalLock.releasePhysicalLock();
  }

}

Future<PrimitiveBubble> updateBubbleShareState(
    BubblePool bubblePool, String bubbleId, FileState state,
    {PrimitiveBubble? create, bool? waitingForAccept}) async {
  var bubble = create ?? await bubblePool.findLastById(bubbleId);
  if (bubble is PrimitiveFileBubble) {
    final PrimitiveFileBubble copyBubble;
    if (waitingForAccept == null) {
      copyBubble = bubble.copy(content: bubble.content.copy(state: state));
    } else {
      copyBubble = bubble.copy(
          content: bubble.content
              .copy(state: state, waitingForAccept: waitingForAccept));
    }
    await bubblePool.add(copyBubble);
    return copyBubble;
  } else if (bubble is PrimitiveDirectoryBubble) {
    final PrimitiveDirectoryBubble copyBubble;
    if (waitingForAccept == null) {
      copyBubble =
          bubble.copy(content: bubble.content.copy(state: state));
    } else {
      copyBubble = bubble.copy(
          content: bubble.content
              .copy(state: state, waitingForAccept: waitingForAccept));
    }
    await bubblePool.add(copyBubble);
    // 更新子气泡状态, 后期子气泡状态可查看后用到
    copyBubble.content.fileBubbles.forEach((element) async {
      await bubblePool.add(element);
    });
    return copyBubble;
  } else {
    throw StateError('The Bubble with id: $bubbleId is not a bubble');
  }
}
