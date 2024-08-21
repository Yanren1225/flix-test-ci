import 'dart:io';

import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/domain/uri_router.dart';
import 'package:flix/presentation/basic/corner/flix_clip_r_rect.dart';
import 'package:flix/presentation/screens/hotpots/connect_hotspot_screen.dart';
import 'package:flix/presentation/style/flix_text_style.dart';
import 'package:flix/presentation/widgets/flix_toast.dart';
import 'package:flix/theme/theme_extensions.dart';
import 'package:flix/utils/permission/flix_permission_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QrcodeScanScreen extends StatefulWidget {
  bool showBack;

  QrcodeScanScreen({super.key, this.showBack = true});

  @override
  State<StatefulWidget> createState() {
    return _QrcodeScanScreenState();
  }
}

class _QrcodeScanScreenState extends State<QrcodeScanScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  @override
  void initState() {
    super.initState();
    FlixPermissionUtils.checkCameraPermission(context).then((value) {
      if (!value) {
        talker.error("没有相机权限");
        flixToast.alert("没有相机权限");
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _buildScannerWidget();
  }

  Widget _buildScannerWidget() {
    return Scaffold(
        backgroundColor: Theme.of(context).flixColors.background.secondary,
        appBar: AppBar(
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back,
              color: Theme.of(context).flixColors.text.primary,
              size: 20,
            ),
          ),
          backgroundColor: Theme.of(context).flixColors.background.secondary,
          surfaceTintColor: Theme.of(context).flixColors.background.secondary,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("扫一扫", style: context.h1()),
              Text("打开 Flix 二维码，快速建立热点连接。", style: context.titleSecondary()),
              const SizedBox(height: 40),
              FlixClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: QRView(
                    key: qrKey,
                    onQRViewCreated: _onQRViewCreated,
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      if (result != null) return;
      talker.info("qrcode result: ${scanData.code}");
      if (scanData.code?.startsWith("https://flix.center/qrcode/") == true) {
        final uri = scanData.code!
            .replaceFirst("https://flix.center/qrcode/", "qrcode://");
        await uriRouter.navigateTo(context, uri);
        result = Barcode(
          uri,
          BarcodeFormat.qrcode,
          scanData.rawBytes,
        );
      } else if (scanData.code?.startsWith("qrcode://") == true) {
        result = scanData;
        await uriRouter.navigateTo(context, scanData.code!);
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
