import 'package:flix/presentation/basic/corner/flix_decoration.dart';
import 'package:flix/utils/text/text_extension.dart';
import 'package:flix/domain/device/device_manager.dart';
import 'package:flix/domain/device/device_profile_repo.dart';

import 'package:flix/presentation/widgets/flix_bottom_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NameEditBottomSheet extends StatefulWidget {
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
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: FlixBottomSheet(
        title: '输入本机名称',
        buttonText: '完成',
        onClick: () async {
          _rename(name);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: CupertinoTextField(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 15, bottom: 15),
            controller: _controller,
            style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.normal)
                .fix(),
            keyboardType: TextInputType.text,
            minLines: null,
            maxLines: 1,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Color.fromRGBO(247, 247, 247, 1),
            ),
            cursorColor: Colors.black,
            onChanged: (value) {
              name = value;
            },
            onSubmitted: (value) {
              Navigator.of(context).pop();
              _rename(value);
            },
          ),
        ),
      ),
    );
  }

  void _rename(String name) {
    DeviceProfileRepo.instance.renameDevice(name);
  }
}
