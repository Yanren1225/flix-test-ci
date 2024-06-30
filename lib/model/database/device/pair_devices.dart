import 'package:drift/drift.dart';

class PairDevices extends Table {
  TextColumn get fingerprint => text()();
  TextColumn get code => text()();
  DateTimeColumn get insertOrUpdateTime => dateTime().withDefault(currentDateAndTime)();
  @override
  Set<Column> get primaryKey => {fingerprint};
}
