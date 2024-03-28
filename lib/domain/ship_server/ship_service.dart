import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flix/domain/bubble_pool.dart';
import 'package:flix/domain/device/ap_interface.dart';
import 'package:flix/domain/device/device_manager.dart';
import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/domain/settings/SettingsRepo.dart';
import 'package:flix/model/intent/trans_intent.dart';
import 'package:flix/model/ui_bubble/shared_file.dart';
import 'package:flix/model/ship/primitive_bubble.dart';
import 'package:flix/model/ui_bubble/ui_bubble.dart';
import 'package:flix/network/multicast_util.dart';
import 'package:flix/network/protocol/device_modal.dart';
import 'package:flix/network/protocol/ping_pong.dart';
import 'package:flix/utils/bubble_convert.dart';
import 'package:flix/utils/stream_cancelable.dart';
import 'package:flix/utils/stream_progress.dart';
import 'package:http_parser/http_parser.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_multipart/form_data.dart';
import 'package:shelf_multipart/multipart.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:http/http.dart' as http;

import '../../utils/file/file_helper.dart';

class ShipService extends ApInterface {
  ShipService._privateConstruct();

  static final ShipService _instance = ShipService._privateConstruct();

  static ShipService get instance => _instance;

  final _bubblePool = BubblePool.instance;

  PongListener? _pongListener;
  HttpServer? _server;

  // final Map<String, Cancelable> tasks = {};

  String intentUrl(String deviceId) {
    return 'http://${DeviceManager.instance.getNetAdressByDeviceId(deviceId)}/intent';
  }

  Future<void> startShipServer() async {
    var app = Router();
    app.post('/bubble', _receiveBubble);
    app.post('/intent', _receiveIntent);
    app.post('/file', _receiveFile);
    app.post('/pong', _receivePong);

    // 尝试三次启动
    _server =  await _startShipServer(app, 'first', () async {
      Future.delayed(const Duration(seconds: 1));
      return _startShipServer(app, 'second', () async {
        Future.delayed(const Duration(seconds: 2));
        return _startShipServer(app, 'third', () async {
        });
      });
    });
  }

  // Future<void> restartShipServer() async {
  //
  // }

  Future<HttpServer?> _startShipServer(Router app, String tag, Future<HttpServer?> Function() onFailed) async {
    try {
      final server = await io.serve(app, '0.0.0.0', MultiCastUtil.defaultPort, shared: true);
      talker.debug('Serving at http://0.0.0.0:${MultiCastUtil.defaultPort}');
      return server;
    } catch (e, stack) {
      talker.error('$tag start server at http://0.0.0.0:${MultiCastUtil.defaultPort} failed $e', e, stack);
      return await onFailed();
    }
  }

  Future<Response> _receiveBubble(Request request) async {
    var body = await request.readAsString();
    var data = jsonDecode(body) as Map<String, dynamic>;
    var bubble = PrimitiveBubble.fromJson(data);
    if (await SettingsRepo.instance.getAutoReceiveAsync() && bubble is PrimitiveFileBubble) {
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
          await _bubblePool.add(bubble.copy(content: bubble.content.copy(state: FileState.waitToAccepted)));
        }
      } else {
        await _bubblePool.add(bubble);
      }
    } else {
      await _bubblePool.add(bubble);
    }
    return Response.ok('received bubble');
  }

  Future<Response> _receiveFile(Request request) async {
    var isGranted = await Permission.storage.isGranted;
    if(!isGranted){
      var permissionStatus = await Permission.storage.request();
      talker.debug('_receiveFile permission permissionStatus $permissionStatus');
    }
    isGranted = await Permission.storage.isGranted;
    talker.debug('_receiveFile permission to $isGranted');

    try {
      if (!request.isMultipart) {
        return Response.badRequest();
      } else if (request.isMultipartForm) {
        final description = StringBuffer('Parsed form multipart request\n');
        PrimitiveFileBubble? bubble;
        await for (final formData in request.multipartFormData) {
          switch (formData.name) {
            case 'share_id':
              final shareId = await formData.part.readString();
              final _bubble = await _bubblePool.findLastById(shareId);
              if (_bubble == null) {
                throw StateError(
                    'Primitive Bubble with id: $shareId should not null.');
              }

              if (_bubble is! PrimitiveFileBubble) {
                throw StateError(
                    'Primitive Bubble should be PrimitiveFileBubble');
              }
              if (_bubble.content.waitingForAccept) {
                throw StateError('Bubble should be accept');
              }
              bubble = _bubble;
              await checkCancel(bubble.id);
              break;
            case 'file':
              if (bubble == null) {
                throw StateError('Bubble should not null');
              }
              await checkCancel(bubble.id);
              try {
                final String desDir = await getDefaultDestinationDirectory();
                final String filePath = '$desDir/${formData.filename}';
                final outFile = File(filePath);
                talker.debug('writing file to ${outFile.path}');
                if (!(await outFile.exists())) {
                  await outFile.create();
                }
                var fileExist = !(await outFile.exists());
                talker.debug('writing file not exit $fileExist');
                final out = outFile.openWrite(mode: FileMode.append);

                final bubbleId = bubble.id;
                await formData.part
                    .chain((Stream<List<int>> stream) async {
                      await checkCancel(bubbleId);
                    })
                    .progress(bubbleId)
                    .pipe(out);

                // await Future.delayed(Duration(seconds: 5));
                final updatedBubble = bubble.copy(
                    content: bubble.content.copy(
                        state: FileState.receiveCompleted,
                        progress: 1.0,
                        meta: bubble.content.meta.copy(path: filePath)));
                // removeBubbleById(updatedBubble.id);
                await _bubblePool.add(updatedBubble);
              } on Error catch (e) {
                talker.error('receive file error: $e', e);
                final updatedBubble = bubble.copy(
                    content: bubble.content
                        .copy(state: FileState.receiveFailed, progress: 1.0));
                // removeBubbleById(updatedBubble.id);
                await _bubblePool.add(updatedBubble);
                return Response.internalServerError();
              }
              break;
          }
        }

        return Response.ok(description.toString());
      } else {
        return Response.badRequest();
      }
    } on CancelException catch (e, stacktrace) {
      talker.warning('_receiveFile canceled: $e', e, stacktrace);
      return Response.ok('canceled');
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

      await checkCancel(bubble.id);

      switch (intent.action) {
        case TransAction.confirmReceive:
          final updatedBubble =
              await _updateFileShareState(intent.bubbleId, FileState.inTransit)
                  as PrimitiveFileBubble;
          _sendFileReal(updatedBubble);
          break;
        case TransAction.cancel:
          await _updateFileShareState(intent.bubbleId, FileState.cancelled);
          await checkCancel(intent.bubbleId);
          break;
      }

      return Response.ok('ok');
    } on Exception catch (e, stackTrace) {
      talker.error('receive intent error: $e', e,stackTrace);
      return Response.badRequest();
    }
  }

  Future<Response> _receivePong(Request request) async {
    try {

      final body = await request.readAsString();
      final pong = Pong.fromJson(body);
      talker.debug('receive tcp pong: $pong');
      final ip = (request.context['shelf.io.connection_info'] as HttpConnectionInfo?)?.remoteAddress.address;
      if (ip != null) {
        pong.from.ip = ip;
        _pongListener?.call(pong);
      } else {
        talker.error('receive tcp pong, but can\'t get ip');
      }
      return Response.ok('ok');
    } on Exception catch (e, stack) {
      talker.error('receive pong error: $e', e, stack);
      return Response.badRequest();
    }
  }

  @override
  void listenPong(PongListener listener) {
    this._pongListener = listener;
  }

  @override
  Future<void> pong(DeviceModal from, DeviceModal to) async {
    final message = Pong(from, to).toJson();
    var uri = Uri.parse(
        'http://${DeviceManager.instance.toNetAddress(to.ip, to.port)}/pong');
    var response = await http.post(
      uri,
      body: message,
      headers: {"Content-type": "application/json; charset=UTF-8"},
    );

    if (response.statusCode == 200) {
      talker.debug('pong success: response: ${response.body}');
    } else {
      talker.debug('pong failed: status code: ${response.statusCode}, ${response.body}');
    }
  }



  Future<void> _send(PrimitiveBubble primitiveBubble) async {
    try {
      await checkCancel(primitiveBubble.id);
      var uri = Uri.parse(
          'http://${DeviceManager.instance.getNetAdressByDeviceId(primitiveBubble.to)}/bubble');

      var response = await http.post(
        uri,
        body: jsonEncode(primitiveBubble.toJson()),
        headers: {"Content-type": "application/json; charset=UTF-8"},
      );

      if (response.statusCode == 200) {
        talker.debug('发送成功: response: ${response.body}');
      } else {
        talker.debug('发送失败: status code: ${response.statusCode}, ${response.body}');
      }
    } on CancelException catch (e, stackTrace) {
      talker.warning('取消发送 bubble: $e', e, stackTrace);
    }
  }

  Future<void> send(UIBubble uiBubble) async {
    try {
      // await checkCancel(uiBubble.shareable.id);
      switch (uiBubble.type) {
        case BubbleType.Text:
          final primitiveBubble = fromUIBubble(uiBubble);
          await _bubblePool.add(primitiveBubble);
          await _send(primitiveBubble);
          break;
        case BubbleType.Image:
        case BubbleType.Video:
        case BubbleType.File:
        case BubbleType.App:
          await _sendFileBubble(fromUIBubble(uiBubble) as PrimitiveFileBubble);
          break;
        default:
          throw UnimplementedError();
      }
    } on CancelException catch (e, stackTrace) {
      talker.warning('outer 取消发送: $e', e, stackTrace);
    }
  }

  Future<void> _sendFileBubble(PrimitiveFileBubble fileBubble) async {
    try {
      var _fileBubble = fileBubble.copy(
          content: fileBubble.content.copy(state: FileState.waitToAccepted));
      await _bubblePool.add(_fileBubble);
      await checkCancel(fileBubble.id);
      // send with no path
      await _send(_fileBubble.copy(
          content: _fileBubble.content
              .copy(meta: _fileBubble.content.meta.copy(path: null))));
    } on CancelException catch (e, stackTrace) {
      talker.warning('取消发送文件: $e', e, stackTrace);
    } catch (e, stackTrace) {
      talker.error('发送异常: $e', e, stackTrace);
      _updateFileShareState(fileBubble.id, FileState.sendFailed);
    }
  }

  Future<void> _sendFileReal(PrimitiveFileBubble fileBubble) async {
    try {
      await checkCancel(fileBubble.id);
      final shardFile = fileBubble.content.meta;

      var request = http.MultipartRequest(
          'POST',
          Uri.parse(
              'http://${DeviceManager.instance.getNetAdressByDeviceId(fileBubble.to)}/file'));

      request.fields['share_id'] = fileBubble.id;
      request.fields['file_name'] = shardFile.name;

      await shardFile.resolvePath((path) async {
        var multipartFile = http.MultipartFile(
            'file',
            File(path).openRead().chain((stream) async {
              await checkCancel(fileBubble.id);
            }).progress(fileBubble.id),
            shardFile.size,
            filename: shardFile.name,
            contentType: MediaType.parse(shardFile.mimeType));
        request.files.add(multipartFile);
        final response = await request.send();
        if (response.statusCode == 200) {
          talker.debug('发送成功 ${await response.stream.bytesToString()}');
          _updateFileShareState(fileBubble.id, FileState.sendCompleted);
        } else {
          talker.error('发送失败: status code: ${response.statusCode}, ${await response.stream.bytesToString()}');
          _updateFileShareState(fileBubble.id, FileState.sendFailed);
        }
      });
    } on CancelException catch (e, stackTrace) {
      talker.warning('发送取消: $e', e, stackTrace);
    } catch (e, stackTrace) {
      talker.error('发送异常: $e', e, stackTrace);
      _updateFileShareState(fileBubble.id, FileState.sendFailed);
    }
  }

  Future<PrimitiveBubble> _updateFileShareState(
    String bubbleId, FileState state,
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
      copyBubble = _bubble.copy(content: _bubble.content.copy(state: state, waitingForAccept: waitingForAccept));
    }
    await _bubblePool.add(copyBubble);
    return copyBubble;
  }

  Future<void> checkCancel(String bubbleId,
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

  Future<void> cancelSend(UIBubble uiBubble) async {
    // tasks[bubbleId]?.cancel();
    final bubble = fromUIBubble(uiBubble) as PrimitiveFileBubble;
    await _updateFileShareState(bubble.id, FileState.cancelled, create: bubble);
    await sendCancelMessage(bubble.id, bubble.to);
  }

  Future<void> cancelReceive(UIBubble uiBubble) async {
    final bubble = fromUIBubble(uiBubble) as PrimitiveFileBubble;
    await _updateFileShareState(bubble.id, FileState.cancelled, create: bubble);
  }

  Future<void> resend(UIBubble uiBubble) async {
    final bubble = fromUIBubble(uiBubble) as PrimitiveFileBubble;
    await _updateFileShareState(bubble.id, FileState.waitToAccepted, create: bubble);
    await _send(bubble.copy(
        content: bubble.content.copy(state: FileState.waitToAccepted)));
  }

  Future<void> confirmReceiveFile(String from, String bubbleId) async {
    try {
      // 更新接收方状态为接收中
      await _updateFileShareState(bubbleId, FileState.inTransit, waitingForAccept: false);
      var uri = Uri.parse(intentUrl(from));

      var response = await http.post(
        uri,
        body: TransIntent(
                deviceId: DeviceManager.instance.did,
                bubbleId: bubbleId,
                action: TransAction.confirmReceive)
            .toJson(),
        headers: {"Content-type": "application/json; charset=UTF-8"},
      );

      if (response.statusCode == 200) {
        talker.debug('发送成功: response: ${response.body}');
      } else {
        talker.error('发送失败: status code: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      talker.error('confirmReceiveFile failed: $e', e);
    }
  }

  Future<void> sendCancelMessage(String bubbleId, String to) async {
    try {
      await _updateFileShareState(bubbleId, FileState.cancelled);
      var uri = Uri.parse(intentUrl(to));

      var response = await http.post(
        uri,
        body: TransIntent(
                deviceId: DeviceManager.instance.did,
                bubbleId: bubbleId,
                action: TransAction.cancel)
            .toJson(),
        headers: {"Content-type": "application/json; charset=UTF-8"},
      );

      if (response.statusCode == 200) {
        talker.debug('sendCancelMessage发送成功: response: ${response.body}');
      } else {
        talker.error('sendCancelMessage发送失败: status code: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      talker.error('sendCancelMessage failed: $e', e);
    }
  }


}
