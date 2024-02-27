import 'package:androp/domain/settings/SettingsRepo.dart';
import 'package:androp/presentation/widgets/settings/switchable_item.dart';
import 'package:flutter/material.dart';

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
                  child: const Text('软件配置',
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
                  )
                ],
              ),
            ))
          ],
        ),
      ),
    );
  }
}
