import 'package:flix/presentation/widgets/blur_appbar.dart';
import 'package:flix/theme/theme_extensions.dart';
import 'package:flix/utils/meida/media_utils.dart';
import 'package:flix/utils/text/text_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NavigationAppbarScaffold extends StatelessWidget {
  final bool showBackButton;
  final String title;
  final bool Function()? onBackButtonPressed;
  final Widget Function(EdgeInsets padding) builder;
  final bool isEditing;
  final String? editTitle;
  final VoidCallback? onExitEditing;
  final VoidCallback? onClearThirdWidget;

  const NavigationAppbarScaffold(
      {super.key,
      this.showBackButton = true,
      required this.title,
      this.isEditing = false,
      this.editTitle,
      this.onBackButtonPressed,
      this.onExitEditing,
      this.onClearThirdWidget, 
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
                colorFilter: ColorFilter.mode(
                    Theme.of(context).flixColors.text.primary, BlendMode.srcIn),
              )),
        ),
      ),
      leadingWidth: 40,
      centerTitle: false,
      title: Text(editTitle ?? '',
          style: TextStyle(
                  color: Theme.of(context).flixColors.text.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.w500)
              .fix()),
      backgroundColor: Theme.of(context).flixColors.background.secondary,
      surfaceTintColor: Theme.of(context).flixColors.background.secondary,
      titleTextStyle: TextStyle(
              color: Theme.of(context).flixColors.text.primary,
              fontSize: 18,
              fontWeight: FontWeight.w500)
          .fix(),
      titleSpacing: 6,
    );

   
  leading = GestureDetector(
    onTap: () {
      if (isOverMediumWidth(context)) {
        onClearThirdWidget?.call();
      } else {
        if (onBackButtonPressed == null || onBackButtonPressed?.call() == false) {
          Navigator.pop(context);
        }
      }
    },
    child: Icon(
      Icons.arrow_back_ios,
      color: Theme.of(context).flixColors.text.primary,
      size: 20,
    ),
  );



    final normalAppBar = AppBar(
      leading: leading,
      centerTitle: true,
      title: Text(
        title,
      ),
      titleTextStyle: TextStyle(
              color: Theme.of(context).flixColors.text.primary,
              fontSize: 18,
              fontWeight: FontWeight.w500)
          .fix(),
      backgroundColor: Theme.of(context).flixColors.background.secondary,
      surfaceTintColor: Theme.of(context).flixColors.background.secondary,
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
      backgroundColor: Theme.of(context).flixColors.background.secondary,
      extendBodyBehindAppBar: true,
      appBar: BlurAppBar(
        appBar: appBar,
        cpreferredSize: normalAppBar.preferredSize,
      ),
      body: builder(EdgeInsets.only(top: appBarHeight)),
    );
  }
}
