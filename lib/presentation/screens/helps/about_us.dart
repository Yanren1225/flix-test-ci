import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/presentation/basic/corner/flix_clip_r_rect.dart';
import 'package:flix/presentation/widgets/flix_toast.dart';
import 'package:flix/presentation/widgets/segements/cupertino_navigation_scaffold.dart';
import 'package:flix/presentation/widgets/segements/navigation_scaffold.dart';
import 'package:flix/theme/theme_extensions.dart';
import 'package:flix/utils/dev_config.dart';
import 'package:flix/utils/download_nonweb_logs.dart';
import 'package:flix/utils/text/text_extension.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:talker/talker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../l10n/l10n.dart';

class AboutUSScreen extends StatefulWidget {
  final bool showBack;

  const AboutUSScreen({super.key, this.showBack = true});

  @override
  State<StatefulWidget> createState() => AboutUSScreenState();
}

class AboutUSScreenState extends State<AboutUSScreen> {
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

  @override
  Widget build(BuildContext context) {
    return NavigationScaffold(
        showBackButton: widget.showBack,
        toolbarCoverBody: true,
        title: S.of(context).help_about,
        builder: (padding) {
          final widgets = <Widget>[
            niceToMeetU(),
            // logo(),
            brief(),
            participate(),
            feedbackGuide(),
            // donate(),
            version()
          ];
          return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(
                      decelerationRate: ScrollDecelerationRate.fast)),
              padding: padding.copyWith(
                  bottom: padding.bottom +
                      MediaQuery.of(context).padding.bottom +
                      20),
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(
                      left: 16.0, right: 80.0, top: 12, bottom: 12),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: DecoratedBox(
                        decoration: BoxDecoration(
                            color:
                                Theme.of(context).flixColors.background.primary,
                            borderRadius: BorderRadius.circular(10)),
                        child: widgets[index]),
                  ),
                );
              },
              itemCount: widgets.length);
        });
  }

  Widget niceToMeetU() {
    return Padding(
        padding: const EdgeInsets.all(10.0),
        child: GestureDetector(
            child: Text(S.of(context).help_hello,
                style: TextStyle(
                        color: Theme.of(context).flixColors.text.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.w400)
                    .fix()),
            onTap: () {
              DevConfig.instance.onCounter();
            }));
  }

  Widget logo() {
    return FlixClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.asset(
        'assets/images/logo.jpg',
        width: 150,
        height: 150,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget brief() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Text(S.of(context).help_description,
          style: TextStyle(
                  color: Theme.of(context).flixColors.text.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w400)
              .fix()),
    );
  }

  Widget participate() {
    return Padding(
      padding: const EdgeInsets.only(left: 10, top: 10, right: 80, bottom: 10),
      child: Text(S.of(context).help_dev_team,
          style: TextStyle(
                  color: Theme.of(context).flixColors.text.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w400)
              .fix()),
    );
  }

  Widget feedbackGuide() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Text.rich(TextSpan(
          children: [
            TextSpan(text: S.of(context).help_join_qq),
            TextSpan(text: S.of(context).help_qq_1),
            ClickableSpan('539943326\n', () {
              final Uri url = Uri.parse('https://qm.qq.com/q/9RTeAZaHRK');
              launchUrl(url).then((value) {
                if (!value) {
                  talker.error('join qq error');
                }
              }).onError((error, stackTrace) {
                talker.error('join qq error', error, stackTrace);
              });
            }),
            TextSpan(text: S.of(context).help_qq_2),
            ClickableSpan('992894289\n', () {
              final Uri url = Uri.parse('https://qm.qq.com/q/aiGWJo7CYo');
              launchUrl(url).then((value) {
                if (!value) {
                  talker.error('join qq error');
                }
              }).onError((error, stackTrace) {
                talker.error('join qq error', error, stackTrace);
              });
            }),
            TextSpan(text: S.of(context).help_qq_3),
            ClickableSpan('779244909', () {
              final Uri url = Uri.parse(
                  'https://qm.qq.com/cgi-bin/qm/qr?k=rnAZO7i9qmK4iBJLUT7SMYq4mP-03yaQ&jump_from=webapi&qr=1');
              launchUrl(url).then((value) {
                if (!value) {
                  talker.error('join qq error');
                }
              }).onError((error, stackTrace) {
                talker.error('join qq error', error, stackTrace);
              });
            }),
          ],
          style: TextStyle(
                  color: Theme.of(context).flixColors.text.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w400)
              .fix())),
    );
  }

  Widget donate() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Text.rich(TextSpan(
          children: [
            TextSpan(text: S.of(context).help_finally),
            ClickableSpan(S.of(context).help_thanks, () {}),
            TextSpan(text: S.of(context).help_thanks),
          ],
          style: TextStyle(
                  color: Theme.of(context).flixColors.text.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w400)
              .fix())),
    );
  }

  Widget version() {
    return Builder(
      builder: (versionContext) => GestureDetector(
        onDoubleTap: () async {
          try {
            await packageLogAndShare(context);
          } catch (e, s) {
            talker.error('日志分享失败', e, s);
            downloadFile(versionContext, talker.history.text).onError(
              (error, stackTrace) {
                talker.error('日志分享失败, $error, $stackTrace', error, stackTrace);
                flixToast.alert("日志分享失败");
              },
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: ValueListenableBuilder(
            valueListenable: _version,
            builder: (_, version, child) => Text(
                S.of(context).help_version(version),
                style: TextStyle(
                        color: Theme.of(context).flixColors.text.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.w400)
                    .fix()),
          ),
        ),
      ),
    );
  }

  TextSpan ClickableSpan(String text, GestureTapCallback onTap) {
    return TextSpan(
        text: text,
        style: const TextStyle(color: Color.fromRGBO(0, 122, 255, 1)).fix(),
        recognizer: TapGestureRecognizer()..onTap = onTap);
  }
}
