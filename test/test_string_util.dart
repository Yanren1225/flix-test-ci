import 'package:flix/model/ui_bubble/shared_file.dart';
import 'package:flix/utils/string_util.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("test_string_util", () async {
    assert("hello.png".isImgName());
  });
}
