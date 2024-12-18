import 'dart:convert';
import 'dart:io';

import 'package:bonsoir/bonsoir.dart';
import 'package:flix/domain/device/device_profile_repo.dart';
import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/domain/paircode/pair_router_handler.dart';
import 'package:flix/network/discover/discover_param.dart';
import 'package:flix/network/multicast_api.dart';
import 'package:flix/network/multicast_impl.dart';
import 'package:flix/network/protocol/device_modal.dart';
import 'package:flix/utils/iterable_extension.dart';
import 'package:flix/utils/net/net_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:mutex/mutex.dart';

// Windows反复启动mdns会crash
class BonjourHelper {
  static const SERVICE_TYPE = "_flix-trans._tcp";

  bool isStart = false;
  bool isPing = false;
  BonsoirBroadcast? broadcast;
  BonsoirDiscovery? discovery;
  BonsoirService? _service;
  final m = Mutex();

  final DeviceProfileRepo deviceProfileRepo;

  BonjourHelper({required this.deviceProfileRepo});

  Future<BonsoirService> makesureServiceInit(int port) async {
    final deviceModal = await deviceProfileRepo.getDeviceModal(port);

    // TODO: always return new BonsoirService, test it
    // if (_service == null || _service?.port != port || ) {
    _service = BonsoirService(
        name: deviceModal.alias,
        // Put your service name here.
        type: SERVICE_TYPE,
        // Put your service type here. Syntax : _ServiceType._TransportProtocolName. (see http://wiki.ros.org/zeroconf/Tutorials/Understanding%20Zeroconf%20Service%20Types).
        port: port,
        // Put your service port here.
        attributes: {
          "network": await getNetworkBase64(),
          "alias": deviceModal.alias,
          "deviceModal": deviceModal.deviceModel ?? '',
          "deviceType": (deviceModal.deviceType ?? DeviceType.mobile).name,
          "fingerprint": deviceModal.fingerprint,
          "version": (deviceModal.version ?? -1).toString()
        });
    // }

    return _service!;
  }

  @override
  Future<void> stop() async {
    if (!Platform.isWindows) {
      await forceStop();
    }
  }

  Future<void> forceStop() async {
    await m.protect(() async {
      try {
        if (isStart) {
          await discovery?.stop();
          isStart = false;
        }
      } catch (e, stackTrace) {
        talker.error('mDns stop failed', e, stackTrace);
      }
      try {
        if (isPing) {
          await broadcast?.stop();
          isPing = false;
        }
      } catch (e, stackTrace) {
        talker.error('mDns stop failed', e, stackTrace);
      }
    });
  }

  @override
  Future<void> ping(int port) async {
    try {
      await m.protect(() async {
        if (isPing) {
          if (Platform.isWindows) return;
          await broadcast?.stop();
          isPing = false;
        }
        isPing = true;
        // Let's create our service !

// And now we can broadcast it :
        broadcast = BonsoirBroadcast(service: await makesureServiceInit(port));
        await broadcast?.ready;
        await broadcast?.start();
      });
    } catch (e, stackTrace) {
      talker.error('mDns ping failed', e, stackTrace);
    }
  }

  Future<void> pong(int port, DeviceModal to) async {}

  Future<void> startScan(DiscoverParam param) async {
    try {
      await m.protect(() async {
        if (isStart) {
          if (Platform.isWindows) return;
          await discovery?.stop();
          isStart = false;
        }

        isStart = true;

// Once defined, we can start the discovery :
        discovery = BonsoirDiscovery(type: SERVICE_TYPE);
        await discovery?.ready;

// If you want to listen to the discovery :
        discovery?.eventStream?.listen((event) async {
          // `eventStream` is not null as the discovery instance is "ready" !
          if (event.type == BonsoirDiscoveryEventType.discoveryServiceFound) {
            talker.debug('mDns Service found : ${event.service?.toJson()}');
            event.service!.resolve(discovery!
                .serviceResolver); // Should be called when the user wants to connect to this service.
          } else if (event.type ==
              BonsoirDiscoveryEventType.discoveryServiceResolved) {
            talker.debug('mDns Service resolved : ${event.service?.toJson()}');
            final remoteService = event.service as ResolvedBonsoirService;
            // final alias = remoteService.name;
            final host = remoteService.host ?? '';
            final port = remoteService.port;
            final serviceAttributes = remoteService.attributes;
            final alias = serviceAttributes['alias'];
            final network = serviceAttributes['network'];
            final deviceType = serviceAttributes['deviceType'];
            final deviceModel = serviceAttributes['deviceModal'];
            final fingerprint = serviceAttributes['fingerprint'];
            final versionString = serviceAttributes['version'];

            if (network?.isNotEmpty == true) {
              PairInfo pairInfo = decodeBase64ToMultipleIpsAndPort(network!);
              for (var ip in pairInfo.ips) {
                param.onData?.call(ip, "bonjour");
              }
            }
          } else if (event.type ==
              BonsoirDiscoveryEventType.discoveryServiceLost) {
            talker.debug('mDns Service lost : ${event.service?.toJson()}');
          }
        }, onError: (e, s) {
          talker.error('mDns discover error: $e', s);
        });

        await discovery?.start();
      });
    } catch (e, stackTrace) {
      talker.error('mDns startScan failed', e, stackTrace);
    }
  }

  void callDeviceScanCallback(
      DeviceScanCallback deviceScanCallback,
      String alias,
      String deviceType,
      String fingerprint,
      int port,
      int version,
      String deviceModel,
      String host) {
    deviceScanCallback(
        DeviceModal(
            alias: alias,
            deviceType:
                DeviceType.values.find((element) => element.name == deviceType),
            fingerprint: fingerprint,
            port: port,
            version: version,
            deviceModel: deviceModel,
            host: host),
        false);
  }

  bool _isFromSelf(String fingerprint) {
    if (kDebugMode) return false;
    return fingerprint == DeviceProfileRepo.instance.did;
  }
}
