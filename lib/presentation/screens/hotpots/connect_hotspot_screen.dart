import 'dart:io';

import 'package:flix/domain/hotspot/direct_wifi_manager.dart';
import 'package:flix/domain/lifecycle/app_lifecycle.dart';
import 'package:flix/presentation/screens/hotpots/hotspot_screen.dart';
import 'package:flix/presentation/style/colors/flix_color.dart';
import 'package:flutter/material.dart';
import 'package:wifi_iot/wifi_iot.dart';

class ConnectHotspotScreen extends StatefulWidget {
  final String apSSID;
  final String apKey;

  const ConnectHotspotScreen(
      {super.key, required this.apSSID, required this.apKey});

  @override
  State<StatefulWidget> createState() {
    return ConnectHotspotScreenState();
  }
}

class ConnectHotspotScreenState extends State<ConnectHotspotScreen>
    implements LifecycleListener {
  WifiConnectionState _state = WifiConnectionState.init;

  @override
  void initState() {
    super.initState();
    appLifecycle.addListener(this);
    _initWifi(false);
  }

  @override
  void dispose() {
    appLifecycle.removeListener(this);
    super.dispose();
  }

  _initWifi(bool refresh) async {
    if (refresh && (_state == WifiConnectionState.init || _state == WifiConnectionState.connecting)) {
      return;
    }
    if (!refresh) {
      _setWifiState(WifiConnectionState.init);
    }
    if (Platform.isIOS || await WiFiForIoTPlugin.isEnabled()) {
      if (!refresh) {
        _setWifiState(WifiConnectionState.connecting);
      }
      if (await directWifiManager.connect(widget.apSSID,
          widget.apKey)) {
        _setWifiState(WifiConnectionState.connected);
      } else {
        _setWifiState(WifiConnectionState.failed);
      }
    } else {
      _setWifiState(WifiConnectionState.wifiDisabled);
    }
  }

  _setWifiState(WifiConnectionState state) {
    setState(() {
      _state = state;
    });
  }

  @override
  Widget build(BuildContext context) {
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
      body: () {
        final Widget content;
        switch (_state) {
          case WifiConnectionState.init:
            content = _buildLoadingContent("正在初始化WiFi");
            break;
          case WifiConnectionState.wifiDisabled:
            content = _buildWifiDisabledContent();
            break;
          case WifiConnectionState.connecting:
            content = _buildLoadingContent("正在连接热点");
            break;
          case WifiConnectionState.connected:
            content = _buildConnectedContent();
            break;
          case WifiConnectionState.failed:
            content = _buildEnableFailedContent();
            break;
        }
        return content;
      }(),
    );
  }

  Widget _buildLoadingContent(String label) {
    return buildHotspotContent(label: label, color: FlixColor.orange);
  }

  Widget _buildWifiDisabledContent() {
    return buildHotspotContent(
        label: "WiFi未开启",
        color: FlixColor.red,
        action: "开启",
        onTap: () async {
          await WiFiForIoTPlugin.setEnabled(true, shouldOpenSettings: true);
          await Future.delayed(const Duration(seconds: 1));
          await _initWifi(false);
          if (_state == WifiConnectionState.wifiDisabled) {
            await Future.delayed(const Duration(seconds: 1));
            await _initWifi(false);
          }
        });
  }

  Widget _buildConnectedContent() {
    return buildHotspotContent(
        label: "热点连接成功",
        color: FlixColor.blue,
        action: "返回传输",
        onTap: () {
          Navigator.pop(context);
        },
        child: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: buildApInfoWidget(context, widget.apSSID, widget.apKey),
        ));
  }

  Widget _buildEnableFailedContent() {
    return buildHotspotContent(
        label: "热点连接失败",
        color: FlixColor.red,
        action: "重试",
        onTap: () {
          _initWifi(false);
        });
  }

  @override
  void onLifecycleChanged(AppLifecycleState state) {
    if (AppLifecycleState.resumed == state) {
      _initWifi(true);
    }
  }
}

enum WifiConnectionState { init, wifiDisabled, connecting, connected, failed }
