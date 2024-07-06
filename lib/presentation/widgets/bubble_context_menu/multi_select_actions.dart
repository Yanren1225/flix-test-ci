import 'dart:ui';

import 'package:flix/presentation/basic/corner/flix_decoration.dart';
import 'package:flix/presentation/widgets/segements/bubble_context_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class MultiSelectActions extends StatelessWidget {
  const MultiSelectActions({
    Key? key,
    required this.onDelete,
  }) : super(key: key);

  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    // left: 0dp;
    // top: 0dp;
    // width: 390dp;
    // height: 81dp;
    // opacity: 1;
    //
    // border-top: 0.5dp solid rgba(228, 228, 228, 1);
    //
    // backdrop-filter: blur(50dp);
    // display: flex;
    // flex-direction: column;
    // justify-content: flex-start;
    // align-items: flex-start;
    // padding: 6dp 0dp 10dp 0dp;
    // 根据注释实现UI

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
        child: Container(
            decoration: FlixDecoration(
                // border: Border(
                //   top: BorderSide(
                //     color: const Color.fromRGBO(228, 228, 228, 1),
                //     width: 0.5,
                //   ),
                // ),
                ),
            padding: EdgeInsets.only(
                top: 6, bottom: 10 + MediaQuery.paddingOf(context).bottom),
            child: Align(
              heightFactor: 1,
              child: BubbleContextMenuItem(
                icon: 'assets/images/ic_delete.svg',
                title: '删除',
                color: const Color.fromRGBO(255, 59, 48, 1),
                onTap: onDelete,
              ),
            )),
      ),
    );
  }
}
