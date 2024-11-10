import 'dart:io';

import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/presentation/basic/corner/flix_clip_r_rect.dart';
import 'package:flix/presentation/basic/corner/flix_decoration.dart';
import 'package:flix/presentation/screens/main_screen.dart';
import 'package:flix/presentation/widgets/helps/qa.dart';
import 'package:flix/presentation/widgets/segements/navigation_scaffold.dart';
import 'package:flix/theme/theme_extensions.dart';
import 'package:flix/utils/pay/pay_util.dart';
import 'package:flix/utils/text/text_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../l10n/l10n.dart';

class QAScreen extends StatefulWidget {
  var versionTapCount = 0;
  int lastTapTime = 0;
  bool showBack = true;

  QAScreen({super.key, required this.showBack});

  @override
  State<StatefulWidget> createState() => QAScreenState();
}

class QAScreenState extends State<QAScreen> {

 void clearThirdWidget() {
    Provider.of<BackProvider>(context, listen: false).backMethod();
  }
 

  @override
 Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return NavigationScaffold(
      title: '帮助',
      onClearThirdWidget: clearThirdWidget,
      showBackButton: widget.showBack,
      builder: (EdgeInsets padding) {
        return Container(
          margin: const EdgeInsets.only(left: 16, right: 16, top: 6),
          width: double.infinity,
          child: SingleChildScrollView(  // 添加滚动视图
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Padding(
                 padding: const EdgeInsets.only(left: 4, top: 4, right: 4,bottom: 6),
                  child: Text(
                    'Windows 连接与传输',
                    style: TextStyle(
                          fontSize: 13.5,
                           fontWeight: FontWeight.normal,
                          color: Theme.of(context).flixColors.text.secondary)
                      .fix(),
                 ),
               ),
                  Padding(
                  padding: const EdgeInsets.only( bottom: 10),
                  child: QA(
                      question: S.of(context).help_q_3,
                      answer: 'Windows 防火墙会导致无法发现设备、传输失败等问题。你可以打开防火墙手动尝试修复。'),
                ),
                Padding(
                 padding: const EdgeInsets.only(left: 4, top: 4, right: 4,bottom: 6),
                  child: Text(
                    '关于连接',
                    style: TextStyle(
                          fontSize: 13.5,
                           fontWeight: FontWeight.normal,
                          color: Theme.of(context).flixColors.text.secondary)
                      .fix(),
                 ),
               ),
                Padding(
                  padding: const EdgeInsets.only( bottom: 10),
                  child: QA(
                      question: S.of(context).help_q_1,
                      answer: S.of(context).help_a_1),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: QA(
                      question: S.of(context).help_q_2,
                      answer: S.of(context).help_a_2),
                ),
                Padding(
                  padding: const EdgeInsets.only( bottom: 10),
                  child: QA(
                      question: S.of(context).help_q_4,
                      answer: S.of(context).help_a_4),
                ),
                  Padding(
                 padding: const EdgeInsets.only(left: 4, top: 4, right: 4,bottom: 6),
                  child: Text(
                    '关于功能',
                    style: TextStyle(
                          fontSize: 13.5,
                           fontWeight: FontWeight.normal,
                          color: Theme.of(context).flixColors.text.secondary)
                      .fix(),
                 ),
               ),
                 Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: QA(
                      question: '自动接收是什么？',
                      answer: '打开自动接收开关后，当你的设备接收到其他设备发来的文件时，将不会弹窗确认，文件会自动保存在设定的目录内，体验更顺畅。'),
                ),
                 Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: QA(
                      question: '我设置了开机自动启动、后台运行本软件，我的设备会变卡吗？',
                      answer: '不会。Flix 软件内存占用极低，不会影响你的设备。'),
                ),
                 Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: QA(
                      question: '热点码和设备码的区别是什么？',
                      answer: '热点码适用于“没有同一个网络”的场景。如在户外传输，一方打开热点码，另一方扫码即可建立同一网络。设备码适用于“已在同一网络下但找不到设备”的场景。通过设备码扫码手动配对，可建立连接。'),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: QA(
                      question: '如何获取软件日志？',
                      answer: '进入“关于我们”页面，双击底部的版本号，即可获取软件日志。'),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }
 
 

  

  
}