import 'dart:io';

import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/presentation/widgets/blur_appbar.dart';
import 'package:flix/presentation/widgets/toolbar.dart';
import 'package:flix/theme/theme_extensions.dart';
import 'package:flix/utils/text/text_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NavigationScaffold extends StatelessWidget {
  final bool showBackButton;
  final String title;
  final bool Function()? onBackButtonPressed;
  final Widget Function(EdgeInsets padding) builder;
  final bool isEditing;
  final bool toolbarCoverBody;

  final String? editTitle;
  final VoidCallback? onClearThirdWidget;
  final VoidCallback? onExitEditing;

  const NavigationScaffold(
      {super.key,
      required this.showBackButton,
      required this.title,
      this.isEditing = false,
      this.toolbarCoverBody = false,
      this.editTitle,
      this.onBackButtonPressed,
      this.onClearThirdWidget, 
      this.onExitEditing,
      required this.builder});

  @override
  Widget build(BuildContext context) {
    final Widget? leading;
    Toolbar toolbar = Toolbar(showBack: showBackButton, title: title);
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



    if (showBackButton) {
    var toolbarHeight = 124.0;
    double stateBarHeight = MediaQuery.of(context).padding.top;
    final Widget appBar = AnimatedCrossFade(
        firstChild: Container(
          height: toolbarHeight,
          padding: const EdgeInsets.only(left: 16),
          child: toolbar,
        ),
        secondChild: editingAppBar,
        crossFadeState:
            isEditing ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        duration: const Duration(milliseconds: 100));

    double appBarHeight = toolbarHeight;
    talker.debug("stateBarHeight = $stateBarHeight");
    return Scaffold(
      backgroundColor: Theme.of(context).flixColors.background.secondary,
      extendBodyBehindAppBar: toolbarCoverBody,
      //BlurAppBar会自动+stateBarHeight,所以toolbarCoverBody是，padding需要加上stateBarHeight
      appBar: BlurAppBar(
        appBar: Align(alignment: Alignment.bottomCenter, child: appBar),
        cpreferredSize: Size(double.infinity, appBarHeight),
      ),
      body: builder(EdgeInsets.only(
          top: toolbarCoverBody ? appBarHeight + stateBarHeight : 0)),
    );}else{
      leading = GestureDetector(
        onTap: () {
          onClearThirdWidget?.call();
        },
       child: Padding(
   padding: EdgeInsets.only(top: Platform.isWindows || Platform.isMacOS || Platform.isLinux ? 20.0 : 0.0), 
    child: Icon(
      Icons.arrow_back,
      color: Theme.of(context).flixColors.text.primary,
      size: 22,
    ),
  ),
);
      final normalAppBar = AppBar(
      leading: leading,
      centerTitle: true,
      title: Padding(
  padding: EdgeInsets.only(top: Platform.isWindows || Platform.isMacOS || Platform.isLinux ? 20.0 : 0.0), 
  child: Text(
    title,
  ),
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
      extendBodyBehindAppBar: false,
      appBar: BlurAppBar(
        appBar: appBar,
        cpreferredSize: normalAppBar.preferredSize,
      ),
      body: builder(EdgeInsets.only(top: appBarHeight)),
    );
    }
  }
}
