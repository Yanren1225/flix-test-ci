import 'package:flix/utils/text/text_extension.dart';
import 'package:flix/utils/void_future_callback.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

// TODO: 回车确认
class FlixBottomSheet extends StatelessWidget {
  final String title;
  final String? subTitle;
  final String? buttonText;
  final List<Color> backgroundGradient;
  final Color buttonColor;
  final Widget child;
  final VoidFutureCallback? onClick;

  const FlixBottomSheet(
      {super.key,
      required this.title,
      this.subTitle,
      this.buttonText,
      this.backgroundGradient = const [
        Color.fromRGBO(232, 243, 255, 1),
        Color.fromRGBO(255, 255, 255, 1),
        Color.fromRGBO(255, 255, 255, 1),
      ],
      this.buttonColor = const Color.fromRGBO(0, 122, 255, 1),
      required this.child,
      this.onClick});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Material(
        type: MaterialType.transparency,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: SvgPicture.asset('assets/images/ic_handler.svg')),
              ),
              Flexible(
                child: Container(
                  margin:
                      const EdgeInsets.only(left: 16, right: 16, bottom: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: backgroundGradient,
                      stops: [0, 0.2043, 1],
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 20, top: 28, right: 20),
                        child: Text(
                          title,
                          style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                  decoration: TextDecoration.none)
                              .fix(),
                        ),
                      ),
                      Visibility(
                        visible: subTitle != null,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          child: Text(
                            subTitle ?? '',
                            style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: 0,
                                    color: Color.fromRGBO(60, 60, 67, 0.6),
                                    decoration: TextDecoration.none)
                                .fix(),
                          ),
                        ),
                      ),
                      Flexible(
                        child: child,
                      ),
                      Visibility(
                        visible: buttonText != null,
                        child: Padding(
                            padding: const EdgeInsets.only(
                                left: 28, right: 28, bottom: 28),
                            child: SizedBox(
                              width: double.infinity,
                              child: CupertinoButton(
                                onPressed: () async {
                                  await onClick?.call();
                                  Navigator.of(context).pop();
                                },
                                color: buttonColor,
                                borderRadius: BorderRadius.circular(14),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 16),
                                child: Text(
                                  buttonText ?? '',
                                  style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 0,
                                          color: Colors.white,
                                          decoration: TextDecoration.none)
                                      .fix(),
                                ),
                              ),
                            )),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
