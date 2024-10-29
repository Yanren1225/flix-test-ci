import 'package:figma_squircle/figma_squircle.dart';
import 'package:flix/theme/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../l10n/l10n.dart';

class IntroWiFi extends StatelessWidget {
  final VoidCallback onBackPressed; 
  final VoidCallback onContinuePressed; 

  const IntroWiFi({super.key, required this.onBackPressed, required this.onContinuePressed});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
         
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                S.of(context).intro_wifi_1,
                                style: const TextStyle(
                                  fontSize: 30,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                S.of(context).intro_wifi_2,
                                 style:  TextStyle(
                                  fontSize: 16,
                                  color: Theme.of(context).flixColors.text.secondary,
                            
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: SizedBox(
                            width: 360,
                            height: 360,
                            child: SvgPicture.asset(
                              'assets/images/intro.svg',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 70.0),
                child: SizedBox(
                  width: 310,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 148,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: onBackPressed, 
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromRGBO(0, 122, 255, 0.1),
                            shadowColor: Colors.transparent,
                            shape: SmoothRectangleBorder(
                              borderRadius: SmoothBorderRadius(
                                cornerRadius: 15,
                                cornerSmoothing: 0.6,
                              ),
                            ),
                          ),
                          child: Text(
                            S.of(context).intro_last,
                            style: const TextStyle(
                              color: Color.fromRGBO(0, 122, 255, 1),
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 148,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: onContinuePressed, 
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromRGBO(0, 122, 255, 1),
                            shadowColor: Colors.transparent,
                            shape: SmoothRectangleBorder(
                              borderRadius: SmoothBorderRadius(
                                cornerRadius: 15,
                                cornerSmoothing: 0.6,
                              ),
                            ),
                          ),
                          child: Text(
                            S.of(context).intro_next,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        } else {
      
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 22.0, top: 100),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        S.of(context).intro_wifi_1,
                        style: const TextStyle(fontSize: 30),
                      ),
                      Text(
                        S.of(context).intro_wifi_2,
                         style:  TextStyle(
                                  fontSize: 16,
                                  color: Theme.of(context).flixColors.text.secondary,
                            
                                ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 360,
                    height: 360,
                    child: SvgPicture.asset('assets/images/intro.svg'),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 28.0, right: 28.0, bottom: 70.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 55,
                        child: ElevatedButton(
                          onPressed: onBackPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromRGBO(0, 122, 255, 0.1),
                            shadowColor: Colors.transparent,
                            shape: SmoothRectangleBorder(
                              borderRadius: SmoothBorderRadius(
                                cornerRadius: 15,
                                cornerSmoothing: 0.6,
                              ),
                            ),
                          ),
                          child: Text(
                            S.of(context).intro_last,
                            style: const TextStyle(
                              color: Color.fromRGBO(0, 122, 255, 1),
                              fontSize: 17,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: SizedBox(
                        height: 55,
                        child: ElevatedButton(
                          onPressed: onContinuePressed, 
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromRGBO(0, 122, 255, 1),
                            shadowColor: Colors.transparent,
                            shape: SmoothRectangleBorder(
                              borderRadius: SmoothBorderRadius(
                                cornerRadius: 15,
                                cornerSmoothing: 0.6,
                              ),
                            ),
                          ),
                          child: Text(
                            S.of(context).intro_next,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }
      },
    );
  }
}
