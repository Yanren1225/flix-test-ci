import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FreeCopyScreen extends StatefulWidget {
  final String text;

  const FreeCopyScreen({super.key, required this.text});

  @override
  State<StatefulWidget> createState() => FreeCopyScreenState();
}

class FreeCopyScreenState extends State<FreeCopyScreen> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          child: Center(
              child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(
                          decelerationRate: ScrollDecelerationRate.fast)),
                  child: SelectableText(widget.text,
                      style: const TextStyle(fontSize: 20, color: Colors.black)
                          .useSystemChineseFont()))),
        ),
      ),
    );
  }
}
