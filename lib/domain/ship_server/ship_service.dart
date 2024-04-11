import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flix/domain/bubble_pool.dart';
import 'package:flix/domain/device/ap_interface.dart';
import 'package:flix/domain/device/device_manager.dart';
import 'package:flix/domain/device/device_profile_repo.dart';
import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/domain/settings/SettingsRepo.dart';
import 'package:flix/model/intent/trans_intent.dart';
import 'package:flix/model/ship/primitive_bubble.dart';
import 'package:flix/model/ui_bubble/shared_file.dart';
import 'package:flix/model/ui_bubble/ui_bubble.dart';
import 'package:flix/network/nearby_service_info.dart';
import 'package:flix/network/protocol/device_modal.dart';
import 'package:flix/network/protocol/ping_pong.dart';
import 'package:flix/presentation/screens/base_screen.dart';
import 'package:flix/utils/bubble_convert.dart';
import 'package:flix/utils/net/net_utils.dart';
import 'package:flix/utils/stream_cancelable.dart';
import 'package:flix/utils/stream_progress.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mutex/mutex.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_multipart/form_data.dart';
import 'package:shelf_multipart/multipart.dart';
import 'package:shelf_router/shelf_router.dart';

import '../../utils/file/file_helper.dart';

class ShipService extends ApInterface {
  ShipService._privateConstruct();

  static final ShipService _instance = ShipService._privateConstruct();

  static ShipService get instance => _instance;

  final _bubblePool = BubblePool.instance;

  int port = defaultPort;
  PongListener? _pongListener;
  HttpServer? _server;

  final lock = Mutex();

  // final Map<String, Cancelable> tasks = {};

  String intentUrl(String deviceId) {
    return 'http://${DeviceManager.instance.getNetAdressByDeviceId(deviceId)}/intent';
  }

  Future<bool> startShipServer() async {
    try {
      return await lock.protect(() async {
        return await _startShipServer();
      });
    } catch (e, stackTrace) {
      talker.error('start ship server failed', e, stackTrace);
      return false;
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
    final tmp = await _startShipServerInner(app, defaultPort, 'first', () async {
      return await Future.delayed(const Duration(seconds: 1), () async {
        return await _startShipServerInner(app, defaultPort + 1, 'second', () async {
          return await Future.delayed(const Duration(seconds: 2), () async {
            return await _startShipServerInner(app, defaultPort + 2, 'third', () async {});
          });
        });
      });
    });

    if (tmp != null) {
      _server = tmp;
      return true;
    }
    return false;
  }

  Future<bool> isServerLiving() async {
    try {
      var uri =
          Uri.parse('http://127.0.0.1:${port}/heartbeat');
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
      await lock.protect(() async {
        talker.debug('restart sever: $_server');
        await _server?.close(force: true);
        return await _startShipServer();
      });
    } catch (e, stacktrace) {
      talker.error('restart server failed: ', e, stacktrace);
    }
    return false;
  }

  Future<HttpServer?> _startShipServerInner(
      Router app, int serverPort, String tag, Future<HttpServer?> Function() onFailed) async {
    try {
      final server = await io.serve(app, '0.0.0.0', serverPort,
          shared: false);
      talker.debug('Serving at http://0.0.0.0:${serverPort}');
      port = serverPort;
      return server;
    } catch (e, stack) {
      talker.error(
          '$tag start server at http://0.0.0.0:${serverPort} failed ',
          e,
          stack);
      return await onFailed();
    }
  }

  Future<Response> _receiveBubble(Request request) async {
    try {
      var body = await request.readAsString();
      var data = jsonDecode(body) as Map<String, dynamic>;
      talker.debug("_receiveBubble===>",data);
      var bubble = PrimitiveBubble.fromJson(data);
      talker.debug("_receiveBubble result===>",data);
      if (await SettingsRepo.instance.getAutoReceiveAsync() &&
          bubble is PrimitiveFileBubble) {
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

  Future<Response> _receiveFile(Request request) async {
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
                final String desDir = SettingsRepo.instance.savedDir;

                if (formData.filename == null) {
                  throw ArgumentError('filename can\'t be null');
                }

                if (Platform.isAndroid) {
                  if (await checkStoragePermission(null)) {
                    await saveFileAndAddBubble(desDir, formData, bubble!);
                  } else {
                    talker.debug("_receiveFile storage permission denied");
                  }
                } else {
                  await saveFileAndAddBubble(desDir, formData, bubble!);
                }
              } on Error catch (e) {
                talker.error('receive file error: ', e);
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
      talker.warning('_receiveFile canceled, ', e, stacktrace);
      return Response.ok('canceled');
    } catch (e, stackTrace) {
      talker.error('_receiveFile failed, ', e, stackTrace);
      return Response.internalServerError();
    }
  }

  Future<void> saveFileAndAddBubble(
      String desDir, FormData formData, PrimitiveFileBubble bubble) async {
    File outFile = await saveFile(desDir, formData, bubble);
    // await Future.delayed(Duration(seconds: 5));
    final updatedBubble = bubble.copy(
        content: bubble.content.copy(
            state: FileState.receiveCompleted,
            progress: 1.0,
            meta: bubble.content.meta.copy(path: outFile.path)));
    // removeBubbleById(updatedBubble.id);
    await _bubblePool.add(updatedBubble);
  }

  Future<File> saveFile(
      String desDir, FormData formData, PrimitiveFileBubble bubble) async {
    final outFile = await createFile(desDir, formData.filename ?? '');

    final out = outFile.openWrite(mode: FileMode.write);

    talker.debug('writing file to ${outFile.path}');

    final bubbleId = bubble!.id;
    await formData.part
        .chain((Stream<List<int>> stream) async {
          await checkCancel(bubbleId);
        })
        .progress(bubbleId)
        .pipe(out);
    return outFile;
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
      talker.error('receive intent error: ', e, stackTrace);
      return Response.badRequest();
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
        _pongListener?.call(pong);
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

  @override
  void listenPong(PongListener listener) {
    this._pongListener = listener;
  }

  @override
  Future<void> pong(DeviceModal from, DeviceModal to) async {
    try {
      final message = Pong(from, to).toJson();
      var uri = Uri.parse(
          'http://${toNetAddress(to.ip, to.port)}/pong');
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
        talker.debug(
            '发送失败: status code: ${response.statusCode}, ${response.body}');
      }
    } on CancelException catch (e, stackTrace) {
      talker.warning('取消发送 bubble: ', e, stackTrace);
    } catch (e, stackTrace) {
      talker.error('send bubble failed', e, stackTrace);
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
      talker.warning('outer 取消发送: ', e, stackTrace);
    } catch (e, stackTrace) {
      talker.error('outer send failed: ', e, stackTrace);
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
      talker.warning('取消发送文件: ', e, stackTrace);
    } catch (e, stackTrace) {
      talker.error('发送异常: ', e, stackTrace);
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
          _deleteCachedFile(fileBubble, path);
        } else {
          talker.error(
              '发送失败: status code: ${response.statusCode}, ${await response.stream.bytesToString()}');
          _updateFileShareState(fileBubble.id, FileState.sendFailed);
        }
      });
    } on CancelException catch (e, stackTrace) {
      talker.warning('发送取消: ', e, stackTrace);
    } catch (e, stackTrace) {
      talker.error('发送异常: ', e, stackTrace);
      _updateFileShareState(fileBubble.id, FileState.sendFailed);
    }
  }

  Future<void> _deleteCachedFile(PrimitiveFileBubble fileBubble, String path) async {
    try {
      if (fileBubble.type == BubbleType.File && await isInCacheOrTmpDir(path)) {
        talker.info('delete cached file: $path');
        await File(path).delete();
        talker.info('delete cached file successfully: $path');
      }
    } catch (e, stackTrace) {
      talker.error('delete cached file failed', e, stackTrace);
    }
  }

  Future<PrimitiveBubble> _updateFileShareState(
      String bubbleId, FileState state,
      {PrimitiveFileBubble? create = null,
      bool? waitingForAccept = null}) async {
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
    await _updateFileShareState(bubble.id, FileState.waitToAccepted,
        create: bubble);
    await _send(bubble.copy(
        content: bubble.content.copy(state: FileState.waitToAccepted)));
  }

  Future<void> confirmReceiveFile(String from, String bubbleId) async {
    try {
      // 更新接收方状态为接收中
      await _updateFileShareState(bubbleId, FileState.inTransit,
          waitingForAccept: false);
      var uri = Uri.parse(intentUrl(from));

      var response = await http.post(
        uri,
        body: TransIntent(
                deviceId: DeviceProfileRepo.instance.did,
                bubbleId: bubbleId,
                action: TransAction.confirmReceive)
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

  Future<void> sendCancelMessage(String bubbleId, String to) async {
    try {
      await _updateFileShareState(bubbleId, FileState.cancelled);
      var uri = Uri.parse(intentUrl(to));

      var response = await http.post(
        uri,
        body: TransIntent(
                deviceId: DeviceProfileRepo.instance.did,
                bubbleId: bubbleId,
                action: TransAction.cancel)
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
}
