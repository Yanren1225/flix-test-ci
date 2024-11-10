import 'package:flix/domain/device/device_profile_repo.dart';
import 'package:flix/main.dart';
import 'package:flix/presentation/widgets/flix_bottom_sheet.dart';
import 'package:flix/presentation/widgets/flix_toast.dart';
import 'package:flix/theme/theme_extensions.dart';
import 'package:flix/utils/text/text_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../l10n/l10n.dart';
import '../../../l10n/lang_config.dart';

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flix/presentation/widgets/flix_bottom_sheet.dart';
import 'package:flix/presentation/widgets/flix_toast.dart';
import 'package:flix/theme/theme_extensions.dart';

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:flix/presentation/widgets/flix_bottom_sheet.dart';
import 'package:flix/presentation/widgets/flix_toast.dart';
import 'package:flix/theme/theme_extensions.dart';

import 'package:flutter/material.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

class HotkeyBottomSheet extends StatefulWidget {
  final Function(HotKey) onHotKeySelected;

  const HotkeyBottomSheet({super.key, required this.onHotKeySelected});

  @override
  State<StatefulWidget> createState() {
    return _HotkeyBottomSheetState();
  }
}

class _HotkeyBottomSheetState extends State<HotkeyBottomSheet> {
  HotKey? _hotKey;
  String _hotKeyDisplay = "按下快捷键组合"; 

  @override
  Widget build(BuildContext context) {
    return FlixBottomSheet(
      title: "设置快捷键",
      buttonText: "确定",
      onClickFuture: () async {
        if (_hotKey != null && !_hotKeyDisplay.contains("Unknown")) {
          widget.onHotKeySelected(_hotKey!); 
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            HotKeyRecorder(
              onHotKeyRecorded: (hotKey) {
                setState(() {
                  _hotKey = hotKey;
                  _hotKeyDisplay = _formatHotKey(hotKey);
                });
              },
            ),
            const SizedBox(height: 16),
            Text(
              _hotKeyDisplay,
              style: TextStyle(
                color: Theme.of(context).flixColors.text.primary,
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

 
  String _formatHotKey(HotKey hotKey) {
    final modifiers = hotKey.modifiers?.map((modifier) {
      switch (modifier) {
        case HotKeyModifier.alt:
          return "Alt";
        case HotKeyModifier.control:
          return "Ctrl";
        case HotKeyModifier.shift:
          return "Shift";
        case HotKeyModifier.meta:
          return "Meta";
        default:
          return "";
      }
    }).join(" + ");

    final key = _getKeyLabel(hotKey.key);
    return "$modifiers + $key";
  }

 
  String _getKeyLabel(KeyboardKey key) {
    if (key is PhysicalKeyboardKey) {
      switch (key) {
        case PhysicalKeyboardKey.keyA:
          return "A";
        case PhysicalKeyboardKey.keyB:
          return "B";
        case PhysicalKeyboardKey.keyC:
          return "C";
        case PhysicalKeyboardKey.keyD:
          return "D";
        case PhysicalKeyboardKey.keyE:
          return "E";
        case PhysicalKeyboardKey.keyF:
          return "F";
        case PhysicalKeyboardKey.keyG:
          return "G";
        case PhysicalKeyboardKey.keyH:
          return "H";
        case PhysicalKeyboardKey.keyI:
          return "I";
        case PhysicalKeyboardKey.keyJ:
          return "J";
        case PhysicalKeyboardKey.keyK:
          return "K";
        case PhysicalKeyboardKey.keyL:
          return "L";
        case PhysicalKeyboardKey.keyM:
          return "M";
        case PhysicalKeyboardKey.keyN:
          return "N";
        case PhysicalKeyboardKey.keyO:
          return "O";
        case PhysicalKeyboardKey.keyP:
          return "P";
        case PhysicalKeyboardKey.keyQ:
          return "Q";
        case PhysicalKeyboardKey.keyR:
          return "R";
        case PhysicalKeyboardKey.keyS:
          return "S";
        case PhysicalKeyboardKey.keyT:
          return "T";
        case PhysicalKeyboardKey.keyU:
          return "U";
        case PhysicalKeyboardKey.keyV:
          return "V";
        case PhysicalKeyboardKey.keyW:
          return "W";
        case PhysicalKeyboardKey.keyX:
          return "X";
        case PhysicalKeyboardKey.keyY:
          return "Y";
        case PhysicalKeyboardKey.keyZ:
          return "Z";
        case PhysicalKeyboardKey.digit0:
          return "0";
        case PhysicalKeyboardKey.digit1:
          return "1";
        case PhysicalKeyboardKey.digit2:
          return "2";
        case PhysicalKeyboardKey.digit3:
          return "3";
        case PhysicalKeyboardKey.digit4:
          return "4";
        case PhysicalKeyboardKey.digit5:
          return "5";
        case PhysicalKeyboardKey.digit6:
          return "6";
        case PhysicalKeyboardKey.digit7:
          return "7";
        case PhysicalKeyboardKey.digit8:
          return "8";
        case PhysicalKeyboardKey.digit9:
          return "9";
        default:
          return "Unknown";
      }
    }
    return "Unknown";
  }
}
