import 'dart:io';

import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/presentation/widgets/segements/cupertino_navigation_scaffold.dart';
import 'package:flix/presentation/widgets/segements/navigation_scaffold.dart';
import 'package:flix/presentation/widgets/toolbar.dart';
import 'package:flix/utils/PlatformUtil.dart';
import 'package:flix/utils/pay/pay_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

class DonateUSScreen extends StatefulWidget {
  var versionTapCount = 0;
  int lastTapTime = 0;
  bool showBack = true;

  DonateUSScreen({super.key, this.showBack = true});

  @override
  State<StatefulWidget> createState() => DonateUSScreenState();
}

class DonateUSScreenState extends State<DonateUSScreen> {
  final String wxButton = "微信";
  final String alipayButton = "支付宝";
  String buttonName = "微信";

  void _selectButton(String buttonName) {
    // 当点击按钮时，更新选中状态
    setState(() {
      this.buttonName = buttonName;
    });
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return NavigationScaffold(
      title: "捐赠我们",
      showBackButton: PlatformUtil.isMobile(),
      builder: (EdgeInsets padding) {
        return Container(
          margin: const EdgeInsets.only(left: 16, right: 16, top: 20),
          width: double.infinity,
          child: Column(
            children: [
              createTable(width, context),
              createPayPicture(),
              const SizedBox(height: 40),
              Visibility(
                  visible: Platform.isAndroid || Platform.isIOS,
                  child: createDonateButton())
            ],
          ),
        );
      },
    );
  }

  Row createTable(double width, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Flexible(
          flex: 1,
          fit: FlexFit.tight,
          child: Container(
              width: width / 2,
              height: 44,
              child: Center(
                  child: creteButton(
                      context, 'assets/images/ic_alipay.svg', alipayButton))),
        ),
        const SizedBox(
          width: 10,
        ),
        Flexible(
          flex: 1,
          fit: FlexFit.tight,
          child: Container(
              width: width / 2,
              height: 44,
              child: Center(
                  child: creteButton(
                      context, 'assets/images/ic_wechat_pay.svg', wxButton))),
        ),
      ],
    );
  }

  Widget creteButton(BuildContext context, String icon, String text) {
    bool isSelectButton = text == buttonName;
    return InkWell(
        onTap: () {
          _selectButton(text);
        },
        child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: isSelectButton
                  ? const Color.fromRGBO(42, 174, 103, 0.1)
                  : Colors.transparent, // 设置背景颜色
              borderRadius: const BorderRadius.all(Radius.circular(5)), // 设置圆角
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // 使用 Image.asset 来加载图片，或者你可以使用 Image.network 来加载网络图片
                SvgPicture.asset(
                  icon,
                  width: 24,
                  height: 24,
                ),
                const SizedBox(width: 8), // 添加一些间距
                Text(text), // 按钮文本
              ],
            )));
  }

  createPayPicture() {
    return Container(
        height: 360,
        margin: const EdgeInsets.only(top: 40),
        child: Image.asset(isWx()
            ? 'assets/images/donate_wechat.png'
            : 'assets/images/donate_alipay.png'));
  }

  createDonateButton() {
    talker.debug("createDonateButton  isWx = $isWx  buttonName = $buttonName ");
    return MaterialButton(
        onPressed: () async {
          if (isWx()) {
            PayUtil.startWechatQrCode();
          } else {
            PayUtil.startAlipayQrCode();
          }
        },
        color: isWx()
            ? const Color.fromRGBO(42, 174, 103, 1)
            : const Color.fromRGBO(0, 122, 255, 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0), // 设置圆角
        ),
        child: SizedBox(
            height: 56,
            child: Center(
                child: Text(
              '保存并跳转到$buttonName扫一扫',
              style: const TextStyle(fontSize: 18, color: Colors.white),
            ))));
  }

  bool isWx() {
    return buttonName.contains(wxButton);
  }
}
