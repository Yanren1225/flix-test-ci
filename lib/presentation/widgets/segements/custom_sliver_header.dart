import 'dart:math';

import 'package:flix/domain/log/flix_log.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';

class CustomSliverHeader extends StatelessWidget {
  final Widget lagerTitle;
  final Function(bool isFolded) onFolded;

  const CustomSliverHeader(
      {super.key, required this.lagerTitle, required this.onFolded});

  @override
  Widget build(BuildContext context) {
    return _LargeTitle(
      child: lagerTitle,
      onFolded: onFolded,
    );
  }
}

class _LargeTitle extends SingleChildRenderObjectWidget {
  final Function(bool isFolded) onFolded;

  _LargeTitle({super.key, required super.child, required this.onFolded});

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _LargeTitleAdapter(onFolded);
  }
}

class _LargeTitleAdapter extends RenderSliverSingleBoxAdapter {
  final hei = 76.0;
  var _isFolded = false;
  final Function(bool isFolded) onFolded;

  _LargeTitleAdapter(this.onFolded);

  @override
  void performLayout() {
    // 滑动距离大于_visibleExtent时则表示子节点已经在屏幕之外了
    if (child == null) {
      _setFolded(true);
      geometry = SliverGeometry(scrollExtent: hei);
      return;
    }

    // talker.verbose(
    //     'scrollOffset ${constraints.scrollOffset}, ${constraints.overlap}');

    if (constraints.scrollOffset < 0 || constraints.overlap < 0) {
      child?.layout(constraints.asBoxConstraints(maxExtent: hei),
          parentUsesSize: false);
      geometry = SliverGeometry(
        scrollExtent: hei,
        paintOrigin: constraints.overlap,
        paintExtent: hei,
        maxPaintExtent: hei,
        layoutExtent: hei,
      );
    } else {
      double paintExtent = hei - constraints.scrollOffset;
      // paintExtent = min(paintExtent, constraints.remainingPaintExtent);

      child!.layout(
        constraints.asBoxConstraints(maxExtent: hei),
        parentUsesSize: false,
      );

      //最大为_visibleExtent，最小为 0
      double layoutExtent = min(hei, paintExtent);

      //设置geometry，Viewport 在布局时会用到
      geometry = SliverGeometry(
          scrollExtent: hei,
          paintOrigin: -constraints.scrollOffset,
          paintExtent: paintExtent,
          maxPaintExtent: hei,
          layoutExtent: layoutExtent,
          hasVisualOverflow: true);
    }

    if ((constraints.scrollOffset + constraints.overlap > hei)) {
      _setFolded(true);
    } else {
      _setFolded(false);
    }
  }

  void _setFolded(bool folded) {
    if (folded != _isFolded) {
      _isFolded = folded;
      Future.delayed(Duration.zero, () {
        onFolded(folded);
      });
    }
  }
}
//
// class _Title extends SingleChildRenderObjectWidget {
//   _Title({super.key, required super.child});
//
//   @override
//   RenderObject createRenderObject(BuildContext context) {
//     return _TitleAdapter();
//   }
// }
//
// class _TitleAdapter extends RenderSliverSingleBoxAdapter {
//   final hei = 76.0;
//
//   _TitleAdapter();
//
//   @override
//   void performLayout() {
//     child!.layout(
//       constraints,
//       parentUsesSize: false,
//     );
//
//     geometry = const SliverGeometry(scrollExtent: 0);
//   }
// }
