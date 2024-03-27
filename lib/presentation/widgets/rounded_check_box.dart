import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RoundedCheckBox extends StatefulWidget {
  final bool value;
  final ValueChanged<bool>? onCheckChanged;
  final double size;
  Widget customIcon =
      SvgPicture.asset('assets/images/ic_checkbox_content.svg'); // 自定义图标
  Color unCheckedColor; // 未选中时边框颜色
  Color checkedColor; // 选中时填充颜色

  RoundedCheckBox({
    super.key,
    required this.value,
    this.onCheckChanged,
    this.size = 20.0, // 默认圆形大小
    this.unCheckedColor = const Color.fromRGBO(229, 229, 234, 1),
    this.checkedColor = const Color.fromRGBO(0, 122, 255, 1),
  });

  @override
  _RoundedCheckBoxState createState() => _RoundedCheckBoxState();
}

class _RoundedCheckBoxState extends State<RoundedCheckBox> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onCheckChanged?.call(!widget.value);
      },
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.value ? widget.checkedColor : widget.unCheckedColor,
        ),
        child: Center(
          child: SizedBox(
              width: 13,
              height: 13,
              child: widget.value ? widget.customIcon : null),
        ),
      ),
    );
  }
}
