import 'dart:io';

import 'package:bonsoir/bonsoir.dart';
import 'package:flix/domain/device/device_profile_repo.dart';
import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/network/multicast_api.dart';
import 'package:flix/network/multicast_impl.dart';
import 'package:flix/network/protocol/device_modal.dart';
import 'package:flix/utils/iterable_extension.dart';
import 'package:flutter/foundation.dart';
import 'package:mutex/mutex.dart';

// Windows反复启动mdns会crash
class BonjourImpl extends MultiCastApi {
  static const SERVICE_TYPE = "_flix-trans._tcp";

  bool isStart = false;
  bool isPing = false;
  BonsoirBroadcast? broadcast;
  BonsoirDiscovery? discovery;
  BonsoirService? _service;
  final m = Mutex();

  final DeviceProfileRepo deviceProfileRepo;

  BonjourImpl({required this.deviceProfileRepo});

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
            "alias": deviceModal.alias,
            "deviceModal": deviceModal.deviceModel ?? '',
            "deviceType": (deviceModal.deviceType ?? DeviceType.mobile).name,
            "fingerprint": deviceModal.fingerprint,
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

  @override
  Future<void> pong(int port, DeviceModal to) async {}

  @override
  Future<void> startScan(DeviceScanCallback deviceScanCallback) async {
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
        discovery?.eventStream?.listen((event) {
          // `eventStream` is not null as the discovery instance is "ready" !
          if (event.type == BonsoirDiscoveryEventType.discoveryServiceFound) {
            talker.debug('mDns Service found : ${event.service?.toJson()}');
            event.service!.resolve(discovery!
                .serviceResolver); // Should be called when the user wants to connect to this service.
          } else if (event.type ==
              BonsoirDiscoveryEventType.discoveryServiceResolved) {
            talker.debug('mDns Service resolved : ${event.service?.toJson()}');
            final remoteService = event.service as ResolvedBonsoirService;
            if (remoteService != null) {
              // final alias = remoteService.name;
              final ip = remoteService.host ?? '';
              final port = remoteService.port;
              final serviceAttributes = remoteService.attributes;
              if (serviceAttributes != null) {
                final alias = serviceAttributes['alias']!;
                final deviceType = serviceAttributes['deviceType']!;
                final deviceModel = serviceAttributes['deviceModal']!;
                final fingerprint = serviceAttributes['fingerprint']!;
                if (_isFromSelf(fingerprint)) {
                  return;
                }
                deviceScanCallback(
                    DeviceModal(
                        alias: alias,
                        deviceType: DeviceType.values
                            .find((element) => element.name == deviceType),
                        fingerprint: fingerprint,
                        port: port,
                        deviceModel: deviceModel,
                        ip: ip),
                    false);
              }
            }
          } else if (event.type ==
              BonsoirDiscoveryEventType.discoveryServiceLost) {
            talker.debug('mDns Service lost : ${event.service?.toJson()}');
          }
        }, onError: (e) {
          talker.error('mDns discover error: $e');
        });

// Start the discovery **after** listening to discovery events :
        await discovery?.start();

// ...

// Then if you want to stop the broadcast :
//     await broadcast?.stop();
      });
    } catch (e, stackTrace) {
      talker.error('mDns startScan failed', e, stackTrace);
    }
  }

  bool _isFromSelf(String fingerprint) {
    if (kDebugMode) return false;
    return fingerprint == DeviceProfileRepo.instance.did;
  }
}
