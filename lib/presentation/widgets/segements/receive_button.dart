
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ReceiveButton extends StatelessWidget {
  const ReceiveButton({
    super.key,
    required this.onTap,
  });

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: IconButton(
        onPressed: onTap,
        iconSize: 20,
        padding: EdgeInsets.zero,
        icon: SvgPicture.asset(
          'assets/images/ic_receive.svg',
        ),
      ),
    );
  }
}