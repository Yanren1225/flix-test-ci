import 'package:drift/drift.dart';

class FileContents extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get mimeType => text()();
  TextColumn get nameWithSuffix => text()();
  IntColumn get size => integer()();
  TextColumn get path => text().nullable()();
  IntColumn get state => integer()();

  @override
  Set<Column> get primaryKey => {id};
}