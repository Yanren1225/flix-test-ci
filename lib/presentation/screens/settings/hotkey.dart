import 'dart:convert'; 
import 'dart:io';

import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/domain/settings/settings_repo.dart';
import 'package:flix/presentation/basic/corner/flix_clip_r_rect.dart';
import 'package:flix/presentation/basic/corner/flix_decoration.dart';
import 'package:flix/presentation/screens/main_screen.dart';
import 'package:flix/presentation/screens/settings/Hotkeyset.dart';
import 'package:flix/presentation/screens/settings/confirm_clean_cache_bottom_sheet.dart';
import 'package:flix/presentation/widgets/flix_toast.dart';
import 'package:flix/presentation/widgets/helps/qa.dart';
import 'package:flix/presentation/widgets/hotkeyprovider.dart';
import 'package:flix/presentation/widgets/segements/navigation_scaffold.dart';
import 'package:flix/presentation/widgets/settings/clickable_item.dart';
import 'package:flix/presentation/widgets/settings/option_item.dart';
import 'package:flix/presentation/widgets/settings/settings_item_wrapper.dart';
import 'package:flix/presentation/widgets/settings/switchable_item.dart';
import 'package:flix/theme/theme_extensions.dart';
import 'package:flix/utils/file/file_helper.dart';
import 'package:flix/utils/pay/pay_util.dart';
import 'package:flix/utils/text/text_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../../../l10n/l10n.dart';

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';



class HotkeyScreen extends StatefulWidget {
  final bool showBack;

  HotkeyScreen({super.key, required this.showBack});

  @override
  State<StatefulWidget> createState() => HotkeyScreenState();
}

class HotkeyScreenState extends State<HotkeyScreen> {
  HotKey _hotKey = HotKey(
    key: PhysicalKeyboardKey.keyF,
    modifiers: [HotKeyModifier.alt],
    scope: HotKeyScope.system,
  );

  String _hotKeyDisplay = ""; 

  @override
  void initState() {
    super.initState();
    _loadHotKey();
  }

  Future<void> _loadHotKey() async {
    final prefs = await SharedPreferences.getInstance();
    final hotKeyString = prefs.getString('hotkey');
    if (hotKeyString == null) {
      await prefs.setString('hotkey', jsonEncode(_hotKey.toJson()));
      setState(() {
        _hotKeyDisplay = _formatHotKey(_hotKey);
      });
    } else {
      final hotKeyMap = jsonDecode(hotKeyString) as Map<String, dynamic>;
      setState(() {
        _hotKey = HotKey.fromJson(hotKeyMap);
        _hotKeyDisplay = _formatHotKey(_hotKey);
      });
    }
  }

 Future<void> _updateHotKey(HotKey newHotKey) async {
   setState(() {
      _hotKey = newHotKey;
      _hotKeyDisplay = _formatHotKey(newHotKey);
    });
  final hotKeyProvider = Provider.of<HotKeyProvider>(context, listen: false);
  hotKeyProvider.updateHotKey(newHotKey);

  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('hotkey', jsonEncode(newHotKey.toJson()));
  FlixToast.instance.info("快捷键已更新");
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

  @override
  Widget build(BuildContext context) {
    return NavigationScaffold(
      title: '快捷键',
      onClearThirdWidget: () {
        Provider.of<BackProvider>(context, listen: false).backMethod();
      },
      showBackButton: widget.showBack,
      builder: (EdgeInsets padding) {
        return Container(
          margin: const EdgeInsets.only(top: 6),
          width: double.infinity,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 16, right: 16, bottom: 0, top: 4),
                      child: ClickableItem(
                        label: '显示/隐藏主界面',
                        tail: _hotKeyDisplay,
                        topRadius: true,
                        bottomRadius: true,
                        onClick: () {
                          showCupertinoModalPopup(
                            context: context,
                            builder: (context) {
                              return HotkeyBottomSheet(
                                onHotKeySelected: (newHotKey) {
                                  _updateHotKey(newHotKey); 
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
