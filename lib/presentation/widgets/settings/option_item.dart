import 'package:flix/presentation/basic/corner/flix_clip_r_rect.dart';
import 'package:flix/presentation/basic/corner/flix_decoration.dart';
import 'package:flix/presentation/widgets/settings/settings_label.dart';
import 'package:flix/theme/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:modals/modals.dart';

class OptionData {
  final String label;
  final String tag;

  const OptionData({required this.label, required this.tag});
}

class OptionItem extends StatelessWidget {
  final String label;
  final String? des;
  final List<OptionData> options;
  final OptionData value;
  final String tag;
  final ValueChanged<OptionData> onChanged;

  final bool topRadius;
  final bool bottomRadius;

  const OptionItem(
      {super.key,
      required this.label,
      this.des,
      required this.options,
      required this.value,
      required this.onChanged,
      required this.tag,
      required this.topRadius,
      required this.bottomRadius});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        removeModal(tag);
        showModal(ModalEntry.anchored(context,
            tag: tag,
            anchorTag: tag,
            removeOnPop: true,
            barrierDismissible: true,
            barrierColor: Colors.black.withOpacity(0.45),
            modalAlignment: Alignment.centerRight,
            offset: const Offset(10, 0),
            child: OptionModal(
              options: options,
              value: value,
              onChanged: onChanged,
              tag: tag,
            )));
      },
      child: DecoratedBox(
        decoration: FlixDecoration(
            color: Theme.of(context).flixColors.background.primary,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(topRadius ? 14 : 0),
                topRight: Radius.circular(topRadius ? 14 : 0),
                bottomLeft: Radius.circular(bottomRadius ? 14 : 0),
                bottomRight: Radius.circular(bottomRadius ? 14 : 0))),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: SettingsLabel(label: label, des: des)),
              Text(value.label,
                  style: TextStyle(
                      color: Theme.of(context).flixColors.text.secondary,
                      fontSize: 14)),
              const SizedBox(
                width: 4,
              ),
              ModalAnchor(
                tag: tag,
                child: Icon(Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: Theme.of(context).flixColors.text.secondary),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class OptionModal extends StatefulWidget {
  final List<OptionData> options;
  final OptionData value;
  final String tag;
  final ValueChanged<OptionData> onChanged;

  const OptionModal(
      {super.key,
      required this.options,
      required this.value,
      required this.tag,
      required this.onChanged});

  @override
  State<OptionModal> createState() => _OptionModalState();
}

class _OptionModalState extends State<OptionModal>
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
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: child,
        );
      },
      child: FlixClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Theme.of(context).flixColors.background.primary,
          child: Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            constraints: const BoxConstraints(
                maxHeight: 300, maxWidth: 300, minWidth: 170),
            child: SingleChildScrollView(
              child: IntrinsicWidth(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...widget.options.asMap().entries.map((e) {
                      final index = e.key;

                      return OptionSelectItem(
                        isFirst: index == 0,
                        isLast: index == widget.options.length - 1,
                        index: index,
                        value: e.value,
                        selected: widget.value,
                        onTap: () {
                          removeModal(widget.tag);
                          widget.onChanged(e.value);
                        },
                      );
                    }).toList()
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class OptionSelectItem extends StatelessWidget {
  final OptionData value;
  final OptionData selected;
  final Function onTap;
  final bool isFirst;
  final bool isLast;
  final int index;

  const OptionSelectItem(
      {super.key,
      required this.value,
      required this.selected,
      required this.onTap,
      this.isFirst = false,
      this.isLast = false,
      required this.index});

  @override
  Widget build(BuildContext context) {
    final isSelected = value.tag == selected.tag;

    return InkWell(
      onTap: () => onTap(),
      child: Container(
        // width: 170,
        color: isSelected
            ? const Color(0xff007AFF).withOpacity(0.1)
            : Theme.of(context).flixColors.background.primary,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10)
              .copyWith(top: isFirst ? 16 : 10, bottom: isLast ? 16 : 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(value.label,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? const Color(0xff007AFF)
                          : Theme.of(context).flixColors.text.primary)),
              const SizedBox(width: 10),
              Visibility(
                visible: isSelected,
                child: const Icon(
                  Icons.check,
                  color: Color(0xff007AFF),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
