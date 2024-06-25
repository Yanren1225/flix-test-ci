import 'dart:io';

import 'package:flix/domain/version/version_checker.dart';
import 'package:flix/presentation/style/colors/flix_color.dart';
import 'package:flix/utils/text/text_extension.dart';
import 'package:flix/presentation/screens/base_screen.dart';
import 'package:flix/presentation/screens/helps/about_us.dart';
import 'package:flix/presentation/widgets/helps/QA.dart';
import 'package:flix/presentation/widgets/segements/cupertino_navigation_scaffold.dart';
import 'package:flix/presentation/widgets/settings/clickable_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

class HelpScreen extends StatefulWidget {
  VoidCallback goVersionScreen;
  VoidCallback goDonateCallback;

  HelpScreen({required this.goVersionScreen, required this.goDonateCallback});

  @override
  State<StatefulWidget> createState() => HelpScreenState();
}

class HelpScreenState extends BaseScreenState<HelpScreen> {
  ValueNotifier<String> version = ValueNotifier('');

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((packageInfo) {
      version.value = packageInfo.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoNavigationScaffold(
      title: '软件帮助',
      isSliverChild: true,
      padding: 10,
      enableRefresh: false,
      child: SliverList.builder(
          itemCount: 1,
          itemBuilder: (context, index) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 16, top: 8, right: 16, bottom: 0),
                    child: ValueListenableBuilder<String>(
                      valueListenable: version,
                      builder:
                          (BuildContext context, String value, Widget? child) {
                        return ClickableItem(
                            label: '关于我们',
                            tail: 'v$value',
                            onClick: widget.goVersionScreen,
                            bottomRadius: Platform.isIOS);
                      },
                    ),
                  ),
                  StreamBuilder<String?>(
                    initialData: VersionChecker.newestVersion,
                    stream: VersionChecker.newestVersionStream.stream,
                    builder:
                        (BuildContext context, AsyncSnapshot<String?> snapshot) {
                      final tail = snapshot.data?.isNotEmpty == true
                          ? '新版本 v${snapshot.requireData}'
                          : '已是最新版本';
                      return Visibility(
                        visible: !Platform.isIOS,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 16, top: 0, right: 16, bottom: 16),
                          child: ClickableItem(
                            label: '检查更新',
                            tail: tail,
                            tailColor: FlixColor.blue,
                            onClick: () {
                              VersionChecker.checkNewVersion(context, ignorePromptCount: true);
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
                      padding: const EdgeInsets.only(
                          left: 16, top: 8, right: 16, bottom: 16),
                      child: ValueListenableBuilder<String>(
                        valueListenable: version,
                        builder: (BuildContext context, String value,
                            Widget? child) {
                          return ClickableItem(
                              label: '❤️捐赠支持我们',
                              onClick: widget.goDonateCallback);
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        left: 20, top: 20, right: 20, bottom: 4),
                    child: Text(
                      '关于连接',
                      style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                              color: Color.fromRGBO(60, 60, 67, 0.6))
                          .fix(),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 16, right: 16, bottom: 10),
                    child: QA(
                        question: '列表里找不到设备？',
                        answer:
                            '请确认发送端和接收端设备处于同一个网络状态下。如：同一个WIFI，或者使用本机热点给其他设备连接使用。'),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 16, right: 16, bottom: 10),
                    child: QA(question: '传输文件会消耗流量吗？', answer: '不会。'),
                  ),
                ],
              )),
    );
  }
}
