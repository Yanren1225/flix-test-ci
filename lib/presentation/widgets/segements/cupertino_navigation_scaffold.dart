import 'package:easy_refresh/easy_refresh.dart';
import 'package:flix/network/multicast_client_provider.dart';
import 'package:flix/presentation/basic/corner/flix_decoration.dart';
import 'package:flix/presentation/widgets/segements/custom_sliver_header.dart';
import 'package:flix/presentation/widgets/super_title.dart';
import 'package:flix/theme/theme_extensions.dart';
import 'package:flix/utils/text/text_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sliver_tools/sliver_tools.dart';

class CupertinoNavigationScaffold extends StatefulWidget {
  final bool showBack;
  final String title;
  final Widget child;
  final bool isSliverChild;
  final double padding;
  final bool enableRefresh;

  const CupertinoNavigationScaffold(
      {super.key,
      required this.title,
      required this.child,
      required this.isSliverChild,
      this.padding = 10,
      this.enableRefresh = false,
      this.showBack = false});

  @override
  State<StatefulWidget> createState() {
    return CupertinoNavigationScalffoldState();
  }
}

class CupertinoNavigationScalffoldState
    extends State<CupertinoNavigationScaffold> {
  bool get showBack => widget.showBack;

  String get title => widget.title;

  Widget get child => widget.child;

  bool get isSliverChild => widget.isSliverChild;

  double get padding => widget.padding;
  var isFolded = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    final deviceProvider = MultiCastClientProvider.of(context, listen: true);
    final slivers = [
      CupertinoSliverNavigationBar(
          transitionBetweenRoutes: false,
          automaticallyImplyLeading: false,
          leading: showBack
              ? Material(
                  color: Theme.of(context).flixColors.background.secondary,
                  child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: SizedBox(
                          height: 56,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: SvgPicture.asset('assets/images/ic_back.svg',
                                width: 24,
                                height: 24,
                                colorFilter: ColorFilter.mode(
                                    Theme.of(context).flixColors.text.primary,
                                    BlendMode.srcIn)),
                          ))),
                )
              : null,
          largeTitle: SuperTitle(title: title),
          middle: Text(title,
              style: TextStyle(
                      color: Theme.of(context).flixColors.text.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.w500)
                  .fix()),
          alwaysShowMiddle: false,
          border: null,
          backgroundColor: Theme.of(context).flixColors.background.secondary),
      SliverPadding(
          padding: EdgeInsets.only(top: padding),
          sliver: isSliverChild
              ? child
              : SliverFillRemaining(
                  child: Material(
                    color: Theme.of(context).flixColors.background.secondary,
                    child: child,
                  ),
                )),
      // SliverFillRemaining()
    ];
    return CupertinoPageScaffold(
        backgroundColor: Theme.of(context).flixColors.background.secondary,
        child: widget.enableRefresh
            ? EasyRefresh(
                callRefreshOverOffset: 1,
                onRefresh: () async {
                  deviceProvider.clearDevices();
                  deviceProvider.startScan();
                  await Future.delayed(const Duration(seconds: 2));
                  return IndicatorResult.success;
                },
                header:
                    const MaterialHeader(color: Color.fromRGBO(0, 122, 255, 1)),
                child: CustomScrollView(
                  slivers: slivers,
                ),
              )
            : CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(
                        decelerationRate: ScrollDecelerationRate.fast)),
                slivers: slivers,
              ));
  }
}
