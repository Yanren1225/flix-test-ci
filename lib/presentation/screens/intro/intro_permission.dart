import 'package:figma_squircle/figma_squircle.dart';
import 'package:flix/main.dart';
import 'package:flix/presentation/screens/main_screen.dart';
import 'package:flix/presentation/screens/settings/agreement.dart';
import 'package:flix/presentation/screens/settings/pravicy.dart';
import 'package:flix/presentation/widgets/flix_bottom_sheet.dart';
import 'package:flix/theme/theme_extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:roundcheckbox/roundcheckbox.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../l10n/l10n.dart'; // 引入roundcheckbox插件

class IntroPermission extends StatefulWidget {
  final VoidCallback onBackPressed; 

  IntroPermission({Key? key,required this.onBackPressed, required void Function() onContinuePressed}): super(key: key);

  @override
  _IntroPermissionState createState() => _IntroPermissionState();
}

class _IntroPermissionState extends State<IntroPermission> {
  bool isChecked = false; 

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
                          padding: const EdgeInsets.only(right: 16, left: 16, bottom: 16, top: 56),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                S.of(context).intro_permission_1,
                                style: const TextStyle(
                                  fontSize: 30,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                S.of(context).intro_permission_2,
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
                          padding: const EdgeInsets.only(right: 16, left: 16, bottom: 16, top: 56),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxWidth: 400,
                            ),
                            child: Center(
                              child: ListView(
                                shrinkWrap: true,
                                children: [
                                  _buildPermissionItem(
                                      'assets/images/permission_item1.svg', S.of(context).intro_permission_3a, S.of(context).intro_permission_3b),
                                  _buildPermissionItem(
                                      'assets/images/permission_item2.svg', S.of(context).intro_permission_4a, S.of(context).intro_permission_4b),
                                  _buildPermissionItem(
                                      'assets/images/permission_item3.svg', S.of(context).intro_permission_5a, S.of(context).intro_permission_5b),
                                  _buildPermissionItem(
                                      'assets/images/permission_item4.svg', S.of(context).intro_permission_6a, S.of(context).intro_permission_6b),
                                  _buildPermissionItem(
                                      'assets/images/permission_item5.svg', S.of(context).intro_permission_7a, S.of(context).intro_permission_7b),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center, 
                  children: [
                    RoundCheckBox(
                      size: 18,
                      onTap: (selected) {
                        setState(() {
                          isChecked = selected!;
                        });
                      },
                      checkedColor: const Color.fromARGB(255, 0, 122, 255),
                      uncheckedColor: Theme.of(context).flixColors.text.tertiary.withOpacity(0.08),
                      border: Border.all(
                        color: Theme.of(context).flixColors.text.tertiary.withOpacity(0.08),
                        width: 0,
                      ),
                      isChecked: isChecked,
                      checkedWidget: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                    const SizedBox(width: 10),
                   
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: S.of(context).intro_permission_8a,
                        style:  TextStyle(color: Theme.of(context).flixColors.text.primary),
                        children: [
                          TextSpan(
                            text: S.of(context).intro_permission_8b,
                            style: const TextStyle(
                              color: Color.fromRGBO(0, 122, 255, 1),
                            ),
                          
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const SettingAgreementScreen()),
                              );
                            }
                          ),
                          TextSpan(
                            text: S.of(context).intro_permission_8c,
                            style:  TextStyle(color: Theme.of(context).flixColors.text.primary),
                          ),
                          TextSpan(
                            text: S.of(context).intro_permission_8d,
                            style: const TextStyle(
                              color: Color.fromRGBO(0, 122, 255, 1),
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const SettingPravicyScreen()),
                                );
                              }
                          ),
                        ],
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
                          onPressed: widget.onBackPressed, 
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
                          onPressed: isChecked
                            ? () async {
                              
                                SharedPreferences prefs = await SharedPreferences.getInstance();
                                await prefs.setBool('isFirstRun', false);

                                Navigator.pushReplacementNamed(
                                  navigatorKey.currentContext!,
                                  "/main",
                                );
                              }
                            : null, 
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isChecked
                                ? const Color.fromRGBO(0, 122, 255, 1)
                                : Colors.grey, 
                            shadowColor: Colors.transparent,
                            shape: SmoothRectangleBorder(
                              borderRadius: SmoothBorderRadius(
                                cornerRadius: 15,
                                cornerSmoothing: 0.6,
                              ),
                            ),
                          ),
                          child: Text(
                            S.of(context).intro_permission_9,
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
                padding: const EdgeInsets.only(left: 22.0, top: 100),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        S.of(context).intro_permission_1,
                        style: const TextStyle(fontSize: 30),
                      ),
                      Text(
                        S.of(context).intro_permission_2,
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
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      _buildPermissionItem(
                          'assets/images/permission_item1.svg', S.of(context).intro_permission_3a, S.of(context).intro_permission_3b),
                      _buildPermissionItem(
                          'assets/images/permission_item2.svg', S.of(context).intro_permission_4a, S.of(context).intro_permission_4b),
                      _buildPermissionItem(
                          'assets/images/permission_item3.svg', S.of(context).intro_permission_5a, S.of(context).intro_permission_5b),
                      _buildPermissionItem(
                          'assets/images/permission_item4.svg', S.of(context).intro_permission_6a, S.of(context).intro_permission_6b),
                      _buildPermissionItem(
                          'assets/images/permission_item5.svg', S.of(context).intro_permission_7a, S.of(context).intro_permission_7b),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0,left: 28,right: 28),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RoundCheckBox(
                      size: 18,
                      onTap: (selected) {
                        setState(() {
                          isChecked = selected!;
                        });
                        if(isChecked){
                        isChecked = false;
                         showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return FlixBottomSheet(
        title: '隐私政策',
        subTitle: '我们致力于保护您的隐私，请确保您已仔细阅读《隐私政策》，如同意请点击“同意”。',
        buttonText: '同意',
        onClickFuture: () async {
          setState(() {
              isChecked = true;
            
          });
     
      },
        child: Padding(
                 padding: const EdgeInsets.all(0.0),
                 child: Column(
                  mainAxisSize: MainAxisSize.min,
    children: [Padding(
                  
                                 padding: const EdgeInsets.only(
                                     left: 28, right: 28, bottom: 10,top: 20),
                                 child: SizedBox(
                                   width: double.infinity,
                                   child: CupertinoButton(
                                     onPressed: () async {
                                       Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const SettingPravicyScreen()),
                                  );
                                   
                                     },
                                     color: Theme.of(context).flixColors.text.secondary.withOpacity(0.1),
                                     borderRadius: BorderRadius.circular(14),
                                     padding: const EdgeInsets.symmetric(
                                         horizontal: 24, vertical: 16),
                                     child: Text(
                                       '阅读《隐私政策》',
                                       style:  TextStyle(
                                               fontSize: 18,
                                               fontWeight: FontWeight.w500,
                                               letterSpacing: 0,
                                               color: Theme.of(context).flixColors.text.primary,
                                               decoration: TextDecoration.none)
                                         
                                     ),
                                   ),
                                 )),

                                  Padding(
                                 padding: const EdgeInsets.only(
                                     left: 28, right: 28, bottom: 10,top: 0),
                                 child: SizedBox(
                                   width: double.infinity,
                                   child: CupertinoButton(
                                     onPressed: () async {
                                      
                                       Navigator.of(context).pop();
                                     },
                                     color: Theme.of(context).flixColors.text.secondary.withOpacity(0.1),
                                     borderRadius: BorderRadius.circular(14),
                                     padding: const EdgeInsets.symmetric(
                                         horizontal: 24, vertical: 16),
                                     child: Text(
                                       '返回',
                                       style:  TextStyle(
                                               fontSize: 18,
                                               fontWeight: FontWeight.w500,
                                               letterSpacing: 0,
                                               color: Theme.of(context).flixColors.text.primary,
                                               decoration: TextDecoration.none)
                                         
                                     ),
                                   ),
                                 )),
                  ]))

                  
      );
    },
  );}
                      },
                      checkedColor: const Color.fromARGB(255, 0, 122, 255),
                      uncheckedColor: Theme.of(context).flixColors.text.tertiary.withOpacity(0.08),
                      border: Border.all(
                        color: Theme.of(context).flixColors.text.tertiary.withOpacity(0.08),
                        width: 0,
                      ),
                      isChecked: isChecked,
                      checkedWidget: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: RichText(
                        textAlign: TextAlign.left, 
                        text: TextSpan(
                          text: S.of(context).intro_permission_8a,
                          style: TextStyle(color: Theme.of(context).flixColors.text.primary),
                          children: [
                            TextSpan(
                              text: S.of(context).intro_permission_8b,
                              style: const TextStyle(
                                color: Color.fromRGBO(0, 122, 255, 1),
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const SettingAgreementScreen()),
                                  );
                                }
                            ),
                            TextSpan(
                              text: S.of(context).intro_permission_8c,
                              style: TextStyle(color: Theme.of(context).flixColors.text.primary),
                            ),
                            TextSpan(
                              text: S.of(context).intro_permission_8d,
                              style: const TextStyle(
                                color: Color.fromRGBO(0, 122, 255, 1),
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const SettingPravicyScreen()),
                                  );
                                }
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
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
                          onPressed: widget.onBackPressed,
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
                         onPressed: isChecked
              ? () async {

SharedPreferences prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('isFirstRun', false);

                  Navigator.pushReplacementNamed(
                    navigatorKey.currentContext!,
                    "/main",
                  );
               
               
               
                }
              : null, 
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isChecked
                                ? const Color.fromRGBO(0, 122, 255, 1)
                                : Colors.grey,
                            shadowColor: Colors.transparent,
                            shape: SmoothRectangleBorder(
                              borderRadius: SmoothBorderRadius(
                                cornerRadius: 15,
                                cornerSmoothing: 0.6,
                              ),
                            ),
                          ),
                          child: Text(
                            S.of(context).intro_permission_9,
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

  
  Widget _buildPermissionItem(String assetPath, String title, String subtitle) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        decoration: BoxDecoration(
          color: Theme.of(context).flixColors.background.primary,
         borderRadius: SmoothBorderRadius(
                                cornerRadius: 15,
                                cornerSmoothing: 0.6,
                              ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.only(left: 20.0),
          leading: SvgPicture.asset(
            assetPath,
            width: 24,
            height: 24,
            fit: BoxFit.contain,
          ),
          title: Text(title),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              color: Theme.of(context).flixColors.text.secondary,
            ),
          ),
          horizontalTitleGap: 16.0,
        ),
      ),
    );
  }
}
