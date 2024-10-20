
import 'package:flix/presentation/style/flix_text_style.dart';
import 'package:flix/theme/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MenuItem extends StatelessWidget {
  const MenuItem({
    Key? key,
    required this.icon,
    required this.lable,
    required this.onTap
  }) : super(key: key);

  final String icon;
  final String lable;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 170,
        height: 50,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              SvgPicture.asset(
                icon,
                colorFilter: ColorFilter.mode(
                    Theme.of(context).flixColors.text.primary, BlendMode.srcIn),
              ),
              const SizedBox(width: 10),
              Text(
                lable,
                style: context.title(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}