import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:flix/domain/bubble_pool.dart';
import 'package:flix/domain/constants.dart';
import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/domain/ship_server/ship_service_bridge.dart';
import 'package:flix/model/intent/trans_intent.dart';
import 'package:flix/model/ship/primitive_bubble.dart';
import 'package:flix/model/ui_bubble/shared_file.dart';
import 'package:flix/network/nearby_service_info.dart';
import 'package:flix/network/protocol/device_modal.dart';
import 'package:flix/network/protocol/ping_pong.dart';
import 'package:flix/utils/drawin_file_security_extension.dart';
import 'package:flix/utils/file/file_helper.dart';
import 'package:flix/utils/stream_cancelable.dart';
import 'package:flix/utils/stream_progress.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:mutex/mutex.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_multipart/form_data.dart';
import 'package:shelf_multipart/multipart.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class ShipService {
  final String did;
  final _bubblePool = BubblePool.instance;
  final syncTasks = <String, Completer>{};
  final lock = Mutex();
  var _longTaskCount = 0;
  final ShipServiceDependency dependency;
  HttpServer? _server;
  int port = defaultPort;

  ShipService({required this.did, required this.dependency}) {}

  Future<String> _pongUrl(String deviceId) async {
    return 'http://${await dependency.getNetAddressById(deviceId)}/pong';
  }

  Future<String> _intentUrl(String deviceId) async {
    return 'http://${await dependency.getNetAddressById(deviceId)}/intent';
  }

  Future<String> _getSendBubbleUrl(
          PrimitiveBubble<dynamic> primitiveBubble) async =>
      'http://${await dependency.getNetAddressById(primitiveBubble.to)}/bubble';

  Future<String> _getSendFileUrl(PrimitiveFileBubble fileBubble) async =>
      'http://${await dependency.getNetAddressById(fileBubble.to)}/file';

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
      var uri = Uri.parse('http://127.0.0.1:${port}/heartbeat');
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

  @override
  Future<void> pong(DeviceModal from, DeviceModal to) async {
    try {
      final message = Pong(from, to).toJson();
      var uri = Uri.parse(await _pongUrl(to.fingerprint));
      var response = await http.post(
        uri,
        body: message,
        headers: {"Content-type": "application/json; charset=UTF-8"},
      );

      if (response.statusCode == 200) {
        talker.debug('pong success: response: ${response.body}');
      } else {
        talker.debug(
            'pong failed: status code: ${response.statusCode}, ${response.body}');
      }
    } catch (e, stackTrace) {
      talker.error('pong failed', e, stackTrace);
    }
  }

  Future<void> send(PrimitiveBubble primitiveBubble) async {
    try {
      // await checkCancel(uiBubble.shareable.id);
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
        default:
          throw UnimplementedError();
      }
    } on CancelException catch (e, stackTrace) {
      talker.warning('outer 取消发送: ', e, stackTrace);
    } catch (e, stackTrace) {
      talker.error('outer send failed: ', e, stackTrace);
    }
  }

  Future<void> confirmBreakPoint(String from, String bubbleId) async {
    try {
      await updateFileShareState(_bubblePool, bubbleId, FileState.inTransit,
          waitingForAccept: false);
      var uri = Uri.parse(await _intentUrl(from));
      var fileBubble =
          (await _bubblePool.findLastById(bubbleId)) as PrimitiveFileBubble;
      var receiveBytesMap = HashMap<String, Object>();
      var filePath = fileBubble.content.meta.path;
      if (filePath?.isNotEmpty == true) {
        var fileLen = await File(filePath!).length();
        receiveBytesMap[Constants.receiveBytes] =fileLen;
        fileBubble.content.receiveBytes = fileLen;
        _bubblePool.add(fileBubble);
      }
      talker.debug("breakPoint",
          "confirmBreakPoint receiveBytes = ${receiveBytesMap[Constants.receiveBytes]}");
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

  Future<void> confirmReceiveFile(String from, String bubbleId) async {
    try {
      // 更新接收方状态为接收中
      await updateFileShareState(_bubblePool, bubbleId, FileState.inTransit,
          waitingForAccept: false);
      var uri = Uri.parse(await _intentUrl(from));

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

  Future<void> cancelSend(PrimitiveFileBubble bubble) async {
    await updateFileShareState(_bubblePool, bubble.id, FileState.cancelled,
        create: bubble);
    await _sendCancelMessage(bubble.id, bubble.to);
  }

  Future<void> resend(PrimitiveFileBubble bubble) async {
    await updateFileShareState(_bubblePool, bubble.id, FileState.waitToAccepted,
        create: bubble);
    //已经发送过，c/s都有此记录
    talker.debug("resend",
        "getBreakPoint receiveBytes = ${bubble.content.progress}");
    if (bubble.content.progress > 0) {
      talker.debug("breakPoint", "start ask");
      askBreakPoint(bubble);
      return;
    }
    await _sendBasicBubble(bubble.copy(
        content: bubble.content.copy(state: FileState.waitToAccepted)));
  }

  Future<void> _sendCancelMessage(String bubbleId, String to) async {
    try {
      await updateFileShareState(_bubblePool, bubbleId, FileState.cancelled);
      var uri = Uri.parse(await _intentUrl(to));

      var response = await http.post(
        uri,
        body: TransIntent(
                deviceId: did, bubbleId: bubbleId, action: TransAction.cancel, extra: {})
            .toJson(),
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
    app.post('/pong', _receivePong);
    app.post('/heartbeat', _heartbeat);

    // 尝试三次启动
    final tmp =
        await _startShipServerInner(app, defaultPort, 'first', () async {
      return await _startShipServerInner(app, defaultPort + 1, 'second',
          () async {
        return await _startShipServerInner(
            app, defaultPort + 2, 'third', () async {});
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
      final server = await io.serve(app, '0.0.0.0', serverPort, shared: false);
      talker.debug('Serving at http://0.0.0.0:${serverPort}');
      port = serverPort;
      return server;
    } catch (e, stack) {
      talker.error('$tag start server at http://0.0.0.0:${serverPort} failed ',
          e, stack);
      return await onFailed();
    }
  }

  Future<void> _sendBasicBubble(PrimitiveBubble primitiveBubble) async {
    try {
      await _checkCancel(primitiveBubble.id);
      var uri = Uri.parse(await _getSendBubbleUrl(primitiveBubble));

      var response = await http.post(
        uri,
        body: jsonEncode(primitiveBubble.toJson()),
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

  Future<void> _sendFileBubble(PrimitiveFileBubble fileBubble) async {
    try {
      var _fileBubble = fileBubble.copy(
          content: fileBubble.content.copy(state: FileState.waitToAccepted));
      await _bubblePool.add(_fileBubble);
      await _checkCancel(fileBubble.id);
      // send with no path
      await _sendBasicBubble(_fileBubble.copy(
          content: _fileBubble.content
              .copy(meta: _fileBubble.content.meta.copy(path: null))));
    } on CancelException catch (e, stackTrace) {
      talker.warning('取消发送文件: ', e, stackTrace);
    } catch (e, stackTrace) {
      talker.error('发送异常: ', e, stackTrace);
      updateFileShareState(_bubblePool, fileBubble.id, FileState.sendFailed);
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
      _notifyNewBubble(bubble);
      if (await dependency.isAutoReceive() && bubble is PrimitiveFileBubble) {
        await _bubblePool.add(bubble);
        await confirmReceiveFile(bubble.from, bubble.id);
      } else if (bubble is PrimitiveFileBubble) {
        final before = await _bubblePool.findLastById(bubble.id);
        if (before is PrimitiveFileBubble) {
          // 如果是重新发送，判断是否已经接收，已经接受直接确认接受，否则继续等待接受。
          if (!before.content.waitingForAccept) {
            await _bubblePool.add(bubble);
            await confirmReceiveFile(bubble.from, bubble.id);
          } else {
            await _bubblePool.add(bubble.copy(
                content: bubble.content.copy(state: FileState.waitToAccepted)));
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
    _addLongTask();
    try {
      await _checkCancel(fileBubble.id);

      final shardFile = fileBubble.content.meta;

      var request = http.MultipartRequest(
          'POST', Uri.parse(await _getSendFileUrl(fileBubble)));

      request.fields['share_id'] = fileBubble.id;
      request.fields['file_name'] = shardFile.name;
      var receiveBytes = fileBubble.content.receiveBytes;
      if (receiveBytes > 0) {
        request.fields['mode'] = FileMode.append.toString();
      } else {
        request.fields['mode'] = FileMode.write.toString();
      }
      await shardFile.resolvePath((path) async {
        var fileSize = shardFile.size;
        talker.debug("breakPoint=>_sendFileReal receiveBytes", "=receiveBytes:$receiveBytes===shardFileSize = ${shardFile.size}  offset = ${fileSize - receiveBytes}");

        var multipartFile = http.MultipartFile(
            'file',
            File(path)
                .openRead(receiveBytes,fileSize)
                .chain((stream) async {
              await _checkCancel(fileBubble.id);
            }).progress(fileBubble,receiveBytes),
            fileSize - receiveBytes,
            filename: shardFile.name,
            contentType: MediaType.parse(shardFile.mimeType));
        request.files.add(multipartFile);
        final response = await request.send();
        if (response.statusCode == 200) {
          talker.debug('发送成功 ${await response.stream.bytesToString()}');
          updateFileShareState(
              _bubblePool, fileBubble.id, FileState.sendCompleted);
          _deleteCachedFile(fileBubble, path);
        } else {
          talker.error(
              '发送失败: status code: ${response.statusCode}, ${await response.stream.bytesToString()}');
          updateFileShareState(
              _bubblePool, fileBubble.id, FileState.sendFailed);
        }
      });
    } on CancelException catch (e, stackTrace) {
      talker.warning('发送取消: ', e, stackTrace);
    } catch (e, stackTrace) {
      talker.error('发送异常: ', e, stackTrace);
      updateFileShareState(_bubblePool, fileBubble.id, FileState.sendFailed);
    }
    _removeLongTask();
  }

  Future<Response> _receiveFile(Request request) async {
    _addLongTask();
    PrimitiveFileBubble? bubble;
    String? shareId;
    try {
      if (!request.isMultipart) {
        _removeLongTask();
        return Response.badRequest();
      } else if (request.isMultipartForm) {
        final description = StringBuffer('Parsed form multipart request\n');
        await for (final formData in request.multipartFormData) {
          switch (formData.name) {
            case 'share_id':
              shareId = await formData.part.readString();
              final _bubble = await _bubblePool.findLastById(shareId!);
              if (_bubble == null) {
                throw StateError(
                    '$shareId Primitive Bubble with id: $shareId should not null.');
              }

              if (_bubble is! PrimitiveFileBubble) {
                throw StateError(
                    '${_bubble.id} Primitive Bubble should be PrimitiveFileBubble');
              }
              if (_bubble.content.waitingForAccept) {
                throw StateError('${_bubble.id} $_bubble Bubble should be accept');
              }
              bubble = _bubble;
              await _checkCancel(bubble.id);
              break;
            case 'file':
              assert(bubble != null, '$shareId bubble can\'t be null');
              assert(formData.filename != null, '$shareId filename can\'t be null');
              bubble = (await _bubblePool.findLastById(bubble!.id)) as PrimitiveFileBubble?;
              await _checkCancel(bubble!.id);
              try {
                final String desDir = await dependency.getSaveDir();
                await resolvePathOnMacOS(desDir, (desDir) async {
                  assert(formData.filename != null, "$shareId filename can't be null");
                  await _saveFileAndAddBubble(desDir, formData, bubble!);
                });
              } on Error catch (e) {
                talker.error('receive file error: ', e);
                final updatedBubble = bubble.copy(
                    content: bubble.content
                        .copy(state: FileState.receiveFailed, progress: 1.0));
                // removeBubbleById(updatedBubble.id);
                await _bubblePool.add(updatedBubble);
                _removeLongTask();
                return Response.internalServerError();
              }
              break;
          }
        }

        _removeLongTask();
        return Response.ok(description.toString());
      } else {
        _removeLongTask();
        return Response.badRequest();
      }
    } on CancelException catch (e, stacktrace) {
      talker.warning('$shareId _receiveFile canceled, ', e, stacktrace);
      setBubbleReceiveFailed(bubble,FileState.cancelled);
      _removeLongTask();
      return Response.ok('$shareId canceled');
    } catch (e, stackTrace) {
      talker.error('$shareId _receiveFile failed, ', e, stackTrace);
      _removeLongTask();
      setBubbleReceiveFailed(bubble,FileState.receiveFailed);
      return Response.internalServerError(body: "$shareId failed");
    }
  }

  void setBubbleReceiveFailed(PrimitiveFileBubble? bubble,FileState state) {
    if(bubble != null){
      bubble.content.state = state;
      _bubblePool.add(bubble);
    }
  }

  Future<Response> _receiveIntent(Request request) async {
    try {
      final body = await request.readAsString();
      final intent = TransIntent.fromJson(body);
      final bubble = await _bubblePool.findLastById(intent.bubbleId);
      if (bubble == null || bubble is! PrimitiveFileBubble) {
        return Response.notFound('bubble not found');
      }
      talker.debug("_receiveIntent","action = ${intent.action}");
      switch (intent.action) {
        case TransAction.confirmReceive:
          await _checkCancel(bubble.id);
          final updatedBubble = await updateFileShareState(
                  _bubblePool, intent.bubbleId, FileState.inTransit)
              as PrimitiveFileBubble;
          _sendFileReal(updatedBubble);
          break;
        case TransAction.cancel:
          await updateFileShareState(
              _bubblePool, intent.bubbleId, FileState.cancelled);
          await _checkCancel(intent.bubbleId);
          break;
        case TransAction.confirmBreakPoint:
          final updatedBubble = await updateFileShareState(
                  _bubblePool, intent.bubbleId, FileState.inTransit)
              as PrimitiveFileBubble;
          var receiveBytes = intent.extra[Constants.receiveBytes];
          updatedBubble.content.waitingForAccept = false;
          updatedBubble.content.receiveBytes = receiveBytes as int;
          _sendFileReal(updatedBubble);
          break;
        case TransAction.askBreakPoint:
          confirmBreakPoint(bubble.from, bubble.id);
          break;
      }

      return Response.ok('ok');
    } on Exception catch (e, stackTrace) {
      talker.error('receive intent error: ', e, stackTrace);
      return Response.badRequest();
    }
  }

  Future<void> _saveFileAndAddBubble(
      String desDir, FormData formData, PrimitiveFileBubble bubble) async {
    talker.debug("breakPoint=>","_saveFileAndAddBubble");
    File outFile = await _saveFile(desDir, formData, bubble);
    String? path = outFile.path;
    String? resourceId = await _saveMediaToAlbumOnIOS(outFile, tag: bubble.id);
    // 保存到相册成功，删除副本
    try {
      if (resourceId != null) {
        path = null;
        await outFile.delete();
      }
    } catch (e, s) {
      talker.error('${bubble.id} delete file failed', e, s);
    }

    final updatedBubble = bubble.copy(
        content: bubble.content.copy(
            state: FileState.receiveCompleted,
            progress: 1.0,
            meta: bubble.content.meta.copy(resourceId: resourceId ,path: path)));
    await _bubblePool.add(updatedBubble);
  }

  Future<String?> _saveMediaToAlbumOnIOS(File outFile, {String? tag}) async {
    if (Platform.isIOS) {
      try {
        final result = await ImageGallerySaver.saveFile(outFile.path, isReturnPathOfIOS: true);
        talker.debug("$tag ios save file result: $result");
        if (result["isSuccess"]) {
          return result["resourceId"] as String;
        } else {
          talker.error("$tag ios save file failed");
        }
      } catch (e, s) {
        talker.error("$tag failed to save to gallery", e, s);
      }
    }
    return null;
  }

  Future<File> _saveFile(
      String desDir, FormData formData, PrimitiveFileBubble bubble) async {

    var deleteExist = true;
    var fileMode = FileMode.write;
    var receiveBytes = bubble.content.receiveBytes;
    if(receiveBytes > 0){
      deleteExist = false;
      fileMode = FileMode.append;
    }
    talker.debug('breakPoint=>_saveFile is append = ${fileMode == FileMode.append} deleteExist = $deleteExist receiveBytes = ${receiveBytes}');
    final outFile = await createFile(desDir, formData.filename ?? '',deleteExist: deleteExist);
    talker.debug('breakPoint=>_saveFile file.length = ${(await outFile.length())}');
    bubble.content.meta.path = outFile.path;
    final out = outFile.openWrite(mode: fileMode);
    talker.debug('writing file to ${outFile.path}');
    await formData.part
        .chain((Stream<List<int>> stream) async {
          await _checkCancel(bubble.id);
        })
        .progress(bubble,receiveBytes)
        .pipe(out);
    out.flush();
    out.close();
    return outFile;
  }

  Future<void> _deleteCachedFile(
      PrimitiveFileBubble fileBubble, String path) async {
    try {
      if (await isInCacheOrTmpDir(path)) {
        talker.info('delete cached file: $path');
        await File(path).delete();
        talker.info('delete cached file successfully: $path');
      }
    } catch (e, stackTrace) {
      talker.error('delete cached file failed', e, stackTrace);
    }
  }

  Future<Response> _receivePong(Request request) async {
    try {
      final body = await request.readAsString();
      final pong = Pong.fromJson(body);
      final ip =
          (request.context['shelf.io.connection_info'] as HttpConnectionInfo?)
              ?.remoteAddress
              .address;
      if (ip != null) {
        pong.from.ip = ip;
        talker.debug('receive tcp pong: $pong');
        dependency.notifyPong(pong);
      } else {
        talker.error('receive tcp pong, but can\'t get ip');
      }
      return Response.ok('ok');
    } on Exception catch (e, stack) {
      talker.error('receive pong error: ', e, stack);
      return Response.badRequest();
    }
  }

  Future<Response> _heartbeat(Request request) async {
    return Response.ok('I\'m living');
  }

  void _notifyNewBubble(PrimitiveBubble bubble) {
    dependency.notifyNewBubble(bubble);
  }

  Future<void> _addLongTask() async {
    _longTaskCount++;
    if (!(await WakelockPlus.enabled)) {
      await WakelockPlus.enable();
    }
    dependency.markTaskStarted();
  }

  Future<void> _removeLongTask() async {
    _longTaskCount--;
    if (_longTaskCount <= 0) {
      _longTaskCount = 0;
      await Future.delayed(Duration(seconds: 2));
      if (_longTaskCount <= 0 && await WakelockPlus.enabled) {
        await WakelockPlus.disable();
      }
      if (_longTaskCount <= 0) {
        dependency.markTaskStopped();
      }
    }
  }

  Future<void> askBreakPoint(PrimitiveFileBubble bubble) async {
    try {
      talker.debug("breakPoint=>","askBreakPoint = ${bubble.to}");
      // 更新接收方状态为接收中
      await updateFileShareState(_bubblePool, bubble.id, FileState.inTransit,
          waitingForAccept: true);
      var uri = Uri.parse(await _intentUrl(bubble.to));

      var response = await http.post(
        uri,
        body: TransIntent(
                deviceId: did,
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
}

Future<PrimitiveBubble> updateFileShareState(
    BubblePool _bubblePool, String bubbleId, FileState state,
    {PrimitiveFileBubble? create = null, bool? waitingForAccept = null}) async {
  var _bubble = await _bubblePool.findLastById(bubbleId);
  if (_bubble == null) {
    if (create != null) {
      _bubble = create;
    } else {
      throw StateError('Can\'t find bubble by id: $bubbleId');
    }
  }

  if (!(_bubble is PrimitiveFileBubble)) {
    throw StateError('The Bubble with id: $bubbleId is not a file bubble');
  }

  final copyBubble;
  if (waitingForAccept == null) {
    copyBubble = _bubble.copy(content: _bubble.content.copy(state: state));
  } else {
    copyBubble = _bubble.copy(
        content: _bubble.content
            .copy(state: state, waitingForAccept: waitingForAccept));
  }
  await _bubblePool.add(copyBubble);
  return copyBubble;
}
