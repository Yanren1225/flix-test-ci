import 'dart:developer';
import 'dart:ffi';

import 'package:androp/presentation/widgets/app_icon.dart';
import 'package:androp/presentation/widgets/check_state_box.dart';
import 'package:androp/utils/app/apk_utils.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';

import '../widgets/blur_appbar.dart';

class AppsScreen extends StatefulWidget {
  const AppsScreen({super.key});

  @override
  State<StatefulWidget> createState() => AppsScreenState();
}

class AppsScreenState extends State<AppsScreen> {
  List<Application> apps = List.empty();

  ValueNotifier<Set<Application>> selectedApps = ValueNotifier({});

  void _back() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      leading: GestureDetector(
        onTap: _back,
        child: const Icon(
          Icons.arrow_back_ios,
          color: Colors.black,
          size: 20,
        ),
      ),
      title: const Text('选择本机应用'),
      titleTextStyle: const TextStyle(
          color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500),
      actions: [
        ValueListenableBuilder(
            valueListenable: selectedApps,
            builder: (_, selectedApps, __) =>
                confirmButton(selectedApps.length))
      ],
      backgroundColor: const Color.fromRGBO(247, 247, 247, 0.8),
      surfaceTintColor: const Color.fromRGBO(247, 247, 247, 0.8),
    );

    final appBarHeight =
        appBar.preferredSize.height + MediaQuery.paddingOf(context).top;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          Future.delayed(Duration.zero, () {
            _back();
          });
        }
        // Navigator.pop(context);
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: const Color.fromRGBO(247, 247, 247, 1),
        appBar: BlurAppBar(
          appBar: AppBar(
            leading: GestureDetector(
              onTap: _back,
              child: const Icon(
                Icons.arrow_back_ios,
                color: Colors.black,
                size: 20,
              ),
            ),
            title: const Text('选择本机应用'),
            titleTextStyle: const TextStyle(
                color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500),
            actions: [
              ValueListenableBuilder(
                  valueListenable: selectedApps,
                  builder: (_, selectedApps, __) =>
                      confirmButton(selectedApps.length))
            ],
            backgroundColor: const Color.fromRGBO(247, 247, 247, 0.8),
            surfaceTintColor: const Color.fromRGBO(247, 247, 247, 0.8),
          ),
        ),
        body: ListView.builder(
            padding: EdgeInsets.only(top: appBarHeight),
            itemCount: apps.length,
            itemBuilder: (context, index) {
              final Application app = apps[index];
              return AppItem(
                  application: app,
                  onChecked: (checked) {
                    if (checked) {
                      selectedApps.value.add(app);
                      selectedApps.notifyListeners();
                    } else {
                      selectedApps.value.remove(app);
                      selectedApps.notifyListeners();
                    }
                  });
            }),
      ),
    );
  }

  Widget confirmButton(int count) {
    return TextButton(
      onPressed: () {
        Navigator.pop(context, selectedApps.value.toList());
      },
      child: Text('发送 ($count)'),
    );
  }

  @override
  void initState() {
    super.initState();
    getInstalledApps().then((apps) {
      log('loaded apps size: ${apps.length}');
      setState(() {
        this.apps = apps;
      });
    });
  }
}

typedef OnChecked = void Function(bool checked);

class AppItem extends StatefulWidget {
  final Application application;
  final OnChecked onChecked;

  const AppItem(
      {super.key, required this.application, required this.onChecked});

  @override
  State<StatefulWidget> createState() => AppItemState();
}

class AppItemState extends State<AppItem> {
  Application get application => widget.application;
  OnChecked get onChecked => widget.onChecked;

  final ValueNotifier<bool> _checked = ValueNotifier<bool>(false);

  void _setChecked(bool? checked) {
    if (checked == null) return;
    _checked.value = checked;
    onChecked(checked);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        _setChecked(!_checked.value);
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 16, top: 9, right: 16, bottom: 9),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image(
                image: AppIcon(app: application),
                width: 50,
                height: 50,
              ),
              const SizedBox(
                width: 16,
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      application.appName,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.black),
                    ),
                    Text(
                      application.packageName,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Color.fromRGBO(60, 60, 67, 0.6)),
                    )
                  ],
                ),
              ),
              ValueListenableBuilder(
                valueListenable: _checked,
                builder: (context, checked, child) =>
                    CheckStateBox(checked: checked),
              )
            ]),
      ),
    );
  }
}
