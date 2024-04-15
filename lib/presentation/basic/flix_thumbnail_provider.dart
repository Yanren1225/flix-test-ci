
import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

final _providerLocks = <FlixThumbnailProvider, Completer<Codec>>{};
final photoManagerPlugin = PhotoManagerPlugin();

class FlixThumbnailProvider extends ImageProvider<FlixThumbnailProvider> {

  final String resourceId;

  FlixThumbnailProvider({required this.resourceId});

  @override
  Future<FlixThumbnailProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<FlixThumbnailProvider>(this);
  }

  @override
  ImageStreamCompleter loadImage(FlixThumbnailProvider key,
      ImageDecoderCallback decode) {
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

  Future<Codec> _loadAsync(FlixThumbnailProvider key,
      ImageDecoderCallback decode, // ignore: deprecated_member_use
      ) {
    if (_providerLocks.containsKey(key)) {
      return _providerLocks[key]!.future;
    }
    final lock = Completer<Codec>();
    _providerLocks[key] = lock;
    Future(() async {
      try {
        assert(key == this);

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
            id: key.resourceId, option: option);

        if (data == null) {
          throw StateError('The data of the entity is null: ${key.resourceId}');
        }
        final buffer = await ImmutableBuffer.fromUint8List(data);
        return decode(buffer);
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
    return resourceId == other.resourceId;
  }

  @override
  int get hashCode =>
      resourceId.hashCode;

}
