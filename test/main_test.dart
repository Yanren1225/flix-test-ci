// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:io';

import 'package:flix/domain/settings/settings_repo.dart';
import 'package:flix/utils/file/file_helper.dart';
import 'package:flix/utils/file/file_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flix/main.dart';

void main() {
  // testWidgets('Counter increments smoke test', (WidgetTester tester) async {
  //   // Build our app and trigger a frame.
  //   await tester.pumpWidget(const MyApp());
  //
  //   // Verify that our counter starts at 0.
  //   expect(find.text('0'), findsOneWidget);
  //   expect(find.text('1'), findsNothing);
  //
  //   // Tap the '+' icon and trigger a frame.
  //   await tester.tap(find.byIcon(Icons.add));
  //   await tester.pump();
  //
  //   // Verify that our counter has incremented.
  //   expect(find.text('0'), findsNothing);
  //   expect(find.text('1'), findsOneWidget);
  // });
  //
  print("test_temp_file");
  test("test_temp_file", () async {
    String dir = File("test/resource").path;
    String actualPath = (await FileUtils.getOrCreateTempWithFolder(dir, "test_file_helper.txt")).path;
    String expectPath =
        "$dir${Platform.pathSeparator}test_file_helper.txt${FileUtils.tempName}";
    print("actualPath = $actualPath");
    print("expectPath = $expectPath");
    expect(actualPath, expectPath);
  });
  print("test_target_file");
  test("test_target_file", () async {
    String dir = File("test/resource").path;
    String actualPath =
        (await FileUtils.getTargetFile(dir, "test_file_helper.txt")).path;
    String expectPath = "$dir${Platform.pathSeparator}test_file_helper(1).txt";
    print("actualPath = $actualPath");
    print("expectPath = $expectPath");
    expect(actualPath, expectPath);
  });

  print("test_rename");
  test("test_rename", () async {
    String dir = File("test/resource").path;
    String actualPath =
        (await FileUtils.getTargetFile(dir, "test_file_helper.txt")).path;
    String expectPath = "$dir${Platform.pathSeparator}test_file_helper(1).txt";
    print("actualPath = $actualPath");
    print("expectPath = $expectPath");
    expect(actualPath, expectPath);
    File(actualPath).writeAsString("text helper 1");
    actualPath =
        (await FileUtils.getTargetFile(dir, "test_file_helper.txt")).path;
    expectPath = "$dir${Platform.pathSeparator}test_file_helper(2).txt";
    print("actualPath1 = $actualPath");
    print("expectPath1 = $expectPath");
    expect(actualPath, expectPath);
  });

  print("test_target_file_with_foler");
  test('test_target_file_with_foler', () async {
    String dir = File("test/resource/haha").path;
    String actualPath =
    (await FileUtils.getTargetFile(dir, "test_file_helper.txt")).path;
    String expectPath = "$dir${Platform.pathSeparator}test_file_helper.txt";
    print("actualPath = $actualPath");
    print("expectPath = $expectPath");
    expect(actualPath, expectPath);
    await File(actualPath).writeAsString("text helper 1");
    actualPath =
    (await FileUtils.getTargetFile(dir, "test_file_helper.txt")).path;
    expectPath = "$dir${Platform.pathSeparator}test_file_helper(1).txt";
    print("actualPath1 = $actualPath");
    print("expectPath1 = $expectPath");
    expect(actualPath, expectPath);
  });

  tearDownAll((){
    print("tearDownAll");
    String testGenerateFolder = File("test/resource/haha").path;
    File(testGenerateFolder).delete(recursive: true);
    testGenerateFolder = File("test/resource").path;
    String testGenerateFile = "$testGenerateFolder${Platform.pathSeparator}test_file_helper(1).txt";
    File(testGenerateFile).delete(recursive: true);
  });

}
