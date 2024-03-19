import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flix/network/multicast_client_provider.dart';
import 'package:flix/presentation/widgets/segements/custom_sliver_header.dart';
import 'package:flix/presentation/widgets/super_title.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sliver_tools/sliver_tools.dart';

class CupertinoNavigationScaffold extends StatefulWidget {
  final String title;
  final Widget child;
  final bool isSliverChild;
  final double padding;
  final bool enableRefresh;

  CupertinoNavigationScaffold(
      {super.key,
      required this.title,
      required this.child,
      required this.isSliverChild,
      required this.padding,
      required this.enableRefresh});

  @override
  State<StatefulWidget> createState() {
    return CupertinoNavigationScalffoldState();
  }
}

class CupertinoNavigationScalffoldState
    extends State<CupertinoNavigationScaffold> {
  String get title => widget.title;

  Widget get child => widget.child;

  bool get isSliverChild => widget.isSliverChild;

  double get padding => widget.padding;
  var isFolded = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    final deviceProvider = MultiCastClientProvider.of(context, listen: true);
    final slivers = [
      SliverPinnedHeader(
          child: DecoratedBox(
            decoration: BoxDecoration(
                color: const Color.fromARGB(255, 247, 247, 247)),
            child: SafeArea(
              child: Center(
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
            ),
          )),

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
      SliverPadding(
          padding: EdgeInsets.only(top: padding),
          sliver: isSliverChild
              ? child
              : SliverFillRemaining(
            child: child,
          )),
      // SliverFillRemaining()
    ];
    return CupertinoPageScaffold(
        // backgroundColor: Colors.transparent,
        backgroundColor: const Color.fromARGB(255, 247, 247, 247),
        child: widget.enableRefresh ? EasyRefresh(
          callRefreshOverOffset: 1,
          onRefresh: () async {
            deviceProvider.clearDevices();
            deviceProvider.startScan();
            await Future.delayed(Duration(seconds: 2));
            return IndicatorResult.success;
          },
          // header: const MaterialHeader(color: Color.fromRGBO(0, 122, 255, 1)),
          header: MaterialHeader(color: Colors.black),
          child: CustomScrollView(
            slivers: slivers,
          ),
        ) : CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(
                  decelerationRate: ScrollDecelerationRate.fast)),
          slivers: slivers,
        ));
  }
}
