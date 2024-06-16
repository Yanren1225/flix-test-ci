import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flix/domain/device/device_discover.dart';
import 'package:flix/domain/device/device_manager.dart';
import 'package:flix/domain/device/device_profile_repo.dart';
import 'package:flix/domain/hotspot/direct_wifi_manager.dart';
import 'package:flix/domain/hotspot/hotspot_manager.dart';
import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/domain/ship_server/ship_service_proxy.dart';
import 'package:flix/model/wifi_or_ap_name.dart';
import 'package:flix/network/protocol/device_modal.dart';
import 'package:flix/utils/iterable_extension.dart';
import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:provider/provider.dart';

enum MultiState { idle, scanning, connect, failure }

class MultiCastClientProvider extends ChangeNotifier {
  Set<DeviceModal> get deviceList => DeviceManager.instance.deviceList;

  Set<DeviceModal> get history => DeviceManager.instance.history
      .where(
          (e) => deviceList.find((d) => d.fingerprint == e.fingerprint) == null)
      .toSet();
  StreamSubscription? connectivitySubscription;

  String? _selectedDeviceId = null;

  String? get selectedDeviceId => _selectedDeviceId;

  var deviceName = DeviceProfileRepo.instance.deviceName;

  StreamController<String> get deviceNameStream =>
      DeviceProfileRepo.instance.deviceNameBroadcast;

  final info = NetworkInfo();

  var wifiName = "";
  final StreamController<String> _wifiNameStreamController =
      StreamController<String>.broadcast();

  Stream<String> get wifiNameStream => _wifiNameStreamController.stream;

  String get apName => hotspotManager.hotspotInfo?.ssid ?? "";

  Stream<String?> get apNameStream =>
      hotspotManager.hotspotInfoStreamController.stream
          .map((event) => event?.ssid);

  WifiOrApName get wifiOrApName {
    if (apName?.isNotEmpty == true) {
      return WifiOrApName(isAp: true, name: apName);
    } else {
      return WifiOrApName(isAp: false, name: wifiName);
    }
  }

  Stream<WifiOrApName> get wifiOrApNameStream {
    return combineStreams([
      wifiNameStream.map((event) {
        if (apName == null || apName?.isEmpty == true) {
          return WifiOrApName(isAp: false, name: event);
        } else {
          return WifiOrApName(isAp: true, name: apName);
        }
      }),
      apNameStream.map((event) {
        if (event == null || event.isEmpty) {
          return WifiOrApName(isAp: false, name: wifiName);
        } else {
          return WifiOrApName(isAp: true, name: event);
        }
    })

    ]);
  }

  Stream<T> combineStreams<T>(List<Stream<T>> streams) async* {
    List<StreamSubscription<T>> subscriptions = [];

    final combinedStreamController = StreamController<T>();

    // Listen to each stream and add its events to the combined stream controller
    for (var stream in streams) {
      final subscription = stream.listen((event) {
        combinedStreamController.add(event);
      }, onError: (error) {
        combinedStreamController.addError(error);
      }, onDone: () {
        if (subscriptions.every((sub) => sub.isPaused)) {
          combinedStreamController.close();
        }
      });

      subscriptions.add(subscription);
    }

    // Yield each event from the combined stream controller
    await for (var event in combinedStreamController.stream) {
      yield event;
    }
  }

  var connectivityResult = ConnectivityResult.none;
  StreamController<ConnectivityResult> connectivityResultStream =
      StreamController<ConnectivityResult>.broadcast();

  static MultiCastClientProvider of(BuildContext context,
      {bool listen = false}) {
    return Provider.of<MultiCastClientProvider>(context, listen: listen);
  }

  MultiCastClientProvider() {
    DeviceManager.instance.addDeviceListChangeListener(_onDeviceListChanged);
    DeviceManager.instance.addHistoryChangeListener(_onHistoryListChanged);
    directWifiManager.hotspotInfoStreamController.stream.listen((event) {
      if (event != null) {
        _onConnectivityChanged([ConnectivityResult.p2pWifi]);
      }
    });
    connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((result) {
        _onConnectivityChanged(result);
    });
    DeviceProfileRepo.instance.deviceNameBroadcast.stream.listen((event) async {
      if (deviceName != event) {
        deviceName = event;
        DeviceDiscover.instance.ping(await shipService.getPort());
      }
    });
  }

  void _notifyConnectivityResult(List<ConnectivityResult> result) async {
    final name = await resetWifiName();
    // ConnectivityResult 互联网连接状态，direct wifi状态下返回none
    if (name?.isNotEmpty == true) {
      _setConnectivityResult(ConnectivityResult.wifi);
      return;
    }
    if (result.contains(ConnectivityResult.wifi) || result.contains(ConnectivityResult.p2pWifi)) {
      resetWifiName();
    }
    if (result.contains(ConnectivityResult.none)) {
      _setConnectivityResult(ConnectivityResult.none);
    } else if (result.contains(ConnectivityResult.wifi)) {
      _setConnectivityResult(ConnectivityResult.wifi);
    } else if (result.contains(ConnectivityResult.p2pWifi)) {
      _setConnectivityResult(ConnectivityResult.p2pWifi);
    } else {
      _setConnectivityResult(ConnectivityResult.other);
    }
  }

  Future<String?> resetWifiName() async {
    try {
      var name = await info.getWifiName() ?? "";
      talker.debug("wifi name: $name");
      if (Platform.isAndroid && name.isNotEmpty) {
        if (name[0] == "\"" && name[name.length - 1] == "\"") {
          name = name.substring(1, name.length - 1);
        }
      }
      _setWifiName(name);
      return name;
    } catch (e, s) {
      talker.error('getWifiName error', e, s);
      return null;
    }
  }

  void _onDeviceListChanged(Set<DeviceModal> deviceList) {
    notifyListeners();
  }

  void _onHistoryListChanged(Set<DeviceModal> history) {
    notifyListeners();
  }

  @override
  void dispose() {
    connectivitySubscription?.cancel();
    DeviceManager.instance.removeDeviceListChangeListener(_onDeviceListChanged);
    DeviceManager.instance.removeHistoryChangeListener(_onHistoryListChanged);
    super.dispose();
  }

  Future<void> startScan() async {
    DeviceDiscover.instance.startScan(await shipService.getPort());
  }

  void clearDevices() {
    DeviceManager.instance.clearDevices();
  }

  void setSelectedDeviceId(String id) {
    _selectedDeviceId = id;
    notifyListeners();
  }

  Future<void> deleteHistory(String deviceId) async {
    await DeviceManager.instance.deleteHistory(deviceId);
  }

  void _setWifiName(String? name) {
    if (name != null && name.isNotEmpty && wifiName != name) {
      wifiName = name;
      _wifiNameStreamController.add(name);
    }
  }

  void _setConnectivityResult(ConnectivityResult result) {
    if (connectivityResult != result) {
      connectivityResult = result;
      connectivityResultStream.add(result);
    }
  }

  void _onConnectivityChanged(List<ConnectivityResult> result) {
    talker.debug('connectivity changed: $result');
    _notifyConnectivityResult(result);
    shipService.isServerLiving().then((isServerLiving) async {
      talker.debug('isServerLiving: $isServerLiving');
      if (isServerLiving) {
        startScan();
      } else {
        if (await shipService.restartShipServer()) {
          startScan();
        } else {
          talker.error('restartShipServer failed');
        }
      }
    }).catchError((error, stackTrace) =>
        talker.error('isServerLiving error', error, stackTrace));
  }
}
