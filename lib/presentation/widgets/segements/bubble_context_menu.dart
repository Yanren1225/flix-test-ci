import 'dart:io';
import 'dart:ui';

import 'package:flix/theme/theme_extensions.dart';
import 'package:flix/presentation/basic/corner/flix_clip_r_rect.dart';
import 'package:flix/presentation/basic/corner/flix_decoration.dart';
import 'package:flix/utils/text/text_extension.dart';
import 'package:flix/model/ui_bubble/ui_bubble.dart';
import 'package:flix/utils/platform_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:modals/modals.dart';

void showBubbleContextMenu(
    BuildContext context,
    String tag,
    Offset clickPosition,
    String selfId,
    GlobalKey relativeWidgetKey,
    UIBubble bubble,
    List<BubbleContextMenuItemType> itemTypes,
    Map<BubbleContextMenuItemType, VoidCallback> itemActions) {
  removeAllModals();
  RenderBox? currentWidget = context.findRenderObject() as RenderBox?;
  RenderBox? relativeWidget =
      relativeWidgetKey.currentContext?.findRenderObject() as RenderBox?;
  if (currentWidget == null || relativeWidget == null) {
    throw StateError('currentWidget or relativeWidget should not null');
  }
  final availableWidth = relativeWidget.size.width;
  int itemTotalWidth = _getMenuWidth(itemTypes);
  final globalOffset =
      currentWidget.localToGlobal(clickPosition, ancestor: relativeWidget);
  final bool showTop;
  if (globalOffset.dy > 100) {
    showTop = true;
  } else {
    showTop = false;
  }
  final bool showLeft;

  if (globalOffset.dx > relativeWidget.size.width - 200) {
    showLeft = true;
  } else {
    showLeft = false;
  }

  final Alignment modalAlignment;
  if (showTop && showLeft) {
    modalAlignment = Alignment.bottomRight;
  } else if (showTop && !showLeft) {
    modalAlignment = Alignment.bottomLeft;
  } else if (!showTop && !showLeft) {
    modalAlignment = Alignment.topLeft;
  } else {
    modalAlignment = Alignment.topRight;
  }

  if (modalAlignment == Alignment.topRight ||
      modalAlignment == Alignment.bottomRight) {
    if (globalOffset.dx < itemTotalWidth) {
      clickPosition = Offset(
          clickPosition.dx + itemTotalWidth - globalOffset.dx,
          clickPosition.dy);
    }
  } else {
    if (availableWidth - globalOffset.dx < itemTotalWidth) {
      clickPosition = Offset(
          clickPosition.dx -
              (itemTotalWidth - (availableWidth - globalOffset.dx)),
          clickPosition.dy);
    }
  }

  showModal(ModalEntry.anchored(
    context,
    tag: 'menu',
    anchorTag: tag,
    modalAlignment: modalAlignment,
    anchorAlignment: Alignment.topLeft,
    offset: clickPosition,
    // barrierColor: const Color.fromRGBO(0, 0, 0, 0.45),
    removeOnPop: true,
    barrierDismissible: false,
    child: BubbleContextMenu(itemTypes: itemTypes, itemActions: itemActions),
  ));
}

int _getMenuWidth(List<BubbleContextMenuItemType> itemTypes) {
  const itemWidth = 55;
  const horizontalMargin = 20;
  const itemGap = 8;
  final itemTotalWidth = itemWidth * itemTypes.length +
      itemGap * (itemTypes.length - 1) +
      horizontalMargin;
  return itemTotalWidth;
}

int _getMenuHeight(List<BubbleContextMenuItemType> itemTypes) {
  return 67;
}

class BubbleContextMenu extends StatefulWidget {
  final List<BubbleContextMenuItemType> itemTypes;
  final Map<BubbleContextMenuItemType, VoidCallback> itemActions;

  const BubbleContextMenu(
      {super.key, required this.itemTypes, required this.itemActions});

  @override
  BubbleContextMenuState createState() => BubbleContextMenuState();
}

class BubbleContextMenuState extends State<BubbleContextMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> items = [];
    for (final type in widget.itemTypes) {
      switch (type) {
        case BubbleContextMenuItemType.Copy:
          items.add(BubbleContextMenuItem(
            title: '复制',
            icon: 'assets/images/ic_copy.svg',
            onTap: onTap(type),
          ));
          break;
        case BubbleContextMenuItemType.Forward:
          items.add(BubbleContextMenuItem(
            title: '转发',
            icon: 'assets/images/ic_forward.svg',
            onTap: onTap(type),
          ));
          break;
        case BubbleContextMenuItemType.Location:

          items.add(BubbleContextMenuItem(
            title: Platform.isAndroid ? '文件打开' :  '文件位置',
            icon: 'assets/images/ic_location.svg',
            onTap: onTap(type),
          ));
          break;
        case BubbleContextMenuItemType.MultiSelect:
          items.add(BubbleContextMenuItem(
            title: '多选',
            icon: 'assets/images/ic_multi_select.svg',
            onTap: onTap(type),
          ));
          break;
        case BubbleContextMenuItemType.Delete:
          items.add(BubbleContextMenuItem(
            title: '删除',
            icon: 'assets/images/ic_delete.svg',
            color: const Color.fromRGBO(255, 59, 48, 1),
            onTap: onTap(type),
          ));
          break;
        case BubbleContextMenuItemType.FreeCopy:
          items.add(BubbleContextMenuItem(
            title: '自由复制',
            icon: 'assets/images/ic_free_copy.svg',
            onTap: onTap(type),
          ));
          break;
      }
    }
    return AnimatedBuilder(
      animation: _animation,
      builder: (BuildContext context, Widget? child) {
        return Transform.scale(
          scale: _animation.value,
          child: FadeTransition(
            opacity: _animation,
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: DecoratedBox(
          decoration: FlixDecoration(boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.1),
              offset: Offset(2, 10),
              blurRadius: 20,
            ),
          ]),
          child: FlixClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .flixColors
                      .background
                      .primary
                      .withOpacity(0.9),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 10, top: 6, right: 10, bottom: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [...items],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  VoidCallback onTap(BubbleContextMenuItemType type) {
    return () {
      removeAllModals();
      Future.delayed(Duration.zero, () => widget.itemActions[type]?.call());
    };
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class BubbleContextMenuItem extends StatelessWidget {
  final String title;
  final String icon;
  final VoidCallback onTap;
  final Color? color;

  const BubbleContextMenuItem(
      {super.key,
      required this.title,
      required this.icon,
      this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 63,
      height: 66,
      child: CupertinoButton(
        onPressed: onTap,
        padding: EdgeInsets.zero,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              icon,
              colorFilter: ColorFilter.mode(
                  color ?? Theme.of(context).flixColors.text.primary,
                  BlendMode.srcIn),
            ),
            const SizedBox(
              height: 2,
            ),
            Text(title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: color ?? Theme.of(context).flixColors.text.primary,
                ).fix()),
          ],
        ),
      ),
    );
  }
}

class BubbleContextMenuWithMask extends BubbleContextMenu {
  final TextSelectionToolbarAnchors anchors;

  const BubbleContextMenuWithMask(
      {super.key,
      required this.anchors,
      required super.itemTypes,
      required super.itemActions});

  @override
  BubbleContextMenuState createState() {
    return BubbleContextMenuWithMaskState();
  }
}

class BubbleContextMenuWithMaskState extends BubbleContextMenuState {
  @override
  Widget build(BuildContext context) {
    final anchors = (widget as BubbleContextMenuWithMask).anchors;
    const margin = 13.0;
    const appBarHeight = 60.0;
    final availableHeight = anchors.primaryAnchor.dy -
        margin -
        MediaQuery.paddingOf(context).top -
        appBarHeight;
    final fitsAbove = _getMenuHeight(widget.itemTypes) <= availableHeight;
    return CustomSingleChildLayout(
        delegate: isDesktop()
            ? DesktopTextSelectionToolbarLayoutDelegate(
                anchor: anchors.primaryAnchor,
              )
            : TextSelectionToolbarLayoutDelegate(
                anchorAbove: anchors.primaryAnchor - const Offset(0, margin),
                anchorBelow: (anchors.secondaryAnchor == null
                        ? anchors.primaryAnchor
                        : anchors.secondaryAnchor!) +
                    const Offset(0, margin),
                fitsAbove: fitsAbove,
              ),
        child: super.build(context));
  }
}

enum BubbleContextMenuItemType {
  Copy,
  Forward,
  Location,
  MultiSelect,
  Delete,
  FreeCopy,
}
