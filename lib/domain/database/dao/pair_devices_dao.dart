import 'package:drift/drift.dart';
import 'package:flix/domain/database/database.dart';
import 'package:flix/model/database/device/pair_devices.dart';

part 'pair_devices_dao.g.dart';

@DriftAccessor(tables: [PairDevices])
class PairDevicesDao extends DatabaseAccessor<AppDatabase>
    with _$PairDevicesDaoMixin {
  PairDevicesDao(super.db);

  Future<bool> isPair(String deviceId) async {
    var pairDevice = await (select(pairDevices)
          ..where((tbl) => tbl.fingerprint.equals(deviceId)))
        .getSingleOrNull();
    return pairDevice != null;
  }

  Future<List<PairDevice>> getAll() async {
    return await select(pairDevices).get();
  }

  Future<int> insert(String fingerPrint, String code) async {
    return await into(pairDevices).insertOnConflictUpdate(
        PairDevicesCompanion.insert(fingerprint: fingerPrint, code: code));
  }

  Future<void> deletePairDevice(String deviceId) async {
    await (delete(pairDevices)
          ..where((tbl) => tbl.fingerprint.equals(deviceId)))
        .go();
  }

  Stream<List<PairDevice>> watchDevices() {
    // 按插入时间倒排
    return (select(pairDevices)
          ..orderBy([
            (t) {
              return OrderingTerm(
                  expression: t.insertOrUpdateTime, mode: OrderingMode.desc);
            }
          ]))
        .watch()
        .map((event) => event
            .map((e) => PairDevice(
                fingerprint: e.fingerprint,
                code: e.code,
                insertOrUpdateTime: e.insertOrUpdateTime))
            .toList());
  }
}
