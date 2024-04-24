import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'dart:ui';

import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/utils/file/file_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:simple_native_image_compress/simple_native_image_compress.dart'
    as nativeCompress;
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

final _providerLocks = <FlixThumbnailProvider, Completer<Codec>>{};
final photoManagerPlugin = PhotoManagerPlugin();

// Android9以下设备对heif的支持
class FlixThumbnailProvider extends ImageProvider<FlixThumbnailProvider> {
  final String id;
  final String? resourceId;
  final String? resourcePath;
  final int preferWidth;
  final int preferHeight;

  static final compress = nativeCompress.SimpleNativeImageCompress();

  FlixThumbnailProvider(
      {required this.id,
      required this.resourceId,
      this.resourcePath,
      required this.preferWidth,
      required this.preferHeight});

  @override
  Future<FlixThumbnailProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<FlixThumbnailProvider>(this);
  }

  @override
  ImageStreamCompleter loadImage(
      FlixThumbnailProvider key, ImageDecoderCallback decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode),
      scale: 1.0,
      debugLabel: 'FlixThumbnailProvider ${key.resourceId}',
      informationCollector: () {
        return <DiagnosticsNode>[
          DiagnosticsProperty<ImageProvider>('Image provider', this),
          DiagnosticsProperty<FlixThumbnailProvider>('Image key', key),
        ];
      },
    );
  }

  Future<bool> _isThumbnailCacheExist(FlixThumbnailProvider key) async {
    return await File(await _getThumbnailCachePath(key)).exists();
  }

  Future<String> _getThumbnailCachePath(FlixThumbnailProvider key) async {
    final cachePath = await getCachePath();
    final thumbnailDir = Directory('$cachePath/thumbnail');
    if (!(await thumbnailDir.exists())) {
      await thumbnailDir.create(recursive: true);
    }
    return '${thumbnailDir.path}/${key.id}.jpg';
  }

  Future<XFile?> _compressImage(FlixThumbnailProvider key) async {
    if (Platform.isWindows || Platform.isLinux) {
      final bytes = await compress.contain(
          filePath: key.resourcePath!,
          compressFormat: nativeCompress.CompressFormat.Jpeg,
          quality: 90,
          maxWidth: key.preferWidth,
          maxHeight: key.preferHeight,
          samplingFilter: nativeCompress.FilterType.Lanczos3);

      final thumbnailFile = File(await _getThumbnailCachePath(key));
      await thumbnailFile.create();
      await thumbnailFile.writeAsBytes(bytes);
    } else {
      File originalImage = File(key.resourcePath!); // 你的原始图片路径
      if (!await originalImage.exists()) {
        throw StateError(
            'The original image is not exist: ${key.resourcePath}');
      }

      return await FlutterImageCompress.compressAndGetFile(
          originalImage.path, await _getThumbnailCachePath(key), // 保存压缩后图片的路径
          minWidth: key.preferWidth, // 压缩质量，范围为0-100
          minHeight: key.preferHeight);
    }
  }

  Future<Codec> _loadAsync(
      FlixThumbnailProvider key, ImageDecoderCallback decode) async {
    if (_providerLocks.containsKey(key)) {
      return _providerLocks[key]!.future;
    }
    final lock = Completer<Codec>();
    _providerLocks[key] = lock;
    Future(() async {
      try {
        assert(key == this);
        if (await _isThumbnailCacheExist(key)) {
          return await _loadFromCacheAsync(key, decode);
        } else if (key.resourceId != null && key.resourceId!.isNotEmpty) {
          return await _loadByEntityAsync(key, decode);
        } else if (key.resourcePath != null && key.resourcePath!.isNotEmpty) {
          return await _cacheAndLoadAsync(key, decode);
        } else {
          throw StateError('The key is invalid: $key');
        }
      } catch (e, s) {
        if (kDebugMode) {
          FlutterError.presentError(
            FlutterErrorDetails(
              exception: e,
              stack: s,
            ),
          );
        }
        // Depending on where the exception was thrown, the image cache may not
        // have had a chance to track the key in the cache at all.
        // Schedule a microtask to give the cache a chance to add the key.
        Future<void>.microtask(() => _evictCache(key));
        rethrow;
      }
    }).then((codec) {
      lock.complete(codec);
    }).catchError((e, s) {
      lock.completeError(e, s);
    }).whenComplete(() {
      _providerLocks.remove(key);
    });
    return lock.future;
  }

  Future<Codec> _loadFromCacheAsync(
      FlixThumbnailProvider key, ImageDecoderCallback decode) async {
    final thumbnail = XFile(await _getThumbnailCachePath(key));
    final buffer =
        await ImmutableBuffer.fromUint8List(await thumbnail.readAsBytes());
    return decode(buffer);
  }

  Future<Codec> _cacheAndLoadAsync(
      FlixThumbnailProvider key, ImageDecoderCallback decode) async {
    assert(key == this);
    final thumbnail = await _compressImage(key);
    if (thumbnail == null) {
      throw StateError('the thumbnail is null: ${key.resourceId}');
    }
    final buffer =
        await ImmutableBuffer.fromUint8List(await thumbnail.readAsBytes());
    return decode(buffer);
  }

  Future<Codec> _loadByEntityAsync(
    FlixThumbnailProvider key,
    ImageDecoderCallback decode, // ignore: deprecated_member_use
  ) async {
    Uint8List? data;
    final ThumbnailOption option;
    if (Platform.isIOS || Platform.isMacOS) {
      option = ThumbnailOption.ios(
        size: pmDefaultGridThumbnailSize,
        format: ThumbnailFormat.jpeg,
      );
    } else {
      option = ThumbnailOption(
        size: pmDefaultGridThumbnailSize,
        format: ThumbnailFormat.jpeg,
        frame: 0,
      );
    }
    data = await photoManagerPlugin.getThumbnail(
        id: key.resourceId!, option: option);

    if (data == null) {
      throw StateError('The data of the entity is null: ${key.resourceId}');
    }
    final buffer = await ImmutableBuffer.fromUint8List(data);
    return decode(buffer);
  }

  static void _evictCache(FlixThumbnailProvider key) {
    // ignore: unnecessary_cast
    ((PaintingBinding.instance as PaintingBinding).imageCache as ImageCache)
        .evict(key);
  }

  @override
  bool operator ==(Object other) {
    if (other is! FlixThumbnailProvider) {
      return false;
    }
    if (identical(this, other)) {
      return true;
    }
    return id == id &&
        resourceId == other.resourceId &&
        resourcePath == resourcePath;
  }

  @override
  int get hashCode => id.hashCode ^ resourceId.hashCode ^ resourcePath.hashCode;

  @override
  String toString() {
    return 'FlixThumbnailProvider(id: $id, resourceId: $resourceId, resourcePath: $resourcePath)';
  }
}
