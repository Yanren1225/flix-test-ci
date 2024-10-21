import 'dart:async';

import 'package:flix/domain/hotspot/hotspot_manager.dart';
import 'package:flix/domain/lifecycle/app_lifecycle.dart';
import 'package:flix/presentation/basic/corner/flix_decoration.dart';
import 'package:flix/presentation/style/colors/flix_color.dart';
import 'package:flix/presentation/style/flix_text_style.dart';
import 'package:flix/presentation/widgets/flix_toast.dart';
import 'package:flix/theme/theme_extensions.dart';
import 'package:flix/utils/permission/flix_permission_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:wifi_iot/wifi_iot.dart';

import '../../../l10n/l10n.dart';

class HotspotScreen extends StatefulWidget {
  bool showBack = true;

  HotspotScreen({Key? key, required this.showBack}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return HotspotScreenState();
  }
}

class HotspotScreenState extends State<HotspotScreen>
    implements LifecycleListener {
  ApState _apState = ApState.checking;
  String _sPreviousAPSSID = "";
  String _sPreviousPreSharedKey = "";

  @override
  void initState() {
    super.initState();
    appLifecycle.addListener(this);
    _initAp(false);
  }

  @override
  void dispose() {
    appLifecycle.removeListener(this);
    super.dispose();
  }

  _initAp(bool refresh) {
    if (refresh && _apState == ApState.checking ||
        _apState == ApState.enabling) {
      return;
    }
    if (!refresh) {
      _setApState(ApState.checking);
    } else if (_apState == ApState.noPermission) {
      _setApState(ApState.checking);
    }
    Future.delayed(Duration.zero).then((value) {
      FlixPermissionUtils.checkHotspotPermission(this.context)
          .then((value) async {
        if (value) {
          if (!await WiFiForIoTPlugin.isEnabled()) {
            _setApState(ApState.wifiDisabled);
            return;
          }
          // 尝试获取Ap信息，若失败说明hotspot未开启
          if (!(await _initApInfos())) {
            if (!refresh) {
              _setApState(ApState.enabling);
            }

            if (await hotspotManager.enableHotspot()) {
              if (!(await _initApInfos())) {
                _setApState(ApState.getApInfoFailed);
              }
            } else {
              _setApState(ApState.enableFailed);
            }
          }
        } else {
          _setApState(ApState.noPermission);
        }
      });
    });
  }

  _retry() async {
    _setApState(ApState.checking);
    await hotspotManager.disableHotspot();
    _initAp(false);
  }

  _setApState(ApState state) {
    if (mounted) {
      setState(() {
        _apState = state;
      });
    }
  }

  Future<bool> _initApInfos() async {
    await Future.delayed(const Duration(seconds: 1));
    final hotspotInfo = await hotspotManager.getHotspotInfo();
    if (hotspotInfo == null) return false;
    if (mounted) {
      setState(() {
        _apState = ApState.enabled;
        _sPreviousAPSSID = hotspotInfo.ssid;
        _sPreviousPreSharedKey = hotspotInfo.key;
      });
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).flixColors.background.secondary,
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
        backgroundColor: Theme.of(context).flixColors.background.secondary,
        surfaceTintColor: Theme.of(context).flixColors.background.secondary,
      ),
      body: () {
        final Widget content;
        switch (_apState) {
          case ApState.checking:
            content = _buildLoadingContent(S.of(context).hotspot_initializing);
            break;
          case ApState.enabling:
            content = _buildLoadingContent(S.of(context).hotspot_enabling);
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
          case ApState.getApInfoFailed:
            content = _buildGetApInfoFailedContent();
            break;
          case ApState.wifiDisabled:
            content = _buildWifiDisabledContent();
            break;
        }
        return content;
      }(),
    );
  }

  Widget _buildLoadingContent(String label) {
    return buildHotspotContent(
        context: this.context, label: label, color: FlixColor.orange);
  }

  Widget _buildEnabledContent() {
    return Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
                child: Text(S.of(context).hotspot_my_qrcode,
                    style: this.context.h1()),
              )),
          Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(S.of(context).hotspot_qrcode_tip,
                    style: this.context.titleSecondary()),
              )),
          const SizedBox(
            height: 20,
          ),
          SizedBox(
              width: 200,
              height: 200,
              child: QrImageView(
                  eyeStyle: QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Theme.of(this.context).flixColors.text.primary,
                  ),
                  dataModuleStyle: QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: Theme.of(this.context).flixColors.text.primary),
                  data: _encodeApInfo(),
                  padding: const EdgeInsets.all(25.0))),
          const SizedBox(
            height: 10,
          ),
          buildApInfoWidget(
              this.context, _sPreviousAPSSID, _sPreviousPreSharedKey)
        ]);
  }

  Widget _buildEnableFailedContent() {
    return buildHotspotContent(
        context: this.context,
        label: S.of(context).hotspot_enable_failed,
        color: FlixColor.red,
        action: S.of(context).hotspot_enable_failed_action,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(S.of(context).hotspot_enable_failed_tip,
              style: this.context.body()),
        ),
        onTap: () {
          _retry();
        });
  }

  Widget _buildNoPermissionContent() {
    return buildHotspotContent(
        context: this.context,
        label: S.of(context).hotspot_missing_permission,
        color: FlixColor.red,
        action: S.of(context).hotspot_missing_permission_action,
        onTap: () {
          _initAp(false);
        });
  }

  Widget _buildGetApInfoFailedContent() {
    return buildHotspotContent(
        context: this.context,
        label: S.of(context).hotspot_get_ap_info_failed,
        color: FlixColor.red,
        action: S.of(context).hotspot_get_ap_info_failed_action,
        onTap: () {
          _initAp(false);
        });
  }

  Widget _buildDisabledContent() {
    return buildHotspotContent(
        context: this.context,
        label: S.of(context).hotspot_disabled,
        color: FlixColor.red,
        action: S.of(context).hotspot_disabled_action,
        onTap: () {
          _initAp(false);
        });
  }

  String _encodeApInfo() {
    final uri = Uri(scheme: "https", host: "flix.center", pathSegments: [
      'qrcode',
      'ap',
      _sPreviousAPSSID,
      _sPreviousPreSharedKey
    ]);
    return uri.toString();
  }

  Widget _buildWifiDisabledContent() {
    return buildHotspotContent(
        context: this.context,
        label: S.of(context).hotspot_wifi_disabled,
        color: FlixColor.red,
        action: S.of(context).hotspot_wifi_disabled_action,
        onTap: () async {
          await WiFiForIoTPlugin.setEnabled(true, shouldOpenSettings: true);
          await Future.delayed(const Duration(seconds: 1));
          await _initAp(false);
          if (_apState == ApState.wifiDisabled) {
            await Future.delayed(const Duration(seconds: 1));
            await _initAp(false);
          }
        });
  }

  @override
  void onLifecycleChanged(AppLifecycleState state) {
    if (AppLifecycleState.resumed == state) {
      _initAp(true);
    }
  }
}

