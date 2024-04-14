import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';

class FlixToast {
  FlixToast.privateConstructor();

  static final FlixToast instance = FlixToast.privateConstructor();

  late FToast _fToast;

  void init(BuildContext context) {
    _fToast = FToast();
    _fToast.init(context);
  }

  void alert(String message) {
    _fToast.showToast(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 17.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25.0),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 4,
              offset: const Offset(2, 4),
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
              child: SvgPicture.asset('assets/images/ic_alert.svg'),
            ),
            const SizedBox(
              width: 10.0,
            ),
            Text(
              message,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14.0,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
      gravity: ToastGravity.TOP,
      toastDuration: const Duration(seconds: 2),
    );


  }
}

final flixToast = FlixToast.instance;