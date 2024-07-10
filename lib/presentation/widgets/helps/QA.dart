import 'package:flix/theme/theme_extensions.dart';
import 'package:flix/utils/text/text_extension.dart';
import 'package:flutter/material.dart';

class QA extends StatefulWidget {
  final String question;
  final String answer;

  const QA({super.key, required this.question, required this.answer});

  @override
  State<StatefulWidget> createState() => QAState();
}

class QAState extends State<QA> {
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
          color: Theme.of(context).flixColors.background.primary,
          borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          expandedAlignment: Alignment.topLeft,
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          backgroundColor: Theme.of(context).flixColors.background.primary,
          collapsedBackgroundColor:
              Theme.of(context).flixColors.background.primary,
          textColor: Theme.of(context).flixColors.text.primary,
          collapsedTextColor: Theme.of(context).flixColors.text.primary,
          iconColor: Theme.of(context).flixColors.text.secondary,
          collapsedIconColor: Theme.of(context).flixColors.text.secondary,
          shape: InputBorder.none,
          collapsedShape: InputBorder.none,
          title: Text(
            widget.question,
            style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: Theme.of(context).flixColors.text.primary)
                .fix(),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                widget.answer,
                style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: Theme.of(context).flixColors.text.secondary)
                    .fix(),
              ),
            )
          ],
        ),
      ),
    );
  }
}
