import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flix/presentation/widgets/super_title.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CupertinoNavigationScaffold extends StatelessWidget {
  final String title;
  final Widget child;
  final bool isSliverChild;

  const CupertinoNavigationScaffold(
      {super.key,
      required this.title,
      required this.child,
      required this.isSliverChild});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      // backgroundColor: Colors.transparent,
      backgroundColor: const Color.fromARGB(255, 247, 247, 247),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(
                decelerationRate: ScrollDecelerationRate.fast)),
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: Padding(
              padding: const EdgeInsets.only(top: 32.0),
              child: SuperTitle(title: title),
            ),

            alwaysShowMiddle: false,
            border: null,
            // padding: const EdgeInsetsDirectional.only(top: 42),
            backgroundColor: const Color.fromARGB(255, 247, 247, 247),
            // backgroundColor: Colors.transparent,
            middle: Text(title,
                style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w500)
                    .useSystemChineseFont()),
          ),
          isSliverChild
              ? child
              : SliverFillRemaining(
                  child: child,
                ),
        ],
      ),
    );
  }
}