enum ApState {
  checking,
  disabled,
  enabling,
  enabled,
  enableFailed,
  getApInfoFailed,
  noPermission,
  wifiDisabled,
}

Widget buildHotspotContent(
    {required BuildContext context,
    required String label,
    required Color color,
    Widget? child,
    String? action,
    VoidCallback? onTap}) {
  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                  width: 40,
                  height: 40,
                  child: SvgPicture.asset(
                    "assets/images/ic_ap.svg",
                    width: 40,
                    height: 40,
                    colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                  )),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  label,
                  style: context.h2().copyWith(color: color),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              child ?? const SizedBox()
            ],
          ),
        ),
        Visibility(
            visible: action != null,
            child: InkWell(
                onTap: onTap,
                child: Padding(
                  padding:
                      const EdgeInsets.only(left: 16, right: 16, bottom: 50),
                  child: Container(
                      width: double.infinity,
                      height: 54,
                      decoration: FlixDecoration(
                          color: FlixColor.blue,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(16))),
                      child: Center(
                        child: Text(
                          action ?? "",
                          style: context.onButton(),
                          textAlign: TextAlign.center,
                        ),
                      )),
                ))),
      ],
    ),
  );
}

Widget buildApInfoWidget(BuildContext context, String ssid, String ssidKey) {
  return Align(
    alignment: Alignment.topCenter,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(S.of(context).hotspot_info_ssid, style: context.body()),
              Text(ssid, style: context.body())
            ]),
        const SizedBox(
          height: 2,
        ),
        InkWell(
          onTap: () {
            Clipboard.setData(ClipboardData(text: ssidKey));
            FlixToast.withContext(context).info(S.of(context).toast_copied);
          },
          child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(S.of(context).hotspot_info_password,
                    style: context.body()),
                Text(ssidKey, style: context.bodyVariant()),
                const SizedBox(
                  width: 8,
                ),
                SvgPicture.asset("assets/images/ic_copy_passwd.svg")
              ]),
        ),
      ],
    ),
  );
}
