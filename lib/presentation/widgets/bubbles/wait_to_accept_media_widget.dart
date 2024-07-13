
import 'package:flix/utils/text/text_extension.dart';
import 'package:flutter/material.dart';

class WaitToAcceptMediaWidget extends StatelessWidget {
  const WaitToAcceptMediaWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              backgroundColor: Colors.transparent,
              color: Colors.white,
              strokeWidth: 2.0,
            )),
        const SizedBox(
          height: 8,
        ),
        Text(
          '等待对方确认',
          style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.normal).fix(),
        )
      ],
    );
  }
}
