
import 'package:flix/model/ui_bubble/ui_bubble.dart';
import 'package:flix/presentation/widgets/bubbles/bubble_widget.dart';
import 'package:flutter/material.dart';

class BubbleList extends StatelessWidget {
  const BubbleList({
    super.key,
    ScrollController? scrollController,
    required this.padding,
    required this.items,
    required this.reverse,
    required this.shrinkWrap,
  }) : _scrollController = scrollController;

  final ScrollController? _scrollController;
  final EdgeInsets padding;
  final List<UIBubble> items;
  final bool reverse;
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics(decelerationRate: ScrollDecelerationRate.fast)),
        reverse: reverse,
        shrinkWrap: shrinkWrap,
        controller: _scrollController,
        padding: EdgeInsets.only(top: padding.top, bottom: 260),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Padding(
            padding: const EdgeInsets.only(
                left: 16.0, right: 16.0, top: 12, bottom: 12),
            child: BubbleWidget(
              key: ValueKey('$index'),
              uiBubble: item,
            ),
          );
        });
  }
}
