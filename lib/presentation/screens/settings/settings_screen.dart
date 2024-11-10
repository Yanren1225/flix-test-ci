import 'dart:async';
import 'dart:io';

import 'package:flix/domain/version/version_checker.dart';
import 'package:flix/presentation/screens/account/vip.dart';
import 'package:flix/presentation/screens/cloud/home.dart';
import 'package:flix/presentation/screens/intro/intro_agreement.dart';
import 'package:flix/presentation/screens/intro/intro_privacy.dart';
import 'package:flix/presentation/style/colors/flix_color.dart';
import 'package:flix/presentation/widgets/helps/flix_share_bottom_sheet.dart';
import 'package:flix/presentation/widgets/helps/qa.dart';
import 'package:flix/presentation/widgets/flix_toast.dart';
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
import 'package:flix/utils/exit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../../../l10n/l10n.dart';
import 'dev/client_info_page.dart';
import 'dev/dev_config.dart';
import '../../dialog/confirm_exit_app_bottomsheet.dart';
import '../../widgets/settings/click_action_item.dart';
import 'dev/dev_new_locale.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback crossDeviceCallback;
  final VoidCallback showConnectionInfoCallback;
  final VoidCallback goManualAddCallback;
  final VoidCallback goDonateCallback;
  final VoidCallback goQACallback;
  final VoidCallback goVersionScreen;
  final VoidCallback goGeneralCallback;
  final VoidCallback goSettingFunctionCallback;
  final VoidCallback goAutomaticReceiveCallback;
  final VoidCallback goSettingPravicyScreen;
  final VoidCallback goSettingAgreementScreen;
  final VoidCallback goLoginPage;
  final VoidCallback goCloudScreenPage;
  final VoidCallback goPayScreen;
  final VoidCallback goHotkeyScreen;

  const SettingsScreen({
    super.key,
    required this.crossDeviceCallback,
    required this.showConnectionInfoCallback,
    required this.goManualAddCallback,
    required this.goDonateCallback,
    required this.goQACallback,
    required this.goVersionScreen,
    required this.goGeneralCallback,
    required this.goSettingFunctionCallback,
    required this.goAutomaticReceiveCallback,
    required this.goSettingPravicyScreen,
    required this.goSettingAgreementScreen,
    required this.goLoginPage,
    required this.goCloudScreenPage,
    required this.goPayScreen,
    required this.goHotkeyScreen,
  });

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
  ValueNotifier<String> version = ValueNotifier('');
  String _title = '注册/登录 >';
  String? _loggedInEmail;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
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
      PackageInfo.fromPlatform().then((packageInfo) {
        version.value = packageInfo.version;
      });
    }
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _loggedInEmail = prefs.getString('loggedInEmail');
      if (_loggedInEmail != null) {
        _title = '我的账户 >';
      }
    });
  }

  @override
  void dispose() {
    deviceNameSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool showAutoSaveMedia = Platform.isAndroid;
    final bool showCustomSaveDir = !Platform.isIOS;
    final bool showAppLaunchConfig = isDesktop();
    final bool showHotkey = isDesktop();

    return CupertinoNavigationScaffold(
      title: S.of(context).setting_title,
      isSliverChild: true,
      padding: 16,
      enableRefresh: false,
      child: SliverList.builder(
        itemCount: 1,
        itemBuilder: (context, index) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //  Padding(
            //    padding: const EdgeInsets.only(left: 16, right: 16，bottom:10),
            ///  child: GestureDetector(
            //    onTap:  widget.goLoginPage,
            //    child: Text(
            //    _title,
            //      style: TextStyle(
            //        fontSize: 13.5,
            //         color: Theme.of(context).flixColors.text.secondary,
            //       ),
            //        textAlign: TextAlign.left,
            //      ),
            //    ),
            //  ),

            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 10),
              child: ClickableItem(
                  topRadius: true,
                  // bottomRadius: !showAppLaunchConfig,
                  bottomRadius: false,
                  label: S.of(context).setting_device_name,
                  des: deviceName,
                  iconPath: 'assets/images/device_name.svg',
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

            Container(
              color: Theme.of(context).flixColors.background.primary,
              margin: const EdgeInsets.only(left: 16, right: 16),
              child: Container(
                height: 0.5,
                color:
                    Theme.of(context).flixColors.text.tertiary.withOpacity(0.1),
                margin: const EdgeInsets.only(left: 16),
              ),
            ),

            Visibility(
              visible: showCustomSaveDir,
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: StreamBuilder<String>(
                  initialData: SettingsRepo.instance.savedDir,
                  stream: SettingsRepo.instance.savedDirStream.stream,
                  builder: (context, snapshot) {
                    return ClickableItem(
                        label: S.of(context).setting_receive_folder,
                        iconPath: 'assets/images/where_save.svg',
                        des: snapshot.data,
                        topRadius: false,
                        //bottomRadius: !showAutoSaveMedia,
                        bottomRadius: false,
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

            Visibility(
              visible: showCustomSaveDir,
              child: Container(
                color: Theme.of(context).flixColors.background.primary,
                margin: const EdgeInsets.only(left: 16, right: 16),
                child: Container(
                  height: 0.5,
                  color: Theme.of(context)
                      .flixColors
                      .text
                      .tertiary
                      .withOpacity(0.1),
                  margin: const EdgeInsets.only(left: 16),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(left: 16, top: 0, right: 16),
              child: ValueListenableBuilder<String>(
                valueListenable: version,
                builder: (BuildContext context, String value, Widget? child) {
                  return ClickableItem(
                      label: '自动接收',
                      iconPath: 'assets/images/automaticreceive.svg',
                      bottomRadius: true,
                      topRadius: false,
                      onClick: widget.goAutomaticReceiveCallback);
                },
              ),
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
                visible: false,
                child: Column(children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 20, top: 20, right: 20),
                    child: Text(
                      S.of(context).setting_accessibility,
                      style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                              color:
                                  Theme.of(context).flixColors.text.secondary)
                          .fix(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16, top: 4, right: 16),
                    child: StreamBuilder<bool>(
                      initialData: SettingsRepo.instance.autoReceive,
                      stream: SettingsRepo.instance.autoReceiveStream.stream,
                      builder:
                          (BuildContext context, AsyncSnapshot<bool> snapshot) {
                        return ClickableItem(
                          label: S.of(context).setting_accessibility_add_self,
                          des: S.of(context).setting_accessibility_add_self_des,
                          topRadius: true,
                          bottomRadius: true,
                          onClick: () {
                            widget.showConnectionInfoCallback();
                          },
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16),
                    child: StreamBuilder<bool>(
                      initialData: SettingsRepo.instance.autoReceive,
                      stream: SettingsRepo.instance.autoReceiveStream.stream,
                      builder:
                          (BuildContext context, AsyncSnapshot<bool> snapshot) {
                        return ClickableItem(
                          label:
                              S.of(context).setting_accessibility_add_devices,
                          des: S
                              .of(context)
                              .setting_accessibility_add_devices_des,
                          topRadius: false,
                          bottomRadius: true,
                          onClick: () {
                            widget.goManualAddCallback();
                          },
                        );
                      },
                    ),
                  ),
                ])),

            // 高度1pt的分割线

            // 高度1pt的分割线

            //   Visibility(
            //    visible: showAutoSaveMedia,
            //    child: Container(
            //      margin: const EdgeInsets.only(left: 14),
            //      height: 0.5,
            //      color: const Color.fromRGBO(0, 0, 0, 0.08),
            //    ),
            //  ),

            Padding(
              padding: const EdgeInsets.only(left: 16, top: 16, right: 16),
              child: ValueListenableBuilder<String>(
                valueListenable: version,
                builder: (BuildContext context, String value, Widget? child) {
                  return ClickableItem(
                      label: '通用',
                      iconPath: 'assets/images/general.svg',
                      bottomRadius: false,
                      onClick: widget.goGeneralCallback);
                },
              ),
            ),

            Container(
              color: Theme.of(context).flixColors.background.primary,
              margin: const EdgeInsets.only(left: 16, right: 16),
              child: Container(
                height: 0.5,
                color:
                    Theme.of(context).flixColors.text.tertiary.withOpacity(0.1),
                margin: const EdgeInsets.only(left: 16),
              ),
            ),

            Visibility(
              visible: showHotkey,
              child: Padding(
                padding: const EdgeInsets.only(left: 16, top: 0, right: 16),
                child: ValueListenableBuilder<String>(
                  valueListenable: version,
                  builder: (BuildContext context, String value, Widget? child) {
                    return ClickableItem(
                        label: '快捷键',
                        iconPath: 'assets/images/hotkey.svg',
                        topRadius: false,
                        bottomRadius: false,
                        onClick: widget.goHotkeyScreen);
                  },
                ),
              ),
            ),

            Visibility(
              visible: showHotkey,
              child: Container(
                color: Theme.of(context).flixColors.background.primary,
                margin: const EdgeInsets.only(left: 16, right: 16),
                child: Container(
                  height: 0.5,
                  color: Theme.of(context)
                      .flixColors
                      .text
                      .tertiary
                      .withOpacity(0.1),
                  margin: const EdgeInsets.only(left: 16),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(left: 16, top: 0, right: 16),
              child: ValueListenableBuilder<String>(
                valueListenable: version,
                builder: (BuildContext context, String value, Widget? child) {
                  return ClickableItem(
                      label: '扩展功能',
                      iconPath: 'assets/images/function.svg',
                      topRadius: false,
                      bottomRadius: true,
                      onClick: widget.goSettingFunctionCallback);
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(left: 16, top: 16, right: 16),
              child: ValueListenableBuilder<String>(
                valueListenable: version,
                builder: (BuildContext context, String value, Widget? child) {
                  return ClickableItem(
                      label: '帮助',
                      iconPath: 'assets/images/qa.svg',
                      bottomRadius: false,
                      onClick: widget.goQACallback);
                },
              ),
            ),

            Container(
              color: Theme.of(context).flixColors.background.primary,
              margin: const EdgeInsets.only(left: 16, right: 16),
              child: Container(
                height: 0.5,
                color:
                    Theme.of(context).flixColors.text.tertiary.withOpacity(0.1),
                margin: const EdgeInsets.only(left: 16),
              ),
            ),

            Visibility(
              visible: !Platform.isIOS,
              child: Padding(
                padding: const EdgeInsets.only(left: 16, top: 0, right: 16),
                child: ValueListenableBuilder<String>(
                  valueListenable: version,
                  builder: (BuildContext context, String value, Widget? child) {
                    return ClickableItem(
                        label: S.of(context).help_donate,
                        iconPath: 'assets/images/donate.svg',
                        bottomRadius: false,
                        topRadius: false,
                        onClick: widget.goDonateCallback);
                  },
                ),
              ),
            ),

            Visibility(
              visible: !Platform.isIOS,
              child: Container(
                color: Theme.of(context).flixColors.background.primary,
                margin: const EdgeInsets.only(left: 16, right: 16),
                child: Container(
                  height: 0.5,
                  color: Theme.of(context)
                      .flixColors
                      .text
                      .tertiary
                      .withOpacity(0.1),
                  margin: const EdgeInsets.only(left: 16),
                ),
              ),
            ),

            Padding(
                padding: const EdgeInsets.only(
                    left: 16, right: 16, bottom: 16, top: 0),
                child: ClickableItem(
                    label: S.of(context).help_recommend,
                    topRadius: Platform.isIOS,
                    iconPath: 'assets/images/suggest.svg',
                    onClick: () {
                      showCupertinoModalPopup(
                          context: context,
                          builder: (BuildContext context) =>
                              FlixShareBottomSheet(context));
                    })),

            Padding(
              padding: const EdgeInsets.only(left: 16, top: 0, right: 16),
              child: ValueListenableBuilder<String>(
                valueListenable: version,
                builder: (BuildContext context, String value, Widget? child) {
                  return ClickableItem(
                    label: S.of(context).help_about,
                    //tail: 'v$value',
                    onClick: widget.goVersionScreen,
                    iconPath: 'assets/images/about_us.svg',
                    bottomRadius: Platform.isIOS,
                  );
                },
              ),
            ),

            Container(
              color: Theme.of(context).flixColors.background.primary,
              margin: const EdgeInsets.only(left: 16, right: 16),
              child: Container(
                height: 0.5,
                color:
                    Theme.of(context).flixColors.text.tertiary.withOpacity(0.1),
                margin: const EdgeInsets.only(left: 16),
              ),
            ),

            StreamBuilder<String?>(
              initialData: VersionChecker.newestVersion,
              stream: VersionChecker.newestVersionStream.stream,
              builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
                final tail = snapshot.data?.isNotEmpty == true
                    ? S.of(context).help_new_version(snapshot.requireData ?? '')
                    : S.of(context).help_latest_version;
                return Visibility(
                  visible: !Platform.isIOS,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16),
                    child: ClickableItem(
                      label: S.of(context).help_check_update,
                      iconPath: 'assets/images/check_update.svg',
                      tail: tail,
                      tailColor: snapshot.data?.isNotEmpty == true
                          ? FlixColor.blue
                          : Theme.of(context).flixColors.text.secondary,
                      onClick: () {
                        VersionChecker.checkNewVersion(context,
                            ignorePromptCount: true);
                      },
                      topRadius: false,
                    ),
                  ),
                );
              },
            ),

            Visibility(
              visible: DevConfig.instance.current,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 16, top: 16, right: 16),
                    child: ClickableItem(
                        label: '日志',
                        bottomRadius: false,
                        onClick: () {
                          Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) =>
                                    TalkerScreen(talker: talker),
                              ));
                        }),
                  ),
                  Container(
                    color: Theme.of(context).flixColors.background.primary,
                    margin: const EdgeInsets.only(left: 16, right: 16),
                    child: Container(
                      height: 0.5,
                      color: Theme.of(context)
                          .flixColors
                          .text
                          .tertiary
                          .withOpacity(0.1),
                      margin: const EdgeInsets.only(left: 16),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 16, right: 16, bottom: 0),
                    child: ClickableItem(
                        label: '语言',
                        tail: Localizations.localeOf(context).toString(),
                        topRadius: false,
                        bottomRadius: false,
                        onClick: () {
                          showCupertinoModalPopup(
                              context: context,
                              builder: (context) {
                                return const DevNewLocaleBottomSheet();
                              });
                        }),
                  ),
                  Padding(
                    padding:
                    const EdgeInsets.only(left: 16, right: 16, bottom: 0),
                    child: ClickableItem(
                        label: '客户端信息',
                        topRadius: false,
                        bottomRadius: false,
                        onClick: () {
                          Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) =>
                                    const ClientInfoPage(),
                              ));
                        }),
                  ),
                  Container(
                    color: Theme.of(context).flixColors.background.primary,
                    margin: const EdgeInsets.only(left: 16, right: 16),
                    child: Container(
                      height: 0.5,
                      color: Theme.of(context)
                          .flixColors
                          .text
                          .tertiary
                          .withOpacity(0.1),
                      margin: const EdgeInsets.only(left: 16),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                    ),
                    child: ClickableItem(
                        label: '账号系统',
                        topRadius: false,
                        bottomRadius: false,
                        onClick: widget.goLoginPage),
                  ),
                  Container(
                    color: Theme.of(context).flixColors.background.primary,
                    margin: const EdgeInsets.only(left: 16, right: 16),
                    child: Container(
                      height: 0.5,
                      color: Theme.of(context)
                          .flixColors
                          .text
                          .tertiary
                          .withOpacity(0.1),
                      margin: const EdgeInsets.only(left: 16),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16),
                    child: ClickableItem(
                        label: '云同步',
                        topRadius: false,
                        onClick: widget.goCloudScreenPage),
                  ),
                ],
              ),
            ),

            Visibility(
              visible: showExit(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 16, top: 20, right: 16, bottom: 22),
                    child: ClickActionItem(
                        label: S.of(context).setting_exit,
                        dangerous: true,
                        onClick: () {
                          doExit();
                          /*
                          showCupertinoDialog(
                              context: context,
                              builder: (context) =>
                                  const ConfirmExitAppBottomSheet());

                           */
                        }),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(
                  left: 10, top: 0, right: 16, bottom: 36),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: widget.goSettingAgreementScreen,
                      child: Text(
                        '用户协议',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).flixColors.text.secondary,
                        ),
                      ),
                    ),
                    Text(
                      '  |  ',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).flixColors.text.secondary,
                      ),
                    ),
                    GestureDetector(
                      onTap: widget.goSettingPravicyScreen,
                      child: Text(
                        '隐私政策',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).flixColors.text.secondary,
                        ),
                      ),
                    ),
                  ],
                ),
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

  String trimMultilineString(String input) {
    // 分割成行
    List<String> lines = input.split('\n');

    // 移除前后空白行
    while (lines.isNotEmpty && lines.first.trim().isEmpty) {
      lines.removeAt(0);
    }
    while (lines.isNotEmpty && lines.last.trim().isEmpty) {
      lines.removeLast();
    }

    if (lines.isEmpty) {
      return '';
    }

    // 找到最小的缩进量
    int minIndent = lines
        .where((line) => line.trim().isNotEmpty)
        .map((line) => line.indexOf(RegExp(r'\S')))
        .reduce((min, indent) => indent < min ? indent : min);

    // 去除每行的缩进
    String trimmedString = lines
        .map((line) =>
            line.length > minIndent ? line.substring(minIndent) : line)
        .join('\n');

    return trimmedString;
  }
}
