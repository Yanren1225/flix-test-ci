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
          color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          expandedAlignment: Alignment.topLeft,
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          backgroundColor: Colors.white,
          collapsedBackgroundColor: Colors.white,
          textColor: Colors.black,
          collapsedTextColor: Colors.black,
          iconColor: const Color.fromRGBO(60, 60, 67, 0.6),
          collapsedIconColor: const Color.fromRGBO(60, 60, 67, 0.6),
          shape: InputBorder.none,
          collapsedShape: InputBorder.none,
          title: Text(
            widget.question,
            style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: Colors.black)
                .fix(),
          ),
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                widget.answer,
                style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: Color.fromRGBO(60, 60, 67, 0.6))
                    .fix(),
              ),
            )
          ],
        ),
      ),
    );
  }
}
