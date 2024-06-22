import 'dart:io';

import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/presentation/basic/corner/flix_clip_r_rect.dart';
import 'package:flix/presentation/screens/hotpots/connect_hotspot_screen.dart';
import 'package:flix/presentation/style/colors/flix_color.dart';
import 'package:flix/presentation/style/flix_text_style.dart';
import 'package:flix/presentation/widgets/flix_toast.dart';
import 'package:flix/presentation/widgets/segements/navigation_scaffold.dart';
import 'package:flix/utils/permission/flix_permission_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class HotpotsScannerScreen extends StatefulWidget {
  bool showBack;

  HotpotsScannerScreen({super.key, this.showBack = true});

  @override
  State<StatefulWidget> createState() {
    return _HotpotsScannerScreenState();
  }
}

class _HotpotsScannerScreenState extends State<HotpotsScannerScreen> {
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
        backgroundColor: FlixColor.surface,
        appBar: AppBar(
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(
              Icons.arrow_back,
              color: Colors.black,
              size: 20,
            ),
          ),
          backgroundColor: FlixColor.surface,
          surfaceTintColor: FlixColor.surface,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("扫一扫", style: FlixTextStyle.h1),
              Text("打开 Flix 二维码，快速建立热点连接。",
                  style: FlixTextStyle.title_secondary),
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
    controller.scannedDataStream.listen((scanData) {
      if (result != null) return;
      talker.info("qrcode result: ${scanData.code}");
      if (scanData.code?.startsWith("qrcode://") == true) {
        final uri = Uri.parse(scanData!.code!);
        if (uri.host == "ap" && uri.pathSegments.length >= 2) {
          result = scanData;
          Navigator.of(context).pushReplacement(CupertinoPageRoute(
            builder: (context) => ConnectHotspotScreen(
              apSSID: uri.pathSegments[0],
              apKey: uri.pathSegments[1],
            ),
          ));
        }
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
