import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AcceptMediaWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.333333,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset('assets/images/ic_receive.svg'),
          const SizedBox(height: 6,),
          const Text('点击接收',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.normal))
        ],
      ),
    );
  }

}