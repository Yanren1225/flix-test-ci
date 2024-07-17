import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/presentation/basic/corner/flix_clip_r_rect.dart';
import 'package:flix/presentation/widgets/flix_toast.dart';
import 'package:flix/presentation/widgets/segements/navigation_scaffold.dart';
import 'package:flix/theme/theme_extensions.dart';
import 'package:flix/utils/download_nonweb_logs.dart';
import 'package:flix/utils/text/text_extension.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:talker/talker.dart';
import 'package:url_launcher/url_launcher.dart';

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
        title: '关于我们',
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
                  parent: BouncingScrollPhysics(decelerationRate: ScrollDecelerationRate.fast)),
              padding: padding.copyWith(
                  bottom: padding.bottom + MediaQuery.of(context).padding.bottom + 20),
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 80.0, top: 12, bottom: 12),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: DecoratedBox(
                        decoration: BoxDecoration(
                            color: Theme.of(context).flixColors.background.primary,
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
      child: Text('👋 你好，很高兴认识你！',
          style: TextStyle(
                  color: Theme.of(context).flixColors.text.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w400)
              .fix()),
    );
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
      child: Text('这里是 Flix，一个快速简洁的多端互传软件，希望你能喜欢 😆',
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

      child: Text(
          'Flix 制作小组\n------\n✅设计：\nlemo\n\n✅开发：\nMovenLecker\nEava_wu\n炎忍\nMashiro.\n皓洋\n张建\n广靓\nChengi\nxkeyC\n小灰灰\n何言\ngggxbbb'
              '\n一季或微凉\nkailun\n暮间雾\nyuzh',
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
            const TextSpan(text: '如果你有任何想法，欢迎你'),
            ClickableSpan('点我进入官方QQ群 🌸', () {
              final Uri url = Uri.parse(
                  'http://qm.qq.com/cgi-bin/qm/qr?_wv=1027&k=sLHZTbK8nxPPoKl2BWApIKoO9TBBGua8&authKey=XBVLWiLqFFt5UD72Gc8tOhyj2Y02J%2FF%2Bw4ijEv%2FsWrYVPy8Y%2B5lbbxvLyx6EQwMP&noverify=0&group_code=539943326');
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
            const TextSpan(text: '最后，你也可以'),
            ClickableSpan('点我进入捐赠渠道', () {}),
            const TextSpan(text: '，非常感谢你来支持我们的持续开发 🙏'),
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
            builder: (_, version, child) => Text('当前软件版本：v$version',
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
