import 'package:anydrop/presentation/widgets/helps/QA.dart';
import 'package:anydrop/presentation/widgets/settings/clickable_item.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class HelpScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HelpScreenState();
}

class HelpScreenState extends State<HelpScreen> {
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
    return Container(
      decoration:
          const BoxDecoration(color: Color.fromARGB(255, 247, 247, 247)),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
                padding: const EdgeInsets.only(
                    top: 60, left: 20, right: 20, bottom: 10),
                child: InkWell(
                  onTap: () async {
                    // MultiCastClientProvider.of(context).clearDevices();
                  },
                  child: const Text('软件帮助',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 36.0,
                          fontWeight: FontWeight.normal)),
                )),
            Expanded(
                child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 16, top: 4, right: 16, bottom: 16),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14)),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: ValueListenableBuilder<String>(
                          valueListenable: version,
                          builder: (BuildContext context, String value,
                              Widget? child) {
                            return ClickableItem(
                                label: '关于我们', tail: 'v$value', onClick: () {});
                          },
                        ),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(
                        left: 20, top: 20, right: 20, bottom: 4),
                    child: Text(
                      '关于连接',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                          color: Color.fromRGBO(60, 60, 67, 0.6)),
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
              ),
            ))
          ],
        ),
      ),
    );
  }
}
