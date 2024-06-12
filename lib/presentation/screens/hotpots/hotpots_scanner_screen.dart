import 'dart:io';

import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/presentation/screens/hotpots/connect_hotpots_screen.dart';
import 'package:flix/presentation/widgets/segements/navigation_scaffold.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
    Permission.camera.request();
  }

  @override
  Widget build(BuildContext context) {
    return _buildScannerWidget();
  }

  Widget _buildScannerWidget() {
    return NavigationScaffold(
        title: "我的二维码",
        showBackButton: widget.showBack,
        builder: (EdgeInsets padding) {
          return Column(
            children: <Widget>[
              Expanded(
                flex: 5,
                child: QRView(
                  key: qrKey,
                  onQRViewCreated: _onQRViewCreated,
                ),
              ),
              Expanded(
                flex: 1,
                child: Center(
                  child: (result != null)
                      ? Text(
                          'Barcode Type: ${describeEnum(result!.format)}   Data: ${result!.code}')
                      : Text('Scan a code'),
                ),
              )
            ],
          );
        });
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
            builder: (context) => ConnectHotpotsScreen(
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
