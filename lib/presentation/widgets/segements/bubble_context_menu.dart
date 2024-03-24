import 'dart:ui';

import 'package:flix/model/ui_bubble/ui_bubble.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:modals/modals.dart';

void showBubbleContextMenu(
    BuildContext context,
    String selfId,
    GlobalKey relativeWidgetKey,
    UIBubble bubble,
    List<BubbleContextMenuItemType> itemTypes,
    Map<BubbleContextMenuItemType, VoidCallback> itemActions) {
  RenderBox? currentWidget = context.findRenderObject() as RenderBox?;
  RenderBox? relativeWidget =
      relativeWidgetKey.currentContext?.findRenderObject() as RenderBox?;
  if (currentWidget == null || relativeWidget == null) {
    throw StateError('currentWidget or relativeWidget should not null');
  }
  final globalOffset =
      currentWidget.localToGlobal(Offset.zero, ancestor: relativeWidget);
  final showTop;
  if (globalOffset.dy > 70) {
    showTop = true;
  } else {
    showTop = false;
  }

  final showLeft;

  if (bubble.isFromMe(selfId)) {
    showLeft = true;
  } else {
    showLeft = false;
  }
  final modalAlignment;
  final anchorAlignment;
  if (showTop && showLeft) {
    modalAlignment = Alignment.bottomRight;
    anchorAlignment = Alignment.topRight;
  } else if (showTop && !showLeft) {
    modalAlignment = Alignment.bottomLeft;
    anchorAlignment = Alignment.topLeft;
  } else if (!showTop && !showLeft) {
    modalAlignment = Alignment.topLeft;
    anchorAlignment = Alignment.bottomLeft;
  } else {
    modalAlignment = Alignment.topRight;
    anchorAlignment = Alignment.bottomRight;
  }

  showModal(ModalEntry.anchored(
    context,
    tag: 'menu',
    anchorTag: bubble.shareable.id,
    modalAlignment: modalAlignment,
    anchorAlignment: anchorAlignment,
    // barrierColor: const Color.fromRGBO(0, 0, 0, 0.45),
    removeOnPop: true,
    barrierDismissible: true,
    child: BubbleContextMenu(itemTypes: itemTypes, itemActions: itemActions),
  ));
}

class BubbleContextMenu extends StatefulWidget {
  final List<BubbleContextMenuItemType> itemTypes;
  final Map<BubbleContextMenuItemType, VoidCallback> itemActions;

  const BubbleContextMenu({super.key, required this.itemTypes, required this.itemActions});

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
      duration: Duration(milliseconds: 80),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> items = [];
    for (final type in widget.itemTypes)
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
            title: '文件位置',
            icon: 'assets/images/ic_location.svg',
            onTap: onTap(type),
          ));
          break;
        case BubbleContextMenuItemType.Delete:
          items.add(BubbleContextMenuItem(
            title: '删除',
            icon: 'assets/images/ic_delete.svg',
            onTap: onTap(type),
          ));
          break;
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
          decoration: BoxDecoration(boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.1),
              offset: Offset(2, 10),
              blurRadius: 20,
            ),
          ]),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(255, 255, 255, 0.6),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 2, top: 6, right: 2, bottom: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ...items
                      // BubbleContextMenuItem(
                      //     title: '复制',
                      //     icon: 'assets/images/ic_copy.svg',
                      //     onTap: () {}),
                      // BubbleContextMenuItem(
                      //     title: '文件位置',
                      //     icon: 'assets/images/ic_location.svg',
                      //     onTap: () {}),
                    ],
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
      widget.itemActions[type]?.call();
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

  BubbleContextMenuItem(
      {required this.title, required this.icon, required this.onTap});

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
            SvgPicture.asset(icon),
            const SizedBox(
              height: 2,
            ),
            Text(title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                )),
          ],
        ),
      ),
    );
  }
}

enum BubbleContextMenuItemType {
  Copy,
  Forward,
  Location,
  Delete,
}
