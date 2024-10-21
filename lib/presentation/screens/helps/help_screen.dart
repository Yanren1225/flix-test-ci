import 'dart:io';

import 'package:flix/domain/version/version_checker.dart';
import 'package:flix/presentation/screens/base_screen.dart';
import 'package:flix/presentation/style/colors/flix_color.dart';
import 'package:flix/presentation/widgets/helps/qa.dart';
import 'package:flix/presentation/widgets/segements/cupertino_navigation_scaffold.dart';
import 'package:flix/presentation/widgets/settings/clickable_item.dart';
import 'package:flix/theme/theme_extensions.dart';
import 'package:flix/utils/text/text_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flix/presentation/widgets/flix_bottom_sheet.dart';

import '../../../l10n/l10n.dart';
import '../../widgets/helps/flix_share_bottom_sheet.dart';

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
      title: S.of(context).help_title,
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
                            label: S.of(context).help_about,
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
                          ? S
                              .of(context)
                              .help_new_version(snapshot.requireData ?? '')
                          : S.of(context).help_latest_version;
                      return Visibility(
                        visible: !Platform.isIOS,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 16, top: 0, right: 16, bottom: 16),
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
                      padding: EdgeInsets.only(
                          left: 16,
                          right: 16,
                          bottom: 16,
                          top: Platform.isIOS ? 8 : 0),
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
