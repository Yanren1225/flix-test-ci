import 'package:flix/l10n/l10n.dart';
import 'package:flix/presentation/basic/corner/flix_decoration.dart';
import 'package:flix/presentation/widgets/flix_toast.dart';
import 'package:flix/theme/theme_extensions.dart';
import 'package:flix/utils/text/text_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart'; 

class FreeCopyScreen extends StatefulWidget {
  final String text;

  const FreeCopyScreen({super.key, required this.text});

  @override
  State<StatefulWidget> createState() => FreeCopyScreenState();
}

class FreeCopyScreenState extends State<FreeCopyScreen> {
  void _copyText() {
    Clipboard.setData(ClipboardData(text: widget.text)).then((_) {
      flixToast.info(S.of(context).bubbles_copied);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).flixColors.background.secondary,
      body: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Stack(
          children: [
            // Main content
            Container(
              padding: const EdgeInsets.only(left: 20,right: 20,bottom: 80,top:65),
              width: double.infinity,
              height: double.infinity,
              decoration: FlixDecoration(
                color: Theme.of(context).flixColors.background.secondary,
              ),
              child: Center(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(
                      decelerationRate: ScrollDecelerationRate.fast,
                    ),
                  ),
                  child: SelectableText(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    widget.text,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                    ).fix(),
                  ),
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 16, 
              left: 16,
              right: 16,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).flixColors.background.secondary,
                 
                ),
                child: const Text(
                  '长按自由复制文本  点击任意位置退出',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color.fromRGBO(60, 60, 67, 0.6),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0, 
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom + 15, 
                  top: 16,
                ),
                color: Colors.white, 
                child: Center(
                  child: GestureDetector(
                    onTap: _copyText,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                      
                     SvgPicture.asset(
                                    "assets/images/ic_copy.svg",
                                      width: 23,
                                      height: 23,
                                    ),
                        const SizedBox(height: 4), 
                      
                        Text(
                          '全部复制',
                          style: TextStyle(
                            fontSize: 13.5,
                            color: Theme.of(context).flixColors.text.primary, 
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
