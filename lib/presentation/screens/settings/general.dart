import 'dart:io';

import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/domain/settings/settings_repo.dart';
import 'package:flix/l10n/lang_config.dart';
import 'package:flix/presentation/basic/corner/flix_clip_r_rect.dart';
import 'package:flix/presentation/basic/corner/flix_decoration.dart';
import 'package:flix/presentation/screens/main_screen.dart';
import 'package:flix/presentation/screens/settings/confirm_clean_cache_bottom_sheet.dart';
import 'package:flix/presentation/widgets/helps/qa.dart';
import 'package:flix/presentation/widgets/segements/navigation_scaffold.dart';
import 'package:flix/presentation/widgets/settings/clickable_item.dart';
import 'package:flix/presentation/widgets/settings/option_item.dart';
import 'package:flix/presentation/widgets/settings/settings_item_wrapper.dart';
import 'package:flix/presentation/widgets/settings/switchable_item.dart';
import 'package:flix/theme/theme_extensions.dart';
import 'package:flix/utils/file/file_helper.dart';
import 'package:flix/utils/pay/pay_util.dart';
import 'package:flix/utils/platform_utils.dart';
import 'package:flix/utils/text/text_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../../../l10n/l10n.dart';

class GeneralScreen extends StatefulWidget {
  var versionTapCount = 0;
  int lastTapTime = 0;
  bool showBack = true;

  GeneralScreen({super.key, required this.showBack});

  @override
  State<StatefulWidget> createState() => GeneralScreenState();
}

class GeneralScreenState extends State<GeneralScreen> {
  var isStartUpEnabled = false;
  bool isDirectExitEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadDirectExitStatus();

    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      launchAtStartup.isEnabled().then((value) {
        setState(() {
          isStartUpEnabled = value;
        });
      });
    }
  }

  void clearThirdWidget() {
    Provider.of<BackProvider>(context, listen: false).backMethod();
  }

  Future<void> _loadDirectExitStatus() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('direct_exit')) {
      setState(() {
        isDirectExitEnabled = prefs.getBool('direct_exit')!;
      });
    } else {
      await prefs.setBool('direct_exit', true);
      setState(() {
        isDirectExitEnabled = true;
      });
    }
  }

  Future<void> _saveDirectExitStatus(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('direct_exit', value);
  }

  @override
  Widget build(BuildContext context) {
    final bool showAppLaunchConfig = isDesktop();
    return NavigationScaffold(
      title: '通用',
      onClearThirdWidget: clearThirdWidget,
      showBackButton: widget.showBack,
      builder: (EdgeInsets padding) {
        return Container(
          margin: const EdgeInsets.only(top: 6),
          width: double.infinity,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 20, top: 4, right: 20),
                      child: Text(
                        '界面显示',
                        style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.normal,
                                color:
                                    Theme.of(context).flixColors.text.secondary)
                            .fix(),
                      ),
                    ),
                    StreamBuilder<String>(
                        stream: SettingsRepo.instance.darkModeTagStream.stream,
                        initialData: SettingsRepo.instance.darkModeTag,
                        builder: (context, snapshot) {
                          return Padding(
                            padding: const EdgeInsets.only(
                                left: 16, right: 16, top: 6),
                            child: Builder(builder: (context) {
                              final options = [
                                OptionData(
                                    label: S
                                        .of(context)
                                        .setting_more_dark_mode_sync,
                                    tag: 'follow_system'),
                                OptionData(
                                    label:
                                        S.of(context).setting_more_dark_mode_on,
                                    tag: 'always_on'),
                                OptionData(
                                    label: S
                                        .of(context)
                                        .setting_more_dark_mode_off,
                                    tag: 'always_off')
                              ];

                              return OptionItem(
                                  topRadius: true,
                                  bottomRadius: false,
                                  label: S.of(context).setting_more_dark_mode,
                                  tag: 'dark_mode',
                                  options: options,
                                  value: options.firstWhereOrNull(
                                          (e) => e.tag == snapshot.data) ??
                                      options[0],
                                  onChanged: (value) {
                                    SettingsRepo.instance
                                        .setDarkModeTag(value.tag);
                                  });
                            }),
                          );
                        }),
                    Container(
                      margin: const EdgeInsets.only(left: 14),
                      height: 0.5,
                      color: const Color.fromRGBO(0, 0, 0, 0.08),
                    ),
                    StreamBuilder<LangData>(
                        stream: LangConfig.langStream,
                        initialData: LangConfig.langData,
                        builder: (context, snapshot) {
                          return Padding(
                            padding: const EdgeInsets.only(
                                left: 16, right: 16, bottom: 14),
                            child: Builder(builder: (context) {
                              final options = [
                                const OptionData(tag: "-1", label: "跟随系统"),
                                for (var index = 0;
                                    index < S.delegate.supportedLocales.length;
                                    index++)
                                  OptionData(
                                    tag: index.toString(),
                                    label: (() {
                                      final lang =
                                          S.delegate.supportedLocales[index];
                                      if (lang.nameable) {
                                        return lang.name;
                                      }
                                      return lang.toString();
                                    }).call(),
                                  ),
                              ];
                              return OptionItem(
                                  topRadius: false,
                                  bottomRadius: true,
                                  label: "语言",
                                  tag: 'lang',
                                  options: options,
                                  value: () {
                                    if (snapshot.data!.ifFollowSystem) {
                                      return options.first;
                                    }
                                    final index = S.delegate.supportedLocales
                                        .indexOf(snapshot.data!.lang!);
                                    if (index == -1) {
                                      return options.first;
                                    }
                                    return options[index + 1];
                                  }(),
                                  onChanged: (value) {
                                    final index = int.tryParse(value.tag);
                                    if (index == -1) {
                                      LangConfig.followSystem();
                                      return;
                                    }
                                    LangConfig.set(
                                        S.delegate.supportedLocales[index!]);
                                  });
                            }),
                          );
                        }),
                    Visibility(
                      visible: showAppLaunchConfig,
                      child: Padding(
                        padding:
                            const EdgeInsets.only(left: 20, top: 0, right: 20),
                        child: Text(
                          '运行',
                          style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.normal,
                                  color: Theme.of(context)
                                      .flixColors
                                      .text
                                      .secondary)
                              .fix(),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: showAppLaunchConfig,
                      child: Padding(
                        padding:
                            const EdgeInsets.only(left: 16, right: 16, top: 6),
                        child: SettingsItemWrapper(
                          topRadius: true,
                          bottomRadius: false,
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
                      visible: showAppLaunchConfig,
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 16, right: 16, bottom: 14),
                        child: SettingsItemWrapper(
                          topRadius: false,
                          bottomRadius: true,
                          child: SwitchableItem(
                            label: '退出时最小化到系统托盘',
                            checked: isDirectExitEnabled,
                            onChanged: (value) async {
                              setState(() {
                                isDirectExitEnabled = value!;
                                _saveDirectExitStatus(value);
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 20, top: 0, right: 20),
                      child: Text(
                        '其他',
                        style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.normal,
                                color:
                                    Theme.of(context).flixColors.text.secondary)
                            .fix(),
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 16, top: 6, right: 16),
                      child: SettingsItemWrapper(
                        topRadius: true,
                        bottomRadius: false,
                        child: StreamBuilder<bool>(
                          initialData: SettingsRepo.instance.enableMdns,
                          stream: SettingsRepo.instance.enableMdnsStream.stream,
                          builder: (BuildContext context,
                              AsyncSnapshot<bool> snapshot) {
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
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 16, right: 16, bottom: 16),
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
              ],
            ),
          ),
        );
      },
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
