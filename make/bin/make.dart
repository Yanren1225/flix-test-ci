// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:async';
import 'package:archive/archive_io.dart';
import 'package:args/args.dart';

final basePath = Directory.current.path;

const versionName = '1.0.0';

void main(List<String> args) {
  final allowPlatforms = ['windows'];

  final argParser = ArgParser()
    ..addFlag('help', abbr: 'h', help: '显示帮助', negatable: false)
    ..addOption('version', abbr: 'v', help: '设置构建版本号（version name）');

  final argResult = argParser.parse(args);

  if (argResult['help']) {
    printUsage(argParser, allowPlatforms);
    return;
  }

  /// 没有指定平台
  if (argResult.rest.isEmpty) {
    print("没有指定平台");
    printUsage(argParser, allowPlatforms);
  }

  final platform = argResult.rest.first;

  if (!allowPlatforms.contains(platform)) {
    print("不支持的平台: $platform");
    printUsage(argParser, allowPlatforms);
    return;
  }

  final version = argResult['version'] ?? versionName;

  switch (platform) {
    case 'windows':
      buildWindows(version);
      break;
    default:
      print("不支持的平台: $platform");
      printUsage(argParser, allowPlatforms);
      break;
  }
}

void printUsage(ArgParser parser, List<String> allowedCommands) {
  print('用法: dart run make <平台> [选项]');
  print('可用的平台:');
  for (var command in allowedCommands) {
    print('  $command');
  }
  print(parser.usage);
}

void buildWindows(String? version) async {
  print("build windows");

  await runCommand('flutter', ['pub', 'get']);

  await runCommand('flutter', ['build', 'windows']);

  /// 复制 release 产物并命名为 flix
  final flixDir = '$basePath\\build\\windows\\x64\\Runner\\flix\\';
  final releaseDir = '$basePath\\build\\windows\\x64\\Runner\\Release';

  if (await Directory(flixDir).exists()) {
    await Directory(flixDir).delete(recursive: true);
  }

  await Directory(flixDir).create(recursive: true);
  await copyDirectory(Directory(releaseDir), Directory(flixDir));

  /// 复制 dll
  await copyDirectory(Directory('$basePath\\make\\dll'), Directory(flixDir));

  /// 压缩 flix_win
  final zipFilePath = '$basePath\\scripts\\Installer\\flix';
  final zipFile = File('$zipFilePath.zip');

  if (await zipFile.exists()) {
    await zipFile.delete();
  }

  final encoder = ZipFileEncoder();
  encoder.create('$zipFilePath.zip');
  encoder.addDirectory(Directory(flixDir), includeDirName: false);
  encoder.close();

  /// 拷贝 flix_win 到
  final portableParentDir = '$basePath\\scripts\\Installer\\portable';
  final portableDir = '$portableParentDir\\flix';
  copyDirectory(Directory(flixDir), Directory(portableDir));

  /// 执行 dotnet publish 命令
  final outputDir = '$basePath\\scripts\\Installer\\publish\\${version}';
  await Directory(outputDir).create(recursive: true);
  await runCommand('dotnet', [
    'publish',
    '$basePath\\scripts\\Installer',
    '-r',
    'win-x64',
    '--self-contained',
    'true',
    '-p:PublishSingleFile=true',
    '-p:IncludeNativeLibrariesForSelfExtract=true',
    '-p:PublishTrimmed=true',
    '-o',
    outputDir
  ]);
}

Future<bool> runCommand(String command, List<String> arguments) async {
  final process = await Process.start(command, arguments, runInShell: true);
  await stdout.addStream(process.stdout);
  await stderr.addStream(process.stderr);
  final exitCode = await process.exitCode;
  if (exitCode != 0) {
    throw ProcessException(
        command, arguments, 'Non-zero exit code: $exitCode', exitCode);
  }
  return process.exitCode == 0;
}

Future<void> copyDirectory(Directory source, Directory destination) async {
  if (!await destination.exists()) {
    await destination.create(recursive: true);
  }

  await for (var entity in source.list(recursive: false, followLinks: false)) {
    if (entity is Directory) {
      await copyDirectory(
          entity, Directory('${destination.path}\\${entity.path.split('\\').last}'));
    } else if (entity is File) {
      await entity.copy('${destination.path}\\${entity.path.split('\\').last}'.replaceAll('\\\\', '\\'));
    }
  }
}
