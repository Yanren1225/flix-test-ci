import 'dart:io';

import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/domain/settings/settings_repo.dart';
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
import 'package:talker_flutter/talker_flutter.dart';

import '../../../l10n/l10n.dart';

class AutomaticReceivenScreen extends StatefulWidget {
  var versionTapCount = 0;
  int lastTapTime = 0;
  bool showBack = true;

  AutomaticReceivenScreen({super.key, required this.showBack});

  @override
  State<StatefulWidget> createState() => AutomaticReceivenScreenState();
}

class AutomaticReceivenScreenState extends State<AutomaticReceivenScreen> {
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

  
  void clearThirdWidget() {
    Provider.of<BackProvider>(context, listen: false).backMethod();
  }

  @override
 Widget build(BuildContext context) {
  final bool showAutoSaveMedia = Platform.isAndroid;
    var width = MediaQuery.of(context).size.width;
    final bool showAppLaunchConfig = isDesktop();
    return NavigationScaffold(
      title: '自动接收',
      onClearThirdWidget: clearThirdWidget,
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
              padding: const EdgeInsets.only(left: 16, top: 4, right: 16),
              child: SettingsItemWrapper(
                topRadius: true,
                bottomRadius: true,
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


              Visibility(
              visible: showAutoSaveMedia,
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 16,top: 8),
                child: SettingsItemWrapper(
                  topRadius: true,
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