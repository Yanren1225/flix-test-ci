import 'package:drift/drift.dart';
import 'package:flix/domain/database/database.dart';
import 'package:flix/model/database/device/persistence_devices.dart';
import 'package:flix/network/protocol/device_modal.dart';

part 'devices_dao.g.dart';

@DriftAccessor(tables: [PersistenceDevices])
class DevicesDao extends DatabaseAccessor<AppDatabase> with _$DevicesDaoMixin {
  DevicesDao(super.db);

  Future<void> insertDevice(DeviceModal deviceModal) async {
    await into(persistenceDevices).insertOnConflictUpdate(PersistenceDevicesCompanion.insert(
        alias: deviceModal.alias,
        deviceModel: Value(deviceModal.deviceModel),
        deviceType: Value(deviceModal.deviceType?.index),
        fingerprint: deviceModal.fingerprint,
        port: Value(deviceModal.port),
        ip: Value(deviceModal.ip),
        insertOrUpdateTime: Value(DateTime.now())));
  }


  Stream<List<DeviceModal>> watchDevices() {
    // 按插入时间倒排
    return (select(persistenceDevices)..orderBy([(t) {
      return OrderingTerm(expression: t.insertOrUpdateTime, mode: OrderingMode.desc);
    }
    ])).watch().map((event) =>
        event.map((e) =>
            DeviceModal(
                alias: e.alias,
                deviceModel: e.deviceModel,
                deviceType: DeviceType.values[e.deviceType ?? 0],
                fingerprint: e.fingerprint,
                port: e.port,
                ip: e.ip ?? ""
            )).toList());
  }

}