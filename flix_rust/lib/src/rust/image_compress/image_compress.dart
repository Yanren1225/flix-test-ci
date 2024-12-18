// This file is automatically generated, so please do not edit it.
// @generated by `flutter_rust_bridge`@ 2.5.1.

// ignore_for_file: invalid_use_of_internal_member, unused_import, unnecessary_import

import '../frb_generated.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

// These functions are ignored because they are not marked as `pub`: `check_orientation`, `compress`, `convert_filter_type`, `encode_dyn_img_to_bytes`, `encode_img_buffer_to_bytes`, `rotate`
// These function are ignored because they are on traits that is not defined in current crate (put an empty `#[frb]` on it to unignore): `assert_receiver_is_total_eq`, `assert_receiver_is_total_eq`, `eq`, `eq`

Future<Uint8List> fitWidth(
        {required String pathStr,
        CompressFormat? compressFormat,
        int? maxWidth,
        int? quality,
        FilterType? samplingFilter}) =>
    RustLib.instance.api.crateImageCompressImageCompressFitWidth(
        pathStr: pathStr,
        compressFormat: compressFormat,
        maxWidth: maxWidth,
        quality: quality,
        samplingFilter: samplingFilter);

Future<Uint8List> fitHeight(
        {required String pathStr,
        CompressFormat? compressFormat,
        int? maxHeight,
        int? quality,
        FilterType? samplingFilter}) =>
    RustLib.instance.api.crateImageCompressImageCompressFitHeight(
        pathStr: pathStr,
        compressFormat: compressFormat,
        maxHeight: maxHeight,
        quality: quality,
        samplingFilter: samplingFilter);

Future<Uint8List> contain(
        {required String pathStr,
        CompressFormat? compressFormat,
        int? maxWidth,
        int? maxHeight,
        int? quality,
        FilterType? samplingFilter}) =>
    RustLib.instance.api.crateImageCompressImageCompressContain(
        pathStr: pathStr,
        compressFormat: compressFormat,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        quality: quality,
        samplingFilter: samplingFilter);

enum CompressFormat {
  jpeg,
  webP,
  ;
}

enum FilterType {
  nearest,
  triangle,
  catmullRom,
  gaussian,
  lanczos3,
  ;
}
