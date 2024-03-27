import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flix/presentation/widgets/blur_appbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NavigationScaffold extends StatelessWidget {
  final bool showBackButton;
  final String title;
  final bool Function()? onBackButtonPressed;
  final Widget Function(EdgeInsets padding) builder;
  final bool isEditing;
  final String? editTitle;
  final VoidCallback? onExitEditing;

  const NavigationScaffold(
      {super.key,
      this.showBackButton = true,
      required this.title,
      this.isEditing = false,
      this.editTitle,
      this.onBackButtonPressed,
      this.onExitEditing,
      required this.builder});

  @override
  Widget build(BuildContext context) {
    final Widget? leading;
    final editingAppBar = AppBar(
      leading: GestureDetector(
        onTap: () {
          onExitEditing?.call();
        },
        child: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: SizedBox(
              width: 24,
              height: 24,
              child: SvgPicture.asset(
                'assets/images/ic_exit.svg',
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(Colors.black, BlendMode.srcIn),
              )),
        ),
      ),
      leadingWidth: 40,
      centerTitle: false,
      title: Text(editTitle ?? '',
          style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w500)
              .useSystemChineseFont()),
      backgroundColor: const Color.fromRGBO(247, 247, 247, 0.8),
      surfaceTintColor: const Color.fromRGBO(247, 247, 247, 0.8),
      titleTextStyle: const TextStyle(
          color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500),
      titleSpacing: 6,
    );

    if (showBackButton) {
      leading = GestureDetector(
        onTap: () {
          if (onBackButtonPressed == null ||
              onBackButtonPressed?.call() == false) {
            Navigator.pop(context);
          }
        },
        child: const Icon(
          Icons.arrow_back_ios,
          color: Colors.black,
          size: 20,
        ),
      );
    } else {
      leading = null;
    }

    final normalAppBar = AppBar(
      leading: leading,
      centerTitle: true,
      title: Text(
        title,
      ),
      titleTextStyle: const TextStyle(
              color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500)
          .useSystemChineseFont(),
      backgroundColor: const Color.fromRGBO(247, 247, 247, 0.8),
      surfaceTintColor: const Color.fromRGBO(247, 247, 247, 0.8),
    );
    final Widget appBar = AnimatedCrossFade(
        firstChild: normalAppBar,
        secondChild: editingAppBar,
        crossFadeState:
            isEditing ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        duration: const Duration(milliseconds: 100));

    final appBarHeight =
        normalAppBar.preferredSize.height + MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: const Color.fromRGBO(247, 247, 247, 1),
      extendBodyBehindAppBar: true,
      appBar: BlurAppBar(
        appBar: appBar,
        cpreferredSize: normalAppBar.preferredSize,
      ),
      body: builder(EdgeInsets.only(top: appBarHeight)),
    );
  }
}
