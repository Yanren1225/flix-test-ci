import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flix/domain/device/device_manager.dart';
import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/domain/settings/SettingsRepo.dart';
import 'package:flix/presentation/screens/base_screen.dart';
import 'package:flix/presentation/widgets/device_name/name_edit_bottom_sheet.dart';
import 'package:flix/presentation/widgets/segements/cupertino_navigation_scaffold.dart';
import 'package:flix/presentation/widgets/settings/clickable_item.dart';
import 'package:flix/presentation/widgets/settings/settings_item_wrapper.dart';
import 'package:flix/presentation/widgets/settings/switchable_item.dart';
import 'package:flix/utils/file/file_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:talker_flutter/talker_flutter.dart';

class SettingsScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SettingsScreenState();
  }
}

class SettingsScreenState extends State<SettingsScreen> {
  var isAutoSave = false;
  var deviceName = DeviceManager.instance.deviceName;
  StreamSubscription<String>? deviceNameSubscription = null;

  @override
  void initState() {
    super.initState();
    deviceNameSubscription =
        DeviceManager.instance.deviceNameBroadcast.stream.listen((event) {
      setState(() {
        deviceName = event;
      });
    });
  }

  @override
  void dispose() {
    deviceNameSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool showCustomSaveDir = !Platform.isIOS;

    return CupertinoNavigationScaffold(
      title: '软件设置',
      isSliverChild: true,
      padding: 16,
      enableRefresh: false,
      child: SliverList.builder(
        itemCount: 1,
        itemBuilder: (context, index) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: ClickableItem(
                  label: '本机名称',
                  des: deviceName,
                  onClick: () {
                    showCupertinoModalPopup(
                        context: context,
                        builder: (context) {
                          return NameEditBottomSheet();
                        });
                  }),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 20, top: 20, right: 20),
              child: Text(
                '接收设置',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    color: Color.fromRGBO(60, 60, 67, 0.6)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 4, right: 16),
              child: SettingsItemWrapper(
                topRadius: true,
                bottomRadius: !showCustomSaveDir,
                child: StreamBuilder<bool>(
                  initialData: SettingsRepo.instance.autoReceive,
                  stream: SettingsRepo.instance.autoReceiveStream.stream,
                  builder:
                      (BuildContext context, AsyncSnapshot<bool> snapshot) {
                    return SwitchableItem(
                      label: '自动接收',
                      des: '收到的文件将自动保存',
                      checked: snapshot.data ?? false,
                      onChanged: (value) {
                        setState(() {
                          if (value != null) {
                            SettingsRepo.instance.setAutoReceive(value);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
            ),
            // 高度1pt的分割线
            Visibility(
              visible: showCustomSaveDir,
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: StreamBuilder<String>(
                  initialData: SettingsRepo.instance.savedDir,
                  stream: SettingsRepo.instance.savedDirStream.stream,
                  builder: (context, snapshot) {
                    return ClickableItem(
                        label: '文件接收目录',
                        des: snapshot.data,
                        topRadius: false,
                        bottomRadius: true,
                        onClick: () async {
                          if (Platform.isAndroid) {
                            DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
                            final androidInfo = await deviceInfoPlugin.androidInfo;
                            if (androidInfo.version.sdkInt >= 30) {
                              if (await Permission.manageExternalStorage.isDenied) {
                                await Permission.manageExternalStorage.request();
                                return;
                              }
                            } else {
                              if (!(await checkStoragePermission(context))) {
                                return;
                              }
                            }
                          }

                          final String initialDirectory;
                          if (snapshot.data != null &&
                              await File(snapshot.data!).exists()) {
                            initialDirectory = snapshot.data!;
                          } else {
                            initialDirectory =
                                await getDefaultDestinationDirectory();
                          }
                          final newSavedPath = await FilePicker.platform
                              .getDirectoryPath(
                                  initialDirectory: initialDirectory,
                                  lockParentWindow: true);
                          if (newSavedPath != null) {
                            // authPersistentAccess(newSavedPath);
                            SettingsRepo.instance.setSavedDir(newSavedPath);
                          }
                          // showCupertinoModalPopup(context: context, builder: (context) {
                          //   return NameEditBottomSheet();
                          // });
                        });
                  },
                ),
              ),
            ),
            Visibility(
              visible: !kReleaseMode,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 20, top: 10, right: 20),
                    child: Text(
                      '开发者',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                          color: Color.fromRGBO(60, 60, 67, 0.6)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 16, top: 4, right: 16, bottom: 16),
                    child: ClickableItem(
                        label: '日志',
                        onClick: () {
                          Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) =>
                                    TalkerScreen(talker: talker),
                              ));
                        }),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 16, top: 4, right: 16, bottom: 16),
                    child: InkWell(
                      onTap: () {
                        deleteAppFiles();
                      },
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                            color: Color.fromRGBO(255, 59, 48, 1),
                            borderRadius: BorderRadius.circular(14)),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: StreamBuilder<bool>(
                            initialData: SettingsRepo.instance.autoReceive,
                            stream:
                                SettingsRepo.instance.autoReceiveStream.stream,
                            builder: (BuildContext context,
                                AsyncSnapshot<bool> snapshot) {
                              return const SizedBox(
                                width: double.infinity,
                                child: const Text(
                                  textAlign: TextAlign.center,
                                  '删除所有数据',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
