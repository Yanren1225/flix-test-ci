import 'dart:io';

import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/presentation/basic/corner/flix_clip_r_rect.dart';
import 'package:flix/presentation/basic/corner/flix_decoration.dart';
import 'package:flix/presentation/widgets/helps/qa.dart';
import 'package:flix/presentation/widgets/segements/navigation_scaffold.dart';
import 'package:flix/utils/pay/pay_util.dart';
import 'package:flix/utils/text/text_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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


 

  @override
 Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return NavigationScaffold(
      title: '软件帮助',
      showBackButton: widget.showBack,
      builder: (EdgeInsets padding) {
        return Container(
          margin: const EdgeInsets.only(left: 16, right: 16, top: 10),
          width: double.infinity,
          child: SingleChildScrollView(  // 添加滚动视图
            child: Column(
              children: [
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
                      question: S.of(context).help_q_3,
                      answer: S.of(context).help_a_3),
                ),
                Padding(
                  padding: const EdgeInsets.only( bottom: 10),
                  child: QA(
                      question: S.of(context).help_q_4,
                      answer: S.of(context).help_a_4),
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
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }
 
 

  

  
}