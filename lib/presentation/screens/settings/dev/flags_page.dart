import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter95/flutter95.dart';

import '../../../../domain/dev/flag.dart';
import '../../../../domain/dev/flags.dart';

class FlagPage extends StatefulWidget {
  final void Function(BuildContext)? onClosePressed;

  const FlagPage({
    Key? key,
    this.onClosePressed,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => FlagPageState();
}

class FlagPageState extends State<FlagPage> {
  void _onChange() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    FlagRepo.instance.addListener(_onChange);
  }

  @override
  void dispose() {
    super.dispose();
    FlagRepo.instance.removeListener(_onChange);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold95(
      title: "Flags",
      onClosePressed: widget.onClosePressed,
      body: Expanded(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: ListView(
            children: [
              for (var flag in FlagRepo.instance.flags)
                _buildFlag(context, flag),
              Container(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Button95(
                            child: Container(
                              alignment: Alignment.center,
                              child: const Text("重置所有 Flags"),
                            ),
                            onTap: () {
                              for (var flag in FlagRepo.instance.flags) {
                                flag.value = flag.defaultValue;
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const Text(
                      "下划线表示未保存到 SharedPreferences, 斜体表示未使用默认值",
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildFlag(BuildContext context, Flag flag) {
  if (flag is BoolFlag) {
    return _buildBoolFlag(context, flag);
  } else if (flag is IntFlag) {
    return _buildIntFlag(context, flag);
  } else if (flag is StringFlag) {
    return _buildStringFlag(context, flag);
  } else {
    return Container();
  }
}

Widget _buildBoolFlag(BuildContext context, BoolFlag flag) {
  return Container(
    padding: const EdgeInsets.all(8),
    child: Column(
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () {
                flag.value = flag.defaultValue;
              },
              icon: const Icon(Icons.refresh),
            ),
            Expanded(
              child: Text(
                flag.name,
                style: Flutter95.textStyle.apply(
                  fontStyle:
                      flag.isDefault ? FontStyle.normal : FontStyle.italic,
                  decoration: flag.saveToSp
                      ? TextDecoration.none
                      : TextDecoration.underline,
                ),
              ),
            ),
            Expanded(
              child: Container(
                alignment: Alignment.centerRight,
                child: Checkbox95(
                  value: flag.value,
                  onChanged: (value) {
                    flag.value = value;
                  },
                ),
              ),
            ),
          ],
        ),
        flag.description != null
            ? SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 8),
                  child: Elevation95(
                    type: Elevation95Type.down,
                    child: Text(
                      flag.description ?? "",
                      style: Flutter95.textStyle.copyWith(
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              )
            : Container(),
        const Divider95(),
      ],
    ),
  );
}

Widget _buildIntFlag(BuildContext context, IntFlag flag) {
  return Container(
    padding: const EdgeInsets.all(8),
    child: Column(
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () {
                flag.value = flag.defaultValue;
              },
              icon: const Icon(Icons.refresh),
            ),
            Expanded(
              child: Text(
                flag.name,
                style: Flutter95.textStyle.apply(
                  fontStyle:
                      flag.isDefault ? FontStyle.normal : FontStyle.italic,
                  decoration: flag.saveToSp
                      ? TextDecoration.none
                      : TextDecoration.underline,
                ),
              ),
            ),
            Expanded(
              child: Container(
                alignment: Alignment.centerRight,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField95(
                        controller:
                            TextEditingController(text: flag.value.toString()),
                        multiline: false,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (newValue) {
                          flag.value =
                              int.tryParse(newValue) ?? flag.defaultValue;
                        },
                        onSubmitted: (newValue) {
                          flag.value =
                              int.tryParse(newValue) ?? flag.defaultValue;
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: flag.increment,
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: flag.decrement,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        flag.description != null
            ? SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 8),
                  child: Elevation95(
                    type: Elevation95Type.down,
                    child: Text(
                      flag.description ?? "",
                      style: Flutter95.textStyle.copyWith(
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              )
            : Container(),
        const Divider95(),
      ],
    ),
  );
}

Widget _buildStringFlag(BuildContext context, StringFlag flag) {
  return Container(
    padding: const EdgeInsets.all(8),
    child: Column(
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () {
                flag.value = flag.defaultValue;
              },
              icon: const Icon(Icons.refresh),
            ),
            Expanded(
              child: Text(
                flag.name,
                style: Flutter95.textStyle.apply(
                  fontStyle:
                      flag.isDefault ? FontStyle.normal : FontStyle.italic,
                  decoration: flag.saveToSp
                      ? TextDecoration.none
                      : TextDecoration.underline,
                ),
              ),
            ),
            Expanded(
              child: TextField95(
                controller: TextEditingController(text: flag.value),
                multiline: false,
                onChanged: (newValue) {
                  flag.value = newValue;
                },
                onSubmitted: (newValue) {
                  flag.value = newValue;
                },
              ),
            ),
          ],
        ),
        flag.description != null
            ? SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 8),
                  child: Elevation95(
                    type: Elevation95Type.down,
                    child: Text(
                      flag.description ?? "",
                      style: Flutter95.textStyle.copyWith(
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              )
            : Container(),
        const Divider95(),
      ],
    ),
  );
}
