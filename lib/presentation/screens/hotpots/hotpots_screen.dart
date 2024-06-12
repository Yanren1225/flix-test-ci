import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/presentation/style/colors/flix_color.dart';
import 'package:flix/presentation/style/flix_text_style.dart';
import 'package:flix/presentation/widgets/flix_toast.dart';
import 'package:flix/presentation/widgets/segements/navigation_scaffold.dart';
import 'package:flix/utils/flix_permission_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:wifi_iot/wifi_iot.dart';

class HotpotsScreen extends StatefulWidget {
  bool showBack = true;

  HotpotsScreen({Key? key, required this.showBack}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return HotpotsScreenState();
  }
}

class HotpotsScreenState extends State<HotpotsScreen>
    with WidgetsBindingObserver {
  ApState _apState = ApState.checking;
  String _sPreviousAPSSID = "";
  String _sPreviousPreSharedKey = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initAp();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.resumed:
        _initAp();
        break;
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.hidden:
    }
  }

  _initAp() {
    _setApState(ApState.checking);
    FlixPermissionUtils.checkNearbyPermission(context).then((value) {
      if (value) {
        WiFiForIoTPlugin.isWiFiAPEnabled().then((isEnabled) async {
          if (isEnabled) {
            await _initApInfos();
          } else {
            _setApState(ApState.enabling);
            if (await WiFiForIoTPlugin.setWiFiAPEnabled(true)) {
              await _initApInfos();
            } else {
              talker.error("Failed to enable WiFi AP");
              _setApState(ApState.enableFailed);
            }
          }
        }).catchError((error, stack) {
          talker.error("Failed to check WiFi AP state", error, stack);
          _setApState(ApState.enableFailed);
        });
      } else {
        talker.error("No permission to enable WiFi AP");
        _setApState(ApState.noPermission);
      }
    });
  }

  _setApState(ApState state) {
    setState(() {
      _apState = state;
    });
  }

  _initApInfos() async {
    String? sAPSSID;
    String? sPreSharedKey;

    try {
      sAPSSID = await WiFiForIoTPlugin.getWiFiAPSSID();
    } on PlatformException {
      sAPSSID = "";
    }

    try {
      sPreSharedKey = await WiFiForIoTPlugin.getWiFiAPPreSharedKey();
    } on PlatformException {
      sPreSharedKey = "";
    }

    setState(() {
      _apState = ApState.enabled;
      _sPreviousAPSSID = sAPSSID ?? "";
      _sPreviousPreSharedKey = sPreSharedKey ?? "";
    });
  }

  // [sAPSSID, sPreSharedKey]
  Future<List<String>> getWiFiAPInfos() async {
    String? sAPSSID;
    String? sPreSharedKey;

    try {
      sAPSSID = await WiFiForIoTPlugin.getWiFiAPSSID();
    } on Exception {
      sAPSSID = "";
    }

    try {
      sPreSharedKey = await WiFiForIoTPlugin.getWiFiAPPreSharedKey();
    } on Exception {
      sPreSharedKey = "";
    }

    return [sAPSSID!, sPreSharedKey!];
  }

  @override
  Widget build(BuildContext context) {
    return NavigationScaffold(
      title: "我的二维码",
      showBackButton: widget.showBack,
      builder: (EdgeInsets padding) {
        final Widget content;
        switch (_apState) {
          case ApState.checking:
            content = _buildLoadingContent("正在初始化热点");
            break;
          case ApState.enabling:
            content = _buildLoadingContent("正在开启热点");
            break;
          case ApState.disabled:
            content = _buildDisabledContent();
            break;
          case ApState.enabled:
            content = _buildEnabledContent();
            break;
          case ApState.enableFailed:
            content = _buildEnableFailedContent();
            break;
          case ApState.noPermission:
            content = _buildNoPermissionContent();
            break;
        }
        return Padding(
          padding: EdgeInsets.only(left: 20, right: 20, top: padding.top),
          child: content,
        );
      },
    );
  }

  Widget _buildLoadingContent(String label) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                backgroundColor: Colors.transparent,
                color: FlixColor.blue,
                strokeWidth: 2.0,
              )),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              label,
              style: FlixTextStyle.body,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildEnabledContent() {
    return Center(
      child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
                alignment: Alignment.topLeft,
                child: Text("打开 Flix 扫一扫，快速建立热点连接。",
                    style: FlixTextStyle.head_secondary)),
            SizedBox(
                width: 200,
                height: 200,
                child: QrImageView(
                    data: _encodeApInfo(),
                    padding: const EdgeInsets.all(25.0))),
            Align(
              alignment: Alignment.topCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                Text("热点名称：", style: FlixTextStyle.body),
                Text(_sPreviousAPSSID, style: FlixTextStyle.body)
              ]),
            ),
            const SizedBox(
              height: 2,
            ),
            InkWell(
              onTap: () {
                Clipboard.setData(ClipboardData(text: _sPreviousPreSharedKey));
                flixToast.info("已复制热点密码到剪切板");
              },
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [
                Text("热点密码：", style: FlixTextStyle.body),
                Text(_sPreviousPreSharedKey, style: FlixTextStyle.body_variant),
                const SizedBox(width: 8,),
                SvgPicture.asset("assets/images/ic_copy_passwd.svg")
              ]),
            ),
          ]),
    );
  }

  Widget _buildEnableFailedContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset("assets/images/ic_permissions.svg"),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              "开启热点失败",
              style: FlixTextStyle.body.copyWith(color: FlixColor.red),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildNoPermissionContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset("assets/images/ic_permissions.svg"),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              "没有权限开启热点，点击申请",
              style: FlixTextStyle.body.copyWith(color: FlixColor.red),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDisabledContent() {
    return Center(
      child: InkWell(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset("assets/images/ic_permissions.svg"),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                "热点已关闭，点击开启",
                style: FlixTextStyle.body.copyWith(color: FlixColor.blue),
              ),
            )
          ],
        ),
      ),
    );
  }

  String _encodeApInfo() {
    final uri = Uri(scheme: "qrcode", host: "ap", pathSegments: [_sPreviousAPSSID, _sPreviousPreSharedKey]);
    return uri.toString();
  }

}

enum ApState {
  checking,
  disabled,
  enabling,
  enabled,
  enableFailed,
  noPermission
}
