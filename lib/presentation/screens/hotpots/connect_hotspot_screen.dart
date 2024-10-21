import 'dart:io';

import 'package:flix/domain/hotspot/direct_wifi_manager.dart';
import 'package:flix/domain/lifecycle/app_lifecycle.dart';
import 'package:flix/presentation/screens/hotpots/hotspot_screen.dart';
import 'package:flix/presentation/style/colors/flix_color.dart';
import 'package:flix/theme/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:wifi_iot/wifi_iot.dart';

import '../../../l10n/l10n.dart';

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
        switch (_state) {
          case WifiConnectionState.init:
            content = _buildLoadingContent(S.of(context).hotspot_wifi_initializing);
            break;
          case WifiConnectionState.wifiDisabled:
            content = _buildWifiDisabledContent();
            break;
          case WifiConnectionState.connecting:
            content = _buildLoadingContent(S.of(context).hotspot_connecting);
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
    return buildHotspotContent(
        context: context, label: label, color: FlixColor.orange);
  }

  Widget _buildWifiDisabledContent() {
    return buildHotspotContent(
        context: context,
        label: S.of(context).hotspot_wifi_disabled,
        color: FlixColor.red,
        action: S.of(context).hotspot_wifi_disabled_action,
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
        context: context,
        label: S.of(context).hotspot_connect_success,
        color: FlixColor.blue,
        action: S.of(context).hotspot_connect_success_action,
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
        context: context,
        label: S.of(context).hotspot_connect_failed,
        color: FlixColor.red,
        action: S.of(context).hotspot_connect_failed_action,
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
