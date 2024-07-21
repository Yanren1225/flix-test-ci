import 'package:flix/domain/device/device_profile_repo.dart';
import 'package:flix/presentation/widgets/flix_bottom_sheet.dart';
import 'package:flix/theme/theme_extensions.dart';
import 'package:flix/utils/text/text_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NameEditBottomSheet extends StatefulWidget {
  const NameEditBottomSheet({super.key});

  @override
  State<StatefulWidget> createState() {
    return NameEditBottomSheetState();
  }
}

class NameEditBottomSheetState extends State<NameEditBottomSheet> {
  var name = DeviceProfileRepo.instance.deviceName;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: name);
  }

  @override
  Widget build(BuildContext context) {
    return
      FlixBottomSheet(
        title: '输入本机名称',
        buttonText: '完成',
        onClickFuture: () async {
          _rename(name);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: CupertinoTextField(
            padding:
                const EdgeInsets.only(left: 16, right: 16, top: 15, bottom: 15),
            controller: _controller,
            style: TextStyle(
                    color: Theme.of(context).flixColors.text.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.normal)
                .fix(),
            keyboardType: TextInputType.text,
            minLines: null,
            maxLines: 1,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Theme.of(context).flixColors.background.secondary,
            ),
            cursorColor: Theme.of(context).flixColors.text.primary,
            onChanged: (value) {
              name = value;
            },
            onSubmitted: (value) {
              Navigator.of(context).pop();
              _rename(value);
            },
          ),
        ),
    );
  }

  void _rename(String name) {
    DeviceProfileRepo.instance.renameDevice(name);
  }
}
