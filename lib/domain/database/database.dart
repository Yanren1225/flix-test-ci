import 'dart:async';
import 'dart:io';

import 'package:androp/domain/database/dao/bubbles_dao.dart';
import 'package:androp/model/database/bubble_entity.dart';
import 'package:androp/model/database/file_content.dart';
import 'package:androp/model/database/text_content.dart';
import 'package:drift/drift.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';
import 'package:drift/native.dart';

import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';



part 'database.g.dart'; // the generated code will be there


@DriftDatabase(tables: [BubbleEntities, TextContents, FileContents], daos: [BubblesDao])
class AppDatabase extends _$AppDatabase {

  AppDatabase(): super(_openConnection());

  @override
  int get schemaVersion => 1;

  static LazyDatabase _openConnection() {
    // the LazyDatabase util lets us find the right location for the file async.
    return LazyDatabase(() async {
      // put the database file, called db.sqlite here, into the documents folder
      // for your app.
      final file;
      if (Platform.isAndroid) {
        // TODO 方便测试，上线后修改
        file = File(p.join('/data/user/0/com.example.androp/databases', 'db.sqlite'));
      } else {
        final dbFolder = await getApplicationDocumentsDirectory();
        file = File(p.join(dbFolder.path, 'db.sqlite'));
      }


      // Also work around limitations on old Android versions
      if (Platform.isAndroid) {
        await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
      }

      // Make sqlite3 pick a more suitable location for temporary files - the
      // one from the system may be inaccessible due to sandboxing.
      final cachebase = (await getTemporaryDirectory()).path;
      // We can't access /tmp on Android, which sqlite3 would try by default.
      // Explicitly tell it about the correct temporary directory.
      sqlite3.tempDirectory = cachebase;

      return NativeDatabase.createInBackground(file);
    });
  }


}


AppDatabase appDatabase = AppDatabase();