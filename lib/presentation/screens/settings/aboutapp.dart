import 'dart:io';

import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/domain/settings/settings_repo.dart';
import 'package:flix/l10n/lang_config.dart';
import 'package:flix/presentation/basic/corner/flix_clip_r_rect.dart';
import 'package:flix/presentation/basic/corner/flix_decoration.dart';
import 'package:flix/presentation/screens/main_screen.dart';
import 'package:flix/presentation/screens/settings/confirm_clean_cache_bottom_sheet.dart';
import 'package:flix/presentation/screens/settings/open.dart';
import 'package:flix/presentation/screens/settings/permission.dart';
import 'package:flix/presentation/widgets/flix_bottom_sheet.dart';
import 'package:flix/presentation/widgets/helps/qa.dart';
import 'package:flix/presentation/widgets/segements/navigation_scaffold.dart';
import 'package:flix/presentation/widgets/settings/clickable_item.dart';
import 'package:flix/presentation/widgets/settings/option_item.dart';
import 'package:flix/presentation/widgets/settings/settings_item_wrapper.dart';
import 'package:flix/presentation/widgets/settings/switchable_item.dart';
import 'package:flix/theme/theme_extensions.dart';
import 'package:flix/utils/exit.dart';
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
import 'package:url_launcher/url_launcher.dart';

import '../../../l10n/l10n.dart';

class AppInfoScreen extends StatefulWidget {
  var versionTapCount = 0;
  int lastTapTime = 0;
  bool showBack = true;
  final VoidCallback goSettingPravicyScreen;
  final VoidCallback goSettingAgreementScreen;
  final VoidCallback goOpensourceScreen;
  final VoidCallback goPermissionScreen;

  AppInfoScreen({super.key, required this.showBack,required this.goSettingPravicyScreen,required this.goOpensourceScreen,
    required this.goSettingAgreementScreen,required this.goPermissionScreen});

  @override
  State<StatefulWidget> createState() => AppInfoScreenState();
}

class AppInfoScreenState extends State<AppInfoScreen> {
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

  void _launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw '无法打开 $url';
  }
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
      title: '应用声明',
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
                        '法律信息',
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
                    child: ClickableItem(
                        label: '用户协议',
                        bottomRadius: false,
                        onClick: () {
                          if (Platform.isAndroid) {
                          _launchURL('http://verification.ifreedomer.com/flix/flix_agreement.html');
                        } else {                      
                          widget.goSettingAgreementScreen();
                        }
                        }),
                  ),
                    Container(
                      margin: const EdgeInsets.only(left: 14),
                      height: 0.5,
                      color: const Color.fromRGBO(0, 0, 0, 0.08),
                    ),
                 
                    Padding(
                    padding:
                        const EdgeInsets.only(left: 16, top: 0, right: 16),
                    child: ClickableItem(
                        label: '隐私政策',
                        topRadius: false,
                        bottomRadius: true,
                        onClick: () {
                      
                       
                         if (Platform.isAndroid) {
                          _launchURL('http://verification.ifreedomer.com/flix/flix_privacy.html');
                        } else {                      
                          widget.goSettingPravicyScreen();
                        }
                      
                     
                        }),
                  ),
                  Padding(
                      padding:
                          const EdgeInsets.only(left: 20, top: 16, right: 20),
                      child: Text(
                        '撤回同意',
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
                    child: ClickableItem(
                        label: '撤回隐私政策同意',
                        bottomRadius: true,
                        onClick: () {
                          showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return FlixBottomSheet(
        title: '撤回同意隐私政策',
        subTitle: '撤回同意隐私政策后，您将无法继续使用Flix ，直到您再次同意《隐私政策》，你的本地数据不会被删除。',
        buttonText: '确认撤回并退出',
        onClickFuture: () async {
           SharedPreferences prefs = await SharedPreferences.getInstance();
                                await prefs.setBool('isFirstRun', true);

                  doExit();
     
      },
        child: const Padding(
                 padding: EdgeInsets.all(10.0),
                 child: Column(
                  mainAxisSize: MainAxisSize.min,
    children: [
                              
                  ]))

                  
      );
    },
  );
                        }),
                  ),
                   


                     Padding(
                      padding:
                          const EdgeInsets.only(left: 20, top: 16, right: 20),
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
                    child: ClickableItem(
                        label: '开源许可声明',
                        bottomRadius: false,
                        onClick: () {
                          widget.goOpensourceScreen();
                        }),
                  ),
                    Container(
                      margin: const EdgeInsets.only(left: 14),
                      height: 0.5,
                      color: const Color.fromRGBO(0, 0, 0, 0.08),
                    ),
                 
                   Padding(
                    padding:
                        const EdgeInsets.only(left: 16, top: 0, right: 16),
                    child: ClickableItem(
                        label: '应用权限',
                        bottomRadius: false,
                        topRadius: false,
                         onClick: () {
                          widget.goPermissionScreen();
                        }),
                  ),

                   Container(
                      margin: const EdgeInsets.only(left: 14),
                      height: 0.5,
                      color: const Color.fromRGBO(0, 0, 0, 0.08),
                    ),

 Padding(
                    padding:
                        const EdgeInsets.only(left: 16, top: 0, right: 16),
                    child: ClickableItem(
                        label: 'ICP备案号',
                       tail: '鄂ICP备20011308号-5A',
                        bottomRadius: true,
                        topRadius: false,
                         onClick: () {
                            _launchURL('https://beian.miit.gov.cn');
                        }),
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

  
}
