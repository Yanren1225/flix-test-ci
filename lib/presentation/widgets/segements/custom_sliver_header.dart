import 'dart:math';

import 'package:flix/domain/log/flix_log.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';

class CustomSliverHeader extends StatelessWidget {
  final Widget lagerTitle;
  final double height;
  final Function(bool isFolded) onFolded;

  const CustomSliverHeader(
      {super.key, required this.lagerTitle, required this.height, required this.onFolded});

  @override
  Widget build(BuildContext context) {
    return _LargeTitle(
      child: lagerTitle,
      height: height,
      onFolded: onFolded,
    );
  }
}

class _LargeTitle extends SingleChildRenderObjectWidget {
  final Function(bool isFolded) onFolded;
  final double height;

  _LargeTitle({super.key, required super.child, required this.height, required this.onFolded});

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _LargeTitleAdapter(height: height, onFolded: onFolded);
  }
}

class _LargeTitleAdapter extends RenderSliverSingleBoxAdapter {
  final double height;
  var _isFolded = false;
  final Function(bool isFolded) onFolded;

  _LargeTitleAdapter({required this.height, required this.onFolded});

  @override
  void performLayout() {

    // 滑动距离大于_visibleExtent时则表示子节点已经在屏幕之外了
    if (child == null) {
      _setFolded(true);
      geometry = SliverGeometry(scrollExtent: height);
      return;
    }

    if (constraints.scrollOffset > height) {
      _setFolded(true);
      return;
    } else if ((constraints.scrollOffset + constraints.overlap > height)) {
      _setFolded(true);
    } else {
      _setFolded(false);
    }

    // talker.verbose(
    //     'scrollOffset ${constraints.scrollOffset}, ${constraints.overlap}');

    if (constraints.scrollOffset < 0 || constraints.overlap < 0) {
      child?.layout(constraints.asBoxConstraints(maxExtent: height),
          parentUsesSize: false);
      geometry = SliverGeometry(
        scrollExtent: height,
        paintOrigin: constraints.overlap,
        paintExtent: height,
        maxPaintExtent: height,
        layoutExtent: height,
      );
    } else {
      double paintExtent = height - constraints.scrollOffset;
      // paintExtent = min(paintExtent, constraints.remainingPaintExtent);

      child!.layout(
        constraints.asBoxConstraints(maxExtent: height),
        parentUsesSize: false,
      );

      //最大为_visibleExtent，最小为 0
      double layoutExtent = min(height, paintExtent);

      //设置geometry，Viewport 在布局时会用到
      geometry = SliverGeometry(
          scrollExtent: height,
          paintOrigin: -constraints.scrollOffset,
          paintExtent: paintExtent,
          maxPaintExtent: height,
          layoutExtent: layoutExtent,
          hasVisualOverflow: true);
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
