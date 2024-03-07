import 'package:flix/presentation/widgets/blur_appbar.dart';
import 'package:flutter/material.dart';

class NavigationScaffold extends StatelessWidget {
  final bool showBackButton;
  final String title;
  final bool Function()? onBackButtonPressed;
  final Widget Function(EdgeInsets padding) builder;

  const NavigationScaffold(
      {super.key,
      this.showBackButton = true,
      required this.title,
      this.onBackButtonPressed,
      required this.builder});

  @override
  Widget build(BuildContext context) {
    final Widget? backButton;
    if (showBackButton) {
      backButton = GestureDetector(
        onTap: () {
          if (onBackButtonPressed == null || onBackButtonPressed?.call() == false) {
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
      backButton = null;
    }
    final appBar = AppBar(
      leading: backButton,
      centerTitle: true,
      title: Text(title),
      titleTextStyle: const TextStyle(
          color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500),
      backgroundColor: const Color.fromRGBO(247, 247, 247, 0.8),
      surfaceTintColor: const Color.fromRGBO(247, 247, 247, 0.8),
    );
    final appBarHeight =
        appBar.preferredSize.height + MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: const Color.fromRGBO(247, 247, 247, 1),
      extendBodyBehindAppBar: true,
      appBar: BlurAppBar(
        appBar: appBar,
      ),
      body: builder(EdgeInsets.only(top: appBarHeight)),
    );
  }
}
