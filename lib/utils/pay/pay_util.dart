import 'dart:io';

import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/utils/file/file_helper.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:shared_storage/shared_storage.dart';
import 'package:slang/builder/utils/file_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class PayUtil {
  static const PAY_CHANNEL = MethodChannel("com.ifreedomer.flix/pay");

  static Future<void> startWechatQrCode() async {
    await saveImageToGallery('assets/images/donate_wechat.png');
    if (Platform.isAndroid) {
      PAY_CHANNEL.invokeMethod("wechat_scan_qrcode");
    }
    if (Platform.isIOS) {
      await launchUrl(Uri.parse("weixin://scanqrcode"));
    }
  }

  static Future<void> startAlipayQrCode() async {
    await saveImageToGallery('assets/images/donate_alipay.png');
    await launchUrl(Uri.parse("alipayqr://platformapi/startapp?saId=10000007"));
  }

  static Future<void> saveImageToGallery(String assetPath) async {
    // 假设你有一个名为 'image.png' 的图片在 assets 目录下
    final ByteData byteData = await rootBundle.load(assetPath);
    final List<int> bytes = byteData.buffer.asUint8List();

    // 获取存储路径
    final String? extDir = await getCachePath();
    final String filePath = '${extDir}/image_from_assets.png';

    // 将图片保存到文件
    final File file = File(filePath);
    await file.writeAsBytes(bytes);

    // 将图片添加到相册
    final result = await ImageGallerySaver.saveFile((filePath));
    talker.debug('Image saved to gallery: $result');
  }
}
