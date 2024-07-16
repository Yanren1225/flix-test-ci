import 'dart:io';

import 'package:flix/domain/version/version_checker.dart';
import 'package:flix/presentation/screens/base_screen.dart';
import 'package:flix/presentation/style/colors/flix_color.dart';
import 'package:flix/presentation/widgets/helps/qa.dart';
import 'package:flix/presentation/widgets/segements/cupertino_navigation_scaffold.dart';
import 'package:flix/presentation/widgets/settings/clickable_item.dart';
import 'package:flix/theme/theme_extensions.dart';
import 'package:flix/utils/text/text_extension.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class HelpScreen extends StatefulWidget {
  VoidCallback goVersionScreen;
  VoidCallback goDonateCallback;

  HelpScreen(
      {super.key,
      required this.goVersionScreen,
      required this.goDonateCallback});

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
                    builder: (BuildContext context,
                        AsyncSnapshot<String?> snapshot) {
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
                            tailColor: snapshot.data?.isNotEmpty == true ? FlixColor.blue: Theme.of(context).flixColors.text.secondary,
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
                    padding: const EdgeInsets.only(
                        left: 20, top: 20, right: 20, bottom: 4),
                    child: Text(
                      '关于连接',
                      style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                              color:
                                  Theme.of(context).flixColors.text.secondary)
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
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 16, right: 16, bottom: 10),
                    child: QA(
                        question: 'Windows端无法接收/发送文件？',
                        answer: trimMultilineString('''
                    请先按照以下步骤，尝试将flix添加到Windows网络防火墙白名单中：
                    1. 搜索「允许应用通过Windows防火墙」
                    2. 点击「更改设置」
                    3. 点击「允许其他应用」
                    4. 添加flix.exe路径（C:\\Users\\[用户名]\\AppData\\Roaming\\Flix\\Flix\\flix.exe或C:\\Program Files\\Flix\\flix.exe）
                    5. 点击「添加」返回到上一页面
                    6. 查看列表中的flix项，勾选「专用」和「公用」
                    7. 保存
                    尝试上述步骤仍旧无法接收，请联系我们。
                    ''')),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 16, right: 16, bottom: 10),
                    child: QA(
                        question: 'PC使用网线时无法接收/发送文件？',
                        answer:
                            '请保证PC和其他设备在一个子网下，即它们的直接上层设备是同一个路由器。若PC通过连接的光猫，其他设备通过Wifi连接的路由器是无法正常接收文件的。'),
                  ),
                ],
              )),
    );
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
