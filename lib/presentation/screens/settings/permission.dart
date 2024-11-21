import 'package:figma_squircle/figma_squircle.dart';
import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/presentation/basic/corner/flix_clip_r_rect.dart';
import 'package:flix/presentation/screens/main_screen.dart';
import 'package:flix/presentation/widgets/flix_toast.dart';
import 'package:flix/presentation/widgets/segements/cupertino_navigation_scaffold.dart';
import 'package:flix/presentation/widgets/segements/navigation_scaffold.dart';
import 'package:flix/theme/theme_extensions.dart';
import 'package:flix/presentation/screens/settings/dev/dev_config.dart';
import 'package:flix/utils/download_nonweb_logs.dart';
import 'package:flix/utils/text/text_extension.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:talker/talker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../l10n/l10n.dart';

class PermissionScreen extends StatefulWidget {
  final bool showBack;

  const PermissionScreen({super.key, this.showBack = true});

  @override
  State<StatefulWidget> createState() => PermissionScreenState();
}

class PermissionScreenState extends State<PermissionScreen> {
  var versionTapCount = 0;
  int lastTapTime = 0;

  final ValueNotifier<String> _version = ValueNotifier('');

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((packageInfo) {
      _version.value = packageInfo.version;
    });
  }

     void clearThirdWidget() {
    Provider.of<BackProvider>(context, listen: false).backMethod();
  }

  @override
  Widget build(BuildContext context) {
    return NavigationScaffold(
        showBackButton: widget.showBack,
        title:'应用权限',
       onClearThirdWidget: clearThirdWidget,
        builder: (EdgeInsets padding) {
           return Container(
            margin: const EdgeInsets.only( top: 10,right: 16,left: 16,bottom: 0),
          width: double.infinity,
            child: pra(),
           );
        });
  }

  Widget pra() {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 0),
    child: SingleChildScrollView(
      child: Align(
        alignment: Alignment.centerLeft, 
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start, 
          children: [
            ListView(
                    shrinkWrap: true,
                    children: [
                      _buildPermissionItem(
                          'assets/images/permission_item1.svg', S.of(context).intro_permission_3a, S.of(context).intro_permission_3b),
                      _buildPermissionItem(
                          'assets/images/permission_item2.svg', S.of(context).intro_permission_4a, S.of(context).intro_permission_4b),
                      _buildPermissionItem(
                          'assets/images/permission_item3.svg', S.of(context).intro_permission_5a, S.of(context).intro_permission_5b),
                      _buildPermissionItem(
                          'assets/images/permission_item4.svg', S.of(context).intro_permission_6a, S.of(context).intro_permission_6b),
                      _buildPermissionItem(
                          'assets/images/permission_item5.svg', S.of(context).intro_permission_7a, S.of(context).intro_permission_7b),
                    ],
                  ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildPermissionItem(String assetPath, String title, String subtitle) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        decoration: BoxDecoration(
          color: Theme.of(context).flixColors.background.primary,
         borderRadius: SmoothBorderRadius(
                                cornerRadius: 15,
                                cornerSmoothing: 0.6,
                              ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.only(left: 20.0),
          leading: SvgPicture.asset(
            assetPath,
            width: 24,
            height: 24,
            fit: BoxFit.contain,
          ),
          title: Text(title),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              color: Theme.of(context).flixColors.text.secondary,
            ),
          ),
          horizontalTitleGap: 16.0,
        ),
      ),
    );
  }

  


  
}
