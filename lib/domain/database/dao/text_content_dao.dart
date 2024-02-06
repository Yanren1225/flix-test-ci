

import 'package:androp/model/database/text_content.dart';

abstract class TextContentDao {
  // @Query('SELECT * FROM TextContent WHERE id IN (:ids)')
  // Future<List<TextContent>> getTextContentsByIds(List<String> ids);
  //
  // @Query('SELECT * FROM TextContent WHERE id = :id')
  // Future<TextContent?> getTextContentById(String id);
  //
  // @Insert(onConflict: OnConflictStrategy.replace)
  // Future<void> insert(TextContent content);
}