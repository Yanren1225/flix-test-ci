import 'dart:async';
import 'dart:io';

import 'package:flix/domain/version/version_checker.dart';
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
import 'package:talker_flutter/talker_flutter.dart';

import '../../../l10n/l10n.dart';
import '../../../utils/dev_config.dart';
import '../../dialog/confirm_exit_app_bottomsheet.dart';
import '../../widgets/settings/click_action_item.dart';
import 'dev_new_locale.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback crossDeviceCallback;
  final VoidCallback showConnectionInfoCallback;
  final VoidCallback goManualAddCallback;
  final VoidCallback goDonateCallback;

  const SettingsScreen(
      {super.key,
      required this.crossDeviceCallback,
      required this.showConnectionInfoCallback,
      required this.goManualAddCallback,
      required this.goDonateCallback});

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
    PackageInfo.fromPlatform().then((packageInfo) {
      version.value = packageInfo.version;
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
    final bool showAutoSaveMedia = Platform.isAndroid;
    final bool showCustomSaveDir = !Platform.isIOS;
    final bool showAppLaunchConfig = isDesktop();

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
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: ClickableItem(
                  topRadius: true,
                  bottomRadius: !showAppLaunchConfig,
                  label: S.of(context).setting_device_name,
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
                    label: S.of(context).setting_auto_start,
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
                          bottomRadius: false,
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

            Padding(
              padding: const EdgeInsets.only(left: 20, top: 20, right: 20),
              child: Text(
                S.of(context).setting_advances,
                style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                        color: Theme.of(context).flixColors.text.secondary)
                    .fix(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 4, right: 16),
              child: StreamBuilder<bool>(
                initialData: SettingsRepo.instance.autoReceive,
                stream: SettingsRepo.instance.autoReceiveStream.stream,
                builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                  return ClickableItem(
                    label: S.of(context).setting_cross_device_clipboard,
                    des: S.of(context).setting_cross_device_clipboard_des,
                    topRadius: true,
                    bottomRadius: true,
                    onClick: () {
                      widget.crossDeviceCallback();
                    },
                  );
                },
              ),
            ),
            // 高度1pt的分割线
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 20, right: 20),
              child: Text(
                S.of(context).setting_receive,
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
                      label: S.of(context).setting_receive_auto,
                      des: S.of(context).setting_receive_auto_des,
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
                        label: S.of(context).setting_receive_folder,
                        des: snapshot.data,
                        topRadius: false,
                        bottomRadius: !showAutoSaveMedia,
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
              visible: showAutoSaveMedia,
              child: Container(
                margin: const EdgeInsets.only(left: 14),
                height: 0.5,
                color: const Color.fromRGBO(0, 0, 0, 0.08),
              ),
            ),

            Visibility(
              visible: showAutoSaveMedia,
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: SettingsItemWrapper(
                  topRadius: false,
                  bottomRadius: true,
                  child: StreamBuilder<bool>(
                    initialData: SettingsRepo.instance.autoSaveToGallery,
                    stream:
                        SettingsRepo.instance.autoSaveToGalleryStream.stream,
                    builder: (context, snapshot) {
                      return SwitchableItem(
                        label: S.of(context).setting_receive_to_album,
                        des: S.of(context).setting_receive_to_album_des,
                        checked: snapshot.data ?? false,
                        onChanged: (value) {
                          setState(() {
                            if (value != null) {
                              SettingsRepo.instance.setAutoSaveToGallery(value);
                            }
                          });
                        },
                      );
                    },
                  ),
                ),
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20, top: 20, right: 20),
                  child: Text(
                    S.of(context).setting_more,
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
                          label: S.of(context).setting_more_new_discover,
                          des: S.of(context).setting_more_new_discover_des,
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
                            OptionData(
                                label:
                                    S.of(context).setting_more_dark_mode_sync,
                                tag: 'follow_system'),
                            OptionData(
                                label: S.of(context).setting_more_dark_mode_on,
                                tag: 'always_on'),
                            OptionData(
                                label: S.of(context).setting_more_dark_mode_off,
                                tag: 'always_off')
                          ];

                          return OptionItem(
                              topRadius: false,
                              bottomRadius: false,
                              label: S.of(context).setting_more_dark_mode,
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
                  padding: const EdgeInsets.only(left: 30, right: 16),
                  child: Container(
                    margin: const EdgeInsets.only(left: 14),
                    height: 0.5,
                    color: const Color.fromRGBO(0, 0, 0, 0.08),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                  child: ClickableItem(
                    label: S.of(context).setting_more_clean_cache,
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
              visible: DevConfig.instance.current,
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
                    padding: const EdgeInsets.only(left: 16, top: 4, right: 16),
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
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                    child: ClickableItem(
                        label: '语言',
                        tail: Localizations.localeOf(context).toString(),
                        topRadius: false,
                        onClick: () {
                          showCupertinoModalPopup(
                              context: context,
                              builder: (context) {
                                return const DevNewLocaleBottomSheet();
                              });
                        }),
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
                        left: 16, top: 4, right: 16, bottom: 16),
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
              padding: const EdgeInsets.only(left: 16, top: 20, right: 16),
              child: ValueListenableBuilder<String>(
                valueListenable: version,
                builder: (BuildContext context, String value, Widget? child) {
                  return ClickableItem(
                    label: S.of(context).help_about,
                    tail: 'v$value',
                    onClick: () {},
                    bottomRadius: Platform.isIOS,
                  );
                },
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
                    visible: !Platform.isIOS,
                    child: Padding(
                      padding:
                          const EdgeInsets.only(left: 16, top: 8, right: 16),
                      child: ValueListenableBuilder<String>(
                        valueListenable: version,
                        builder: (BuildContext context, String value,
                            Widget? child) {
                          return ClickableItem(
                              label: S.of(context).help_donate,
                              bottomRadius: false,
                              onClick: widget.goDonateCallback);
                        },
                      ),
                    ),
                  ),
             Padding(
                      padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          bottom: 16,
                          top:  0),
                      child: ClickableItem(
                          label: S.of(context).help_recommend,
                          topRadius: Platform.isIOS,
                          onClick: () {
                            showCupertinoModalPopup(
                                context: context,
                                builder: (BuildContext context) =>
                                    FlixShareBottomSheet(context));
                          })),



             Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
              child: ClickableItem(
                label: '用户协议',
                bottomRadius: false,
                onClick: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const IntroAgreementPage()),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: ClickableItem(
                label: '隐私政策',
                topRadius: Platform.isIOS,
                onClick: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const IntroPrivacyPage()),
                  );
                },
              ),
            ),

              Padding(
                    padding: const EdgeInsets.only(
                        left: 20, top: 20, right: 20, bottom: 4),
                    child: Text(
                      S.of(context).help_title,
                      style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                              color:
                                  Theme.of(context).flixColors.text.secondary)
                          .fix(),
                    ),
                  ),
                  
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 16, right: 16, bottom: 10),
                    child: QA(
                        question: S.of(context).help_q_1,
                        answer: S.of(context).help_a_1),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 16, right: 16, bottom: 10),
                    child: QA(
                        question: S.of(context).help_q_2,
                        answer: S.of(context).help_a_2),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 16, right: 16, bottom: 10),
                    child: QA(
                        question: S.of(context).help_q_3,
                        answer: S.of(context).help_a_3),
                  ),
                  Padding(
                      padding: const EdgeInsets.only(
                          left: 16, right: 16, bottom: 10),
                      child: QA(
                          question: S.of(context).help_q_4,
                          answer: S.of(context).help_a_4)),
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
