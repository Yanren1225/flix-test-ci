import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/domain/settings/SettingsRepo.dart';
import 'package:flix/presentation/widgets/segements/cupertino_navigation_scaffold.dart';
import 'package:flix/presentation/widgets/settings/clickable_item.dart';
import 'package:flix/presentation/widgets/settings/switchable_item.dart';
import 'package:flix/presentation/widgets/super_title.dart';
import 'package:flix/utils/file/file_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:talker_flutter/talker_flutter.dart';

class SettingsScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SettingsScreenState();
  }
}

class SettingsScreenState extends State<SettingsScreen> {
  var isAutoSave = false;

  @override
  Widget build(BuildContext context) {
    return CupertinoNavigationScaffold(
      title: '软件配置',
      isSliverChild: false,
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 20, top: 10, right: 20),
              child: Text(
      '接收设置',
      style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: Color.fromRGBO(60, 60, 67, 0.6)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
        left: 16, top: 4, right: 16, bottom: 16),
              child: DecoratedBox(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: StreamBuilder<bool>(
          initialData: SettingsRepo.instance.getAutoReceive(),
          stream:
              SettingsRepo.instance.autoReceiveStream.stream,
          builder: (BuildContext context,
              AsyncSnapshot<bool> snapshot) {
            return SwitchableItem(
              label: '自动接收',
              des: '收到的文件将自动保存',
              checked: snapshot.data ?? false,
              onChanged: (value) {
                setState(() {
                  if (value != null) {
                    SettingsRepo.instance.autoReceive(value);
                  }
                });
              },
            );
          },
        ),
      ),
              ),
            ),
            Visibility(
              visible: !kReleaseMode,
              child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        const Padding(
          padding:
              EdgeInsets.only(left: 20, top: 10, right: 20),
          child: Text(
            '开发者',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: Color.fromRGBO(60, 60, 67, 0.6)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
              left: 16, top: 4, right: 16, bottom: 16),
          child: InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        TalkerScreen(talker: talker),
                  ));
            },
            child: DecoratedBox(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child:
                    ClickableItem(label: '日志', onClick: () {}),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
              left: 16, top: 4, right: 16, bottom: 16),
          child: InkWell(
            onTap: () {
              deleteAppFiles();
            },
            child: DecoratedBox(
              decoration: BoxDecoration(
                  color: Color.fromRGBO(255, 59, 48, 1),
                  borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: StreamBuilder<bool>(
                  initialData:
                      SettingsRepo.instance.getAutoReceive(),
                  stream: SettingsRepo
                      .instance.autoReceiveStream.stream,
                  builder: (BuildContext context,
                      AsyncSnapshot<bool> snapshot) {
                    return const SizedBox(
                      width: double.infinity,
                      child: const Text(
                        textAlign: TextAlign.center,
                        '删除所有数据',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.normal),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
              ),
            ),
          ],
      ),
    );
  }
}
