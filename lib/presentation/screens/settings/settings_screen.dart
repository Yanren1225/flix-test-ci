import 'dart:async';
import 'dart:io';

import 'package:flix/presentation/widgets/settings/option_item.dart';
import 'package:flix/theme/theme_extensions.dart';
import 'package:flix/utils/drawin_file_security_extension.dart';
import 'package:flix/utils/text/text_extension.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flix/domain/device/device_profile_repo.dart';
import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/domain/settings/settings_repo.dart';
import 'package:flix/presentation/screens/base_screen.dart';
import 'package:flix/presentation/screens/settings/confirm_clean_cache_bottom_sheet.dart';
import 'package:flix/presentation/widgets/device_name/name_edit_bottom_sheet.dart';
import 'package:flix/presentation/widgets/segements/cupertino_navigation_scaffold.dart';
import 'package:flix/presentation/widgets/settings/clickable_item.dart';
import 'package:flix/presentation/widgets/settings/settings_item_wrapper.dart';
import 'package:flix/presentation/widgets/settings/switchable_item.dart';
import 'package:flix/utils/file/file_helper.dart';
import 'package:flix/utils/platform_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:talker_flutter/talker_flutter.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback crossDeviceCallback;

  const SettingsScreen({super.key, required this.crossDeviceCallback});

  @override
  State<StatefulWidget> createState() {
    return SettingsScreenState();
  }
}

class SettingsScreenState extends State<SettingsScreen> {
  var isAutoSave = false;
  var deviceName = DeviceProfileRepo.instance.deviceName;
  StreamSubscription<String>? deviceNameSubscription;
  var isStartUpEnabled = false;

  @override
  void initState() {
    super.initState();
    deviceNameSubscription =
        DeviceProfileRepo.instance.deviceNameBroadcast.stream.listen((event) {
      setState(() {
        deviceName = event;
      });
    });

    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      launchAtStartup.isEnabled().then((value) {
        setState(() {
          isStartUpEnabled = value;
        });
      });
    }
  }

  @override
  void dispose() {
    deviceNameSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool showCustomSaveDir = !Platform.isIOS;
    final bool showAppLaunchConfig = isDesktop();

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
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: ClickableItem(
                  topRadius: true,
                  bottomRadius: !showAppLaunchConfig,
                  label: '本机名称',
                  des: deviceName,
                  onClick: () {
                    final theme = Theme.of(context);
                    print(theme.flixColors.text.primary);
                    showCupertinoModalPopup(
                        context: context,
                        builder: (context) {
                          final theme = Theme.of(context);
                          print(theme.flixColors.text.primary);
                          return const NameEditBottomSheet();
                        });
                  }),
            ),

            // 高度1pt的分割线
            // Visibility(
            //   visible: showAppLaunchConfig,
            //   child: Padding(
            //     padding: const EdgeInsets.only(left: 16, right: 16),
            //     child: SettingsItemWrapper(
            //       topRadius: false,
            //       bottomRadius: false,
            //       child: StreamBuilder<bool>(
            //         initialData: SettingsRepo.instance.isMinimized,
            //         stream: SettingsRepo.instance.isMinimizedStream.stream,
            //         builder:
            //             (BuildContext context, AsyncSnapshot<bool> snapshot) {
            //           return SwitchableItem(
            //             label: '关闭窗口后，保留在系统托盘区域',
            //             checked: snapshot.data ?? false,
            //             onChanged: (value) async {
            //               talker.debug("isMinimized value = $value");
            //               SettingsRepo.instance.setMinimizedMode(value!);
            //             },
            //           );
            //         },
            //       ),
            //     ),
            //   ),
            // ),

            // 高度1pt的分割线
            Visibility(
              visible: showAppLaunchConfig,
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: SettingsItemWrapper(
                  topRadius: false,
                  bottomRadius: true,
                  child: SwitchableItem(
                    label: '开机时自动启动',
                    // des: '软件会在后台静默启动，不会弹窗打扰',
                    checked: isStartUpEnabled,
                    onChanged: (value) async {
                      print("startup value = $value");
                      var success = false;
                      if (value == true) {
                        success = await launchAtStartup.enable();
                      } else {
                        success = await launchAtStartup.disable();
                      }
                      setState(() {
                        if (success) {
                          isStartUpEnabled = value!;
                        }
                      });
                    },
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(left: 20, top: 20, right: 20),
              child: Text(
                '进阶功能',
                style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                        color: Color.fromRGBO(60, 60, 67, 0.6))
                    .fix(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 4, right: 16),
              child: SettingsItemWrapper(
                topRadius: true,
                bottomRadius: true,
                child: StreamBuilder<bool>(
                  initialData: SettingsRepo.instance.autoReceive,
                  stream: SettingsRepo.instance.autoReceiveStream.stream,
                  builder:
                      (BuildContext context, AsyncSnapshot<bool> snapshot) {
                    return ClickableItem(
                      label: '跨设备复制粘贴',
                      des: '复制文字、图片后，可共享数据',
                      onClick: () {
                        widget.crossDeviceCallback();
                      },
                    );
                  },
                ),
              ),
            ),
            // 高度1pt的分割线
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 20, right: 20),
              child: Text(
                '接收设置',
                style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                        color: Theme.of(context).flixColors.text.secondary)
                    .fix(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 4, right: 16),
              child: SettingsItemWrapper(
                topRadius: true,
                bottomRadius: false,
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
                          if (!(await checkStoragePermission(context,
                              manageExternalStorage: true))) {
                            return;
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
                                  initialDirectory: Platform.isWindows
                                      ? null
                                      : initialDirectory,
                                  lockParentWindow: true);
                          if (newSavedPath != null) {
                            authPersistentAccess(newSavedPath);
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20, top: 20, right: 20),
                  child: Text(
                    '更多',
                    style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                            color: Theme.of(context).flixColors.text.secondary)
                        .fix(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 4, right: 16),
                  child: SettingsItemWrapper(
                    topRadius: true,
                    bottomRadius: false,
                    child: StreamBuilder<bool>(
                      initialData: SettingsRepo.instance.enableMdns,
                      stream: SettingsRepo.instance.enableMdnsStream.stream,
                      builder:
                          (BuildContext context, AsyncSnapshot<bool> snapshot) {
                        return SwitchableItem(
                          label: '启用新的设备发现方式',
                          des: '开启后可解决开热点后无法发现设备的问题。若遇到兼容问题，请尝试关闭此开关，并反馈给我们❤️',
                          checked: snapshot.data ?? false,
                          onChanged: (value) {
                            setState(() {
                              if (value != null) {
                                SettingsRepo.instance.setEnableMdns(value);
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
                ),
                StreamBuilder<String>(
                    stream: SettingsRepo.instance.darkModeTagStream.stream,
                    initialData: SettingsRepo.instance.darkModeTag,
                    builder: (context, snapshot) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 16, right: 16),
                        child: Builder(builder: (context) {
                          final options = [
                            const OptionData(
                                label: '跟随系统', tag: 'follow_system'),
                            const OptionData(label: '始终开启', tag: 'always_on'),
                            const OptionData(label: '始终关闭', tag: 'always_off')
                          ];

                          return OptionItem(
                              topRadius: false,
                              bottomRadius: false,
                              label: '深色模式',
                              tag: 'dark_mode',
                              options: options,
                              value: options.firstWhereOrNull(
                                      (e) => e.tag == snapshot.data) ??
                                  options[0],
                              onChanged: (value) {
                                SettingsRepo.instance.setDarkModeTag(value.tag);
                              });
                        }),
                      );
                    }),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                  child: ClickableItem(
                    label: '清除缓存',
                    topRadius: false,
                    bottomRadius: true,
                    onClick: () {
                      showConfirmDeleteCacheBottomSheet();
                    },
                  ),
                ),
              ],
            ),

            Visibility(
              visible: !kReleaseMode,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 20, top: 10, right: 20),
                    child: Text(
                      '开发者',
                      style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                              color:
                                  Theme.of(context).flixColors.text.secondary)
                          .fix(),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showConfirmDeleteCacheBottomSheet() {
    showCupertinoModalPopup(
        context: context,
        builder: (context) {
          return ConfirmCleanCacheBottomSheet(
            onConfirm: () async {
              // PaintingBinding.instance.imageCache?.clear();
              // PaintingBinding.instance.imageCache?.clearLiveImages();
              deleteCache();
            },
          );
        });
  }
}
