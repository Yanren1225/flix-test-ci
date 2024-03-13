import 'package:flix/presentation/widgets/segements/navigation_scaffold.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class AboutUSScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return NavigationScaffold(
        title: '关于我们',
        builder: (padding) {
          final widgets = <Widget>[
            niceToMeetU(),
            logo(),
            brief(),
            participate(),
            feedbackGuide(),
            donate(),
            version()
          ];
          return ListView.builder(
              physics: const BouncingScrollPhysics(decelerationRate: ScrollDecelerationRate.fast),
              padding: padding.copyWith(bottom: padding.bottom + MediaQuery.of(context).padding.bottom + 20),
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(
                      left: 16.0, right: 80.0, top: 12, bottom: 12),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: DecoratedBox(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10)),
                        child: widgets[index]),
                  ),
                );
              },
              itemCount: widgets.length);
        });
  }

  Widget niceToMeetU() {
    return const Padding(
      padding: EdgeInsets.all(10.0),
      child: Text('👋 你好，很高兴认识你！',
          style: TextStyle(
              color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500)),
    );
  }

  Widget logo() {
    return ClipRRect(
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
    return const Padding(
      padding: EdgeInsets.all(10.0),
      child: Text('这里是 Flix，一个快速简洁的多端互传软件，希望你能喜欢 😆',
          style: TextStyle(
              color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500)),
    );
  }

  Widget participate() {
    return const Padding(
      padding: EdgeInsets.only(left: 10, top: 10, right: 80, bottom: 10),
      child: Text('Flix 制作小组\n------\n✅设计：\nlemo\n\n✅开发：\nMovenLecker\nEava_wu',
          style: TextStyle(
              color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500)),
    );
  }

  Widget feedbackGuide() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Text.rich(TextSpan(
          children: [
            TextSpan(text: '如果你有任何想法，欢迎你'),
            ClickableSpan('点我进入官方QQ群', () {}),
            TextSpan(text: '，也可以通过'),
            ClickableSpan('邮箱 xxxxx@xx.com', () {}),
            TextSpan(text: ' 联系我们 🌸')
          ],
          style: TextStyle(
              color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500))),
    );
  }

  Widget donate() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Text.rich(TextSpan(
          children: [
            TextSpan(text: '最后，你也可以'),
            ClickableSpan('点我进入捐赠渠道', () {}),
            TextSpan(text: '，非常感谢你来支持我们的持续开发 🙏'),
          ],
          style: TextStyle(
              color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500))),
    );
  }

  Widget version() {
    return const Padding(
      padding: EdgeInsets.all(10.0),
      child: Text('当前软件版本：V0.0.1-b24010601',
          style: TextStyle(
              color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500)),
    );
  }

  TextSpan ClickableSpan(String text, GestureTapCallback onTap) {
    return TextSpan(
        text: text,
        style: const TextStyle(color: Color.fromRGBO(0, 122, 255, 1)),
        recognizer: TapGestureRecognizer()..onTap = onTap);
  }
}
