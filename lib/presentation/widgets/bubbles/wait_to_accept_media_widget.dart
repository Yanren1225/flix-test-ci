
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class WaitToAcceptMediaWidget extends StatelessWidget {
  const WaitToAcceptMediaWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              backgroundColor: Colors.transparent,
              color: Colors.white,
              strokeWidth: 2.0,
            )),
        SizedBox(
          height: 8,
        ),
        Text(
          '等待对方确认',
          style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.normal),
        )
      ],
    );
  }
}
