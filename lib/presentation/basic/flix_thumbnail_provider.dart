import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/utils/file/file_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:flix_rust/image_compress.dart' as native_compress;

final _providerLocks = <FlixThumbnailProvider, Completer<Codec>>{};
final photoManagerPlugin = PhotoManagerPlugin();

// win不支持展示heic图片
// Android9以下设备对heif的支持
class FlixThumbnailProvider extends ImageProvider<FlixThumbnailProvider> {
  final String id;
  final String? resourceId;
  final String? resourcePath;
  final int preferWidth;
  final int preferHeight;


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
    final cachePath = await getTmpPath();
    final thumbnailDir = Directory('$cachePath/thumbnail');
    if (!(await thumbnailDir.exists())) {
      await thumbnailDir.create(recursive: true);
    }
    return '${thumbnailDir.path}/${key.id}.jpg';
  }

  Future<XFile?> _compressImage(FlixThumbnailProvider key) async {
    if (Platform.isWindows || Platform.isLinux) {
      final bytes = await native_compress.contain(
          pathStr: key.resourcePath!,
          compressFormat: native_compress.CompressFormat.jpeg,
          quality: 90,
          maxWidth: key.preferWidth,
          maxHeight: key.preferHeight,
          samplingFilter: native_compress.FilterType.lanczos3);

      final thumbnailFile = File(await _getThumbnailCachePath(key));
      if (!(await thumbnailFile.exists())) {
        await thumbnailFile.create();
      }
      await thumbnailFile.writeAsBytes(bytes, flush: true);
      return XFile(thumbnailFile.path);
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
        // Depending on where the exception was thrown, the image cache may not
        // have had a chance to track the key in the cache at all.
        // Schedule a microtask to give the cache a chance to add the key.
        talker.error('Failed to load the image: $key', e, s);
        if (key.resourcePath != null && key.resourcePath!.isNotEmpty) {
          try {
            return await _loadByFlutterMethod(key, decode);
          } catch (e, s) {
            talker.error('Failed to load the image: $key with back-up method', e, s);
            Future<void>.microtask(() => _evictCache(key));
            rethrow;
          }
        } else {
          Future<void>.microtask(() => _evictCache(key));
          rethrow;
        }
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
      option = const ThumbnailOption(
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

  Future<Codec> _loadByFlutterMethod(FlixThumbnailProvider key,
      ImageDecoderCallback decode, ) async {
    Future<Codec> decodeResize(ImmutableBuffer buffer, {TargetImageSizeCallback? getTargetSize}) {
      assert(
      getTargetSize == null,
      'ResizeImage cannot be composed with another ImageProvider that applies '
          'getTargetSize.',
      );
      return decode(buffer, getTargetSize: (int intrinsicWidth, int intrinsicHeight) {
            final double aspectRatio = intrinsicWidth / intrinsicHeight;
            final int maxWidth = key.preferWidth;
            final int maxHeight = key.preferHeight;
            int targetWidth = intrinsicWidth;
            int targetHeight = intrinsicHeight;

            if (targetWidth > maxWidth) {
              targetWidth = maxWidth;
              targetHeight = targetWidth ~/ aspectRatio;
            }

            if (targetHeight > maxHeight) {
              targetHeight = maxHeight;
              targetWidth = (targetHeight * aspectRatio).floor();
            }

            return TargetImageSize(width: targetWidth, height: targetHeight);
      });
    }

    final file = File(key.resourcePath!);
    final int lengthInBytes = await file.length();
    if (lengthInBytes == 0) {
      // The file may become available later.
      PaintingBinding.instance.imageCache.evict(key);
      throw StateError('$file is empty and cannot be loaded as an image.');
    }

    return (file.runtimeType == File)
        ? decodeResize(await ImmutableBuffer.fromFilePath(file.path))
        : decodeResize(await ImmutableBuffer.fromUint8List(await file.readAsBytes()));
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
