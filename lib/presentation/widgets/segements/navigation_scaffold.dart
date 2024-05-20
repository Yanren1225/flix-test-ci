import 'package:flix/utils/text/text_extension.dart';
import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/presentation/widgets/blur_appbar.dart';
import 'package:flix/presentation/widgets/toolbar.dart';
import 'package:flutter/cupertino.dart';
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
  final VoidCallback? onExitEditing;

  const NavigationScaffold(
      {super.key,
      required this.showBackButton,
      required this.title,
      this.isEditing = false,
      this.toolbarCoverBody = false,
      this.editTitle,
      this.onBackButtonPressed,
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
              .fix()),
      backgroundColor: const Color.fromRGBO(242, 242, 242, 0.8),
      surfaceTintColor: const Color.fromRGBO(242, 242, 242, 0.8),
      titleTextStyle: const TextStyle(
              color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500)
          .fix(),
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
      title: toolbar,
      backgroundColor: const Color.fromRGBO(242, 242, 242, 0.8),
      surfaceTintColor: const Color.fromRGBO(242, 242, 242, 0.8),
    );

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
      backgroundColor: const Color.fromRGBO(242, 242, 242, 1),
      extendBodyBehindAppBar: toolbarCoverBody,
      //BlurAppBar会自动+stateBarHeight,所以toolbarCoverBody是，padding需要加上stateBarHeight
      appBar: BlurAppBar(
        appBar: Container(
            child: Align(alignment: Alignment.bottomCenter, child: appBar)),
        cpreferredSize: Size(double.infinity, appBarHeight),
      ),
      body: builder(EdgeInsets.only(top: toolbarCoverBody ? appBarHeight+stateBarHeight : 0)),
    );
  }
}
