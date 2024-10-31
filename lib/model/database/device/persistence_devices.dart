import 'package:drift/drift.dart';

class PersistenceDevices extends Table {
  TextColumn get alias => text()();
  TextColumn get deviceModel => text().nullable()();
  IntColumn get deviceType => integer().nullable()();
  TextColumn get fingerprint => text()();
  IntColumn get port => integer().nullable()();
  IntColumn get version => integer().nullable()();
  TextColumn get ip => text().nullable()();
  TextColumn get host => text().nullable()();
  TextColumn get from => text().nullable()();
  DateTimeColumn get insertOrUpdateTime => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {fingerprint};
}