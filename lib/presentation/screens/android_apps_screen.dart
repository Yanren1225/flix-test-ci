import 'dart:developer';

import 'package:androp/presentation/widgets/app_icon.dart';
import 'package:androp/presentation/widgets/check_state_box.dart';
import 'package:androp/presentation/widgets/search_box.dart';
import 'package:androp/utils/apk_utils.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AppsScreen extends StatefulWidget {
  const AppsScreen({super.key});

  // @override
  // Widget build(BuildContext context) {

  // return Scaffold(
  //   appBar: AppBar(
  //     leading: GestureDetector(
  //       onTap: () => Navigator.pop(context),
  //       child: const Icon(
  //         Icons.arrow_back_ios,
  //         color: Colors.black,
  //         size: 20,
  //       ),
  //     ),
  //     title: const Text('选择App'),
  //     titleTextStyle: const TextStyle(
  //         color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500),
  //     backgroundColor: const Color.fromRGBO(247, 247, 247, 1),
  //     surfaceTintColor: const Color.fromRGBO(247, 247, 247, 1),
  //   ),
  //   body: Container(
  //       decoration:
  //           const BoxDecoration(color: Color.fromRGBO(247, 247, 247, 1)),
  //       child: const ShareConcertMainView()),
  // );
  // }

  @override
  State<StatefulWidget> createState() => AppsScreenState();
}

class AppsScreenState extends State<AppsScreen> {
  List<Application> apps = List.empty();

  Set<Application> selectedApp = {};

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        log('didPop: ${didPop}');
        if (!didPop) {
          Future.delayed(Duration.zero, () {
            Navigator.pop(context, selectedApp.toList());
          });
        }
        // Navigator.pop(context);
      },
      child: Material(
        color: const Color.fromRGBO(247, 247, 247, 1),
        child: ListView.builder(
            itemCount: apps.length,
            itemBuilder: (context, index) {
              final Application app = apps[index];
              return AppItem(
                  application: app,
                  onChecked: (checked) {
                    if (checked) {
                      setState(() {
                        selectedApp.add(app);
                      });
                    } else {
                      setState(() {
                        selectedApp.remove(app);
                      });
                    }
                  });
            }),
      ),
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

  bool _checked = false;

  void _setChecked(bool? checked) {
    if (checked == null) return;
    setState(() {
      _checked = checked;
    });
    onChecked(checked);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        _setChecked(!_checked);
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
              CheckStateBox(checked: _checked)
            ]),
      ),
    );
  }
}
