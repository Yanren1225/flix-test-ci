import 'package:flix/theme/theme_extensions.dart';
import 'package:flix/presentation/basic/corner/flix_decoration.dart';
import 'package:flix/utils/text/text_extension.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';

class FlixToast {
  FlixToast.privateConstructor();

  FlixToast.withContext(BuildContext context) {
    init(context);
  }

  static final FlixToast instance = FlixToast.privateConstructor();

  late FToast _fToast;

  void init(BuildContext context) {
    _fToast = FToast();
    _fToast.init(context);
  }

  void info(String message) {
    _fToast.showToast(
      child: _body('ic_info', message),
      gravity: ToastGravity.TOP,
      toastDuration: const Duration(seconds: 2),
    );
  }

  void alert(String message) {
    _fToast.showToast(
      child: _body('ic_alert', message),
      gravity: ToastGravity.TOP,
      toastDuration: const Duration(seconds: 2),
    );
  }

  Container _body(String icon, String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 17.0),
      decoration: FlixDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Theme.of(_fToast.context!).flixColors.background.primary,
        boxShadow: [
        BoxShadow(
          color: Theme.of(_fToast.context!).flixColors.text.primary.withOpacity(0.025), 
          offset: const Offset(0, -3), 
          blurRadius: 6,
        ),
        BoxShadow(
          color: Theme.of(_fToast.context!).flixColors.text.primary.withOpacity(0.025), 
          offset: const Offset(0, 8), 
          blurRadius: 8,
        ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: SvgPicture.asset('assets/images/$icon.svg'),
          ),
          const SizedBox(
            width: 10.0,
          ),
          Text(
            message,
            style: TextStyle(
              color: Theme.of(_fToast.context!).flixColors.text.primary,
              fontSize: 14.0,
              fontWeight: FontWeight.w400,
            ).fix(),
          ),
        ],
      ),
    );
  }
}

final flixToast = FlixToast.instance;
