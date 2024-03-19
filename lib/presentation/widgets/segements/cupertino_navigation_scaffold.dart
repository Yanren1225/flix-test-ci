import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flix/presentation/widgets/segements/custom_sliver_header.dart';
import 'package:flix/presentation/widgets/super_title.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CupertinoNavigationScaffold extends StatefulWidget {
  final String title;
  final Widget child;
  final bool isSliverChild;
  final double padding;

  CupertinoNavigationScaffold(
      {super.key,
      required this.title,
      required this.child,
      required this.isSliverChild,
      required this.padding});



  @override
  State<StatefulWidget> createState() {
    return CupertinoNavigationScalffoldState();
  }
}

class CupertinoNavigationScalffoldState extends State<CupertinoNavigationScaffold> {
  String get title => widget.title;
  Widget get child => widget.child;
  bool get isSliverChild => widget.isSliverChild;
  double get padding => widget.padding;
  var isFolded = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      // backgroundColor: Colors.transparent,
        backgroundColor: const Color.fromARGB(255, 247, 247, 247),
        child: Column(children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: ValueListenableBuilder<bool>(
                valueListenable: isFolded,
                builder: (context, value, child) {
                  return AnimatedOpacity(
                    opacity: value ? 1 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: child,
                  );
                },
                child: Text(title,
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w500)
                        .useSystemChineseFont()),
              ),
            ),
          ),
          Expanded(
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(
                      decelerationRate: ScrollDecelerationRate.fast)),
              slivers: [
                CustomSliverHeader(
                  lagerTitle: Padding(
                    padding: const EdgeInsets.only(top: 32, left: 20),
                    child: SuperTitle(title: title),
                  ),
                  onFolded: (_isFolded) {
                    if (_isFolded != isFolded.value) {
                      isFolded.value = _isFolded;
                    }
                  },
                ),
                // CupertinoSliverNavigationBar(
                //   largeTitle: SuperTitle(title: title),
                //
                //   alwaysShowMiddle: false,
                //   border: null,
                //   // padding: const EdgeInsetsDirectional.only(top: 42),
                //   backgroundColor: const Color.fromARGB(255, 247, 247, 247),
                //   // backgroundColor: Colors.transparent,
                //   middle: Text(title,
                //       style: const TextStyle(
                //               color: Colors.black,
                //               fontSize: 18,
                //               fontWeight: FontWeight.w500)
                //           .useSystemChineseFont()),
                // ),
                // SliverToBoxAdapter(child: SizedBox(height: padding,),),
                SliverPadding(padding: EdgeInsets.only(top: padding), sliver: isSliverChild
                    ? child
                    : SliverFillRemaining(
                  child: child,
                )),
                // SliverFillRemaining()
              ],
            ),
          ),
        ]));
  }
}
