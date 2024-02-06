import 'package:drift/drift.dart';

class TextContents extends Table {
  TextColumn get id => text()();
  TextColumn get content => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class TextContent {
  final String id;
  final String content;

  TextContent({required this.id, required this.content});
}