import 'dart:io';

import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/domain/settings/settings_repo.dart';
import 'package:flix/presentation/basic/corner/flix_clip_r_rect.dart';
import 'package:flix/presentation/basic/corner/flix_decoration.dart';
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
@override
  void initState() {
    super.initState();
    

    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      launchAtStartup.isEnabled().then((value) {
        setState(() {
          isStartUpEnabled = value;
        });
      });
    
  }
  }

  
 

  @override
 Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    final bool showAppLaunchConfig = isDesktop();
    return NavigationScaffold(
      title: '通用',
      
      showBackButton: widget.showBack,
      builder: (EdgeInsets padding) {
        return Container(
          margin: const EdgeInsets.only( top: 6),
          width: double.infinity,
          child: SingleChildScrollView(  
            child: Column(
              children: [
                    Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20, top: 0, right: 20),
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
                  Visibility(
              visible: showAppLaunchConfig,
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: SettingsItemWrapper(
                  topRadius: true,
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