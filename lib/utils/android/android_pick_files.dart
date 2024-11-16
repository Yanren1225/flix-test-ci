

import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flix/utils/android/android_file_info.dart';
import 'package:flutter/services.dart';


import 'android_picker_result.dart';

const MethodChannel _channel = MethodChannel(
  'com.ifreedomer.flix.plugins.android_filepicker',
  StandardMethodCodec(),
);

const EventChannel _eventChannel =
EventChannel('com.ifreedomer.flix.plugins.android_filepickerevent');

class AndroidPickFiles {

  static StreamSubscription? _eventSubscription;

  static Future<AndroidFilePackerResult?> pickFiles({
    FileType fileType = FileType.any,
    List<String>? allowedExtensions,
    String? dialogTitle,
    String? initialDirectory,
    Function(FilePickerStatus)? onFileLoading,
    bool? allowCompression = false,
    bool allowMultipleSelection = false,
    bool? withData = false,
    int compressionQuality = 100,
    bool? withReadStream = false,
    bool lockParentWindow = false,
    bool readSequential = false,
  }) async {
    final String type = fileType.name;
    if (type != 'custom' && (allowedExtensions?.isNotEmpty ?? false)) {
      throw ArgumentError.value(
        allowedExtensions,
        'allowedExtensions',
        'Custom extension filters are only allowed with FileType.custom. '
            'Remove the extension filter or change the FileType to FileType.custom.',
      );
    }
    try {
      _eventSubscription?.cancel();
      if (onFileLoading != null) {
        _eventSubscription = _eventChannel.receiveBroadcastStream().listen(
              (data) => onFileLoading((data as bool)
              ? FilePickerStatus.picking
              : FilePickerStatus.done),
          onError: (error) => throw Exception(error),
        );
      }
      final List<Map>? result = await _channel.invokeListMethod(type, {
        'allowMultipleSelection': allowMultipleSelection,
        'allowedExtensions': allowedExtensions,
        'allowCompression': allowCompression,
        'withData': withData,
        'compressionQuality': compressionQuality,
      });

      if (result == null) {
        return null;
      }

      final List<FileInfo> files = <FileInfo>[];
      for (final Map infoMap in result) {
        files.add(
          FileInfo(
            name: infoMap['name'] ?? "",
            path: infoMap['path'] ?? "",
            size: infoMap['size'] ?? -1,
            uri: infoMap['uri']??""
          )
        );
      }


      return AndroidFilePackerResult(files);

    } catch (e) {
      print(e);
      return null;
    }
  }

}