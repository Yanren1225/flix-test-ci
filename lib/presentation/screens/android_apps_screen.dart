import 'package:device_apps/device_apps.dart';
import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/presentation/widgets/app_icon.dart';
import 'package:flix/presentation/widgets/check_state_box.dart';
import 'package:flix/presentation/widgets/search_box.dart';
import 'package:flix/theme/theme_extensions.dart';
import 'package:flix/utils/app/apk_utils.dart';
import 'package:flix/utils/text/text_extension.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pinyin/pinyin.dart';

import '../widgets/blur_appbar.dart';

class AppsScreen extends StatefulWidget {
  const AppsScreen({super.key});

  @override
  State<StatefulWidget> createState() => AppsScreenState();
}

class AppsScreenState extends State<AppsScreen> {
  // List<Application> apps = List.empty();
  List<String> sortedPackageNames = List.empty();
  List<String> originSortPackageNames = List.empty();
  Map<String, Application> package2AppMap = {};

  Map<String, AppIcon> package2AppIcon = {};

  ValueNotifier<Set<Application>> selectedApps = ValueNotifier({});

  void _back() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      leading: GestureDetector(
        onTap: _back,
        child: Icon(
          Icons.arrow_back_ios,
          color: Theme.of(context).flixColors.text.primary,
          size: 20,
        ),
      ),
      title: const Text('选择本机应用'),
      titleTextStyle: TextStyle(
              color: Theme.of(context).flixColors.text.primary,
              fontSize: 18,
              fontWeight: FontWeight.w500)
          .fix(),
      actions: [
        ValueListenableBuilder(
            valueListenable: selectedApps,
            builder: (_, selectedApps, __) =>
                confirmButton(selectedApps.length))
      ],
      backgroundColor:
          Theme.of(context).flixColors.background.secondary.withOpacity(0.8),
      surfaceTintColor:
          Theme.of(context).flixColors.background.secondary.withOpacity(0.8),
    );

    final appBarHeight =
        appBar.preferredSize.height + MediaQuery.paddingOf(context).top;

    return PopScope(
      canPop: true,
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
          backgroundColor: Theme.of(context).flixColors.background.secondary,
          appBar: BlurAppBar(
            appBar: appBar,
            cpreferredSize: appBar.preferredSize,
          ),
          body: Container(
            margin: EdgeInsets.only(top: appBarHeight),
            child: Column(
              children: [
                SizedBox(child: createSearchBar()),
                Expanded(
                    child: MediaQuery.removePadding(
                        removeTop: true,
                        context: context,
                        child: createListView())),
              ],
            ),
          )),
    );
  }

  ListView createListView() {
    return ListView.builder(
        itemCount: sortedPackageNames.length,
        itemBuilder: (context, index) {
          final packageName = sortedPackageNames[index];
          final Application app = package2AppMap[packageName]!;
          final AppIcon? icon = package2AppIcon[packageName];
          return AppItem(
              application: app,
              checked: selectedApps.value.contains(app),
              onChecked: (checked) {
                if (checked) {
                  selectedApps.value.add(app);
                  selectedApps.notifyListeners();
                } else {
                  selectedApps.value.remove(app);
                  selectedApps.notifyListeners();
                }
              },
              icon: icon
          );
        });
  }

  Widget confirmButton(int count) {
    return TextButton(
      onPressed: () {
        Navigator.pop(context, selectedApps.value.toList());
      },
      child: Text(
        '发送 ($count)',
        style: const TextStyle().fix(),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    getInstalledApps().then((apps) async {
      talker.debug('loaded apps size: ${apps.length}');
      final sortedPackageName = await compute((appNames) {
        final letters = appNames.map((e) {
          var letter = PinyinHelper.getPinyinE(e.value).toLowerCase();
          if (letter.isEmpty) {
            letter = e.value.toLowerCase();
          }
          // talker.debug('name: ${e.value}, letter: $letter');
          return letter;
        }).toList();
        return (appNames.asMap().entries.toList()
              ..sort((MapEntry<int, MapEntry<String, String>> a,
                      MapEntry<int, MapEntry<String, String>> b) =>
                  letters[a.key].compareTo(letters[b.key])))
            .map((e) => e.value.key)
            .toList();
      }, apps.map((e) => MapEntry(e.packageName, e.appName)).toList());
      if (mounted) {
        setState(() {
          sortedPackageNames = sortedPackageName;
          originSortPackageNames = sortedPackageName;
          package2AppMap = apps
              .asMap()
              .map((key, value) => MapEntry(value.packageName, value));
          package2AppIcon = apps.asMap().map(
              (key, value) => MapEntry(value.packageName, AppIcon(app: value)));
        });
      }
    });
  }

  Widget createSearchBar() {
    return SearchBox(onSearch: (keyword) {
      if (keyword.isEmpty) {
        setState(() {
          sortedPackageNames = originSortPackageNames;
        });
        return;
      }
      List<String> searchResult = [];

      List<String> searchKeyList = keyword.toLowerCase().split(",");
      package2AppMap.forEach((key, value) {
        for (var searchKey in searchKeyList) {
          if (fuzzySearch((key + value.appName).toLowerCase(), searchKey)) {
            searchResult.add(value.packageName);
            break;
          }
        }
      });
      setState(() {
        sortedPackageNames = searchResult;
      });
    });
  }

  bool fuzzySearch(String content, String key) {
    var i = 0;
    var j = 0;
    while (i < content.length && j < key.length) {
      if (content[i] == key[j]) {
        j++;
      }
      i++;
    }
    return j == key.length;
  }
}

typedef OnChecked = void Function(bool checked);

class AppItem extends StatefulWidget {
  final Application application;
  final AppIcon? icon;
  final OnChecked onChecked;
  late final ValueNotifier<bool> _checked = ValueNotifier<bool>(false);

  AppItem(
      {super.key,
      required this.application,
      required bool checked,
      required this.onChecked,
      AppIcon? this.icon}) {
    _checked.value = checked;
  }

  @override
  State<StatefulWidget> createState() => AppItemState();
}

class AppItemState extends State<AppItem> {
  Application get application => widget.application;

  OnChecked get onChecked => widget.onChecked;

  ValueNotifier<bool> get _checked => widget._checked;

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
                image: widget.icon ?? AppIcon(app: application),
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
                      style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Theme.of(context).flixColors.text.primary)
                          .fix(),
                    ),
                    Text(
                      application.packageName,
                      style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color:
                                  Theme.of(context).flixColors.text.secondary)
                          .fix(),
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
