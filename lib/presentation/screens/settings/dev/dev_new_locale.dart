import 'package:flix/domain/device/device_profile_repo.dart';
import 'package:flix/main.dart';
import 'package:flix/presentation/widgets/flix_bottom_sheet.dart';
import 'package:flix/presentation/widgets/flix_toast.dart';
import 'package:flix/theme/theme_extensions.dart';
import 'package:flix/utils/text/text_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../l10n/l10n.dart';
import '../../../../l10n/lang_config.dart';

class DevNewLocaleBottomSheet extends StatefulWidget {
  const DevNewLocaleBottomSheet({super.key});

  @override
  State<StatefulWidget> createState() {
    return NameEditBottomSheetState();
  }
}

class NameEditBottomSheetState extends State<DevNewLocaleBottomSheet> {
  var lang = "";
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: lang);
  }

  @override
  Widget build(BuildContext context) {
    lang = Localizations.localeOf(context).toString();
    return FlixBottomSheet(
      title: "修改语言",
      buttonText: "确定",
      onClickFuture: () async {
        _newlang(lang);
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
            lang = value;
          },
          onSubmitted: (value) {
            Navigator.of(context).pop();
            _newlang(value);
          },
        ),
      ),
    );
  }

  void _newlang(String lang) async {
    var newLocale = Locale(lang);
    var newLangAvailable = false;
    for (var locale in S.delegate.supportedLocales) {
      if (locale.toString() == lang) {
        newLangAvailable = true;
        break;
      }
    }
    if (newLangAvailable) {
      LangConfig.instance.setLang(newLocale);
      FlixToast.instance.info("修改成功");
    } else {
      FlixToast.instance.alert("语言不可用");
    }
  }
}
