import 'package:flix/domain/concert/concert_provider.dart';
import 'package:flix/model/ui_bubble/ui_bubble.dart';
import 'package:flix/presentation/widgets/bubbles/bubble_widget.dart';
import 'package:flix/presentation/widgets/rounded_check_box.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class BubbleList extends StatefulWidget {
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
  BubbleListState createState() => BubbleListState();
}

class BubbleListState extends State<BubbleList> {
  ScrollController? get _scrollController => widget._scrollController;

  EdgeInsets get padding => widget.padding;

  List<UIBubble> get items => widget.items;

  bool get reverse => widget.reverse;

  bool get shrinkWrap => widget.shrinkWrap;

  @override
  Widget build(BuildContext context) {
    final concertProvider = Provider.of<ConcertProvider>(context, listen: true);
    return ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(
                decelerationRate: ScrollDecelerationRate.fast)),
        reverse: reverse,
        shrinkWrap: shrinkWrap,
        controller: _scrollController,
        padding: EdgeInsets.only(top: padding.top, bottom: 260),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final cell = Padding(
            padding: const EdgeInsets.only(
                left: 16.0, right: 16.0, top: 12, bottom: 12),
            child: BubbleWidget(
              key: ValueKey('$index'),
              uiBubble: item,
            ),
          );
          if (concertProvider.isEditing) {
            return InkWell(
              onTap: () {
                final isChecked = !concertProvider.isSelected(item);
                if (isChecked) {
                  concertProvider.select(item);
                } else {
                  concertProvider.unselect(item);
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AnimatedSlide(
                    offset: concertProvider.isEditing ? const Offset(0, 0) : const Offset(-40, 0),
                    duration: const Duration(milliseconds: 100),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: RoundedCheckBox(
                        value: concertProvider.isSelected(item),
                        onCheckChanged: (isChecked) {
                          if (isChecked) {
                            concertProvider.select(item);
                          } else {
                            concertProvider.unselect(item);
                          }
                        },
                      ),
                    ),
                  ),
                  Expanded(child: AbsorbPointer(absorbing: concertProvider.isEditing, child: cell)),
                ],
              ),
            );
          } else {
            return cell;
          }
        });
  }
}
