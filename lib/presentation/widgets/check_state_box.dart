import 'package:flix/theme/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CheckStateBox extends StatelessWidget {
  final bool checked;
  const CheckStateBox({super.key, required this.checked});

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      crossFadeState:
          checked ? CrossFadeState.showFirst : CrossFadeState.showSecond,
      firstChild: SvgPicture.asset(
        'assets/images/checked.svg',
        width: 20,
        height: 20,
      ),
      secondChild: Container(
        decoration: BoxDecoration(
            color: Theme.of(context).flixColors.text.tertiary,
            borderRadius: BorderRadius.circular(100)),
        width: 20,
        height: 20,
      ),
      duration: const Duration(milliseconds: 300),
    );
  }
}
