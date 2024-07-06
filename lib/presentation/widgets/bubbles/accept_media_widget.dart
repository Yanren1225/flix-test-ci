import 'package:flix/theme/theme_extensions.dart';
import 'package:flix/utils/text/text_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AcceptMediaWidget extends StatelessWidget {
  const AcceptMediaWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.333333,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset('assets/images/ic_receive.svg'),
          const SizedBox(
            height: 6,
          ),
          Text('点击接收',
              style: TextStyle(
                      color: Theme.of(context).flixColors.text.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.normal)
                  .fix())
        ],
      ),
    );
  }
}
