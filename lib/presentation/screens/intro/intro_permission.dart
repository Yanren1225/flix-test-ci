import 'package:figma_squircle/figma_squircle.dart';
import 'package:flix/presentation/screens/intro/intro_agreement.dart';
import 'package:flix/presentation/screens/intro/intro_privacy.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:roundcheckbox/roundcheckbox.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 引入roundcheckbox插件

class IntroPermission extends StatefulWidget {
  final VoidCallback onBackPressed; 

  IntroPermission({required this.onBackPressed, required void Function() onContinuePressed});

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
                    const Expanded(
                      flex: 1,
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.only(right: 16, left: 16, bottom: 16, top: 56),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '给 Flix 必要的权限',
                                style: TextStyle(
                                  fontSize: 30,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                '为了保证软件的正常使用，我们需要向你申请\n以下权限：',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color.fromRGBO(60, 60, 67, 0.6),
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
                                      'assets/images/permission_item1.svg', '打开和关闭WIFI', '扫描附近的设备'),
                                  _buildPermissionItem(
                                      'assets/images/permission_item2.svg', '存储', '保存接收到的文件'),
                                  _buildPermissionItem(
                                      'assets/images/permission_item3.svg', '通知', '接收新文件通知'),
                                  _buildPermissionItem(
                                      'assets/images/permission_item4.svg', '定位', '获取网络名称'),
                                  _buildPermissionItem(
                                      'assets/images/permission_item5.svg', '相机', '扫描二维码'),
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
                      uncheckedColor: const Color.fromRGBO(0, 0, 0, 0.06),
                      border: Border.all(
                        color: Color.fromARGB(0, 0, 123, 255),
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
                        text: '已阅读并同意 ',
                        style: const TextStyle(color: Colors.black),
                        children: [
                          TextSpan(
                            text: '用户协议',
                            style: const TextStyle(
                              color: Color.fromRGBO(0, 122, 255, 1),
                            ),
                          
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const IntroAgreementPage()),
  );
}
                          ),
                          const TextSpan(
                            text: ' 和 ',
                            style: TextStyle(color: Colors.black),
                          ),
                          TextSpan(
                            text: '隐私政策',
                            style: const TextStyle(
                              color: Color.fromRGBO(0, 122, 255, 1),
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const IntroPrivacyPage()),
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
                          child: const Text(
                            '上一步',
                            style: TextStyle(
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

                
                  Navigator.of(context).popUntil((route) => route.isFirst);
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
                          child: const Text(
                            '开始使用',
                            style: TextStyle(
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
              const Padding(
                padding: EdgeInsets.only(left: 22.0, top: 100),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '给 Flix 必要的权限',
                        style: TextStyle(fontSize: 30),
                      ),
                      Text(
                        '为了保证软件的正常使用，我们需要向你申请以下权限：',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color.fromRGBO(60, 60, 67, 0.6),
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
                          'assets/images/permission_item1.svg', '打开和关闭WIFI', '扫描附近的设备'),
                      _buildPermissionItem(
                          'assets/images/permission_item2.svg', '存储', '保存接收到的文件'),
                      _buildPermissionItem(
                          'assets/images/permission_item3.svg', '通知', '接收新文件通知'),
                      _buildPermissionItem(
                          'assets/images/permission_item4.svg', '定位', '获取网络名称'),
                      _buildPermissionItem(
                          'assets/images/permission_item5.svg', '相机', '扫描二维码'),
                    ],
                  ),
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
                      uncheckedColor: const Color.fromRGBO(0, 0, 0, 0.06),
                      border: Border.all(
                        color: Color.fromARGB(0, 0, 123, 255),
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
                        text: '已阅读并同意 ',
                        style: const TextStyle(color: Colors.black),
                        children: [
                          TextSpan(
                            text: '用户协议',
                            style: const TextStyle(
                              color: Color.fromRGBO(0, 122, 255, 1),
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const IntroAgreementPage()),
  );
}
                          ),
                          const TextSpan(
                            text: ' 和 ',
                            style: TextStyle(color: Colors.black),
                          ),
                          TextSpan(
                            text: '隐私政策',
                            style: const TextStyle(
                              color: Color.fromRGBO(0, 122, 255, 1),
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const IntroPrivacyPage()),
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
                          child: const Text(
                            '上一步',
                            style: TextStyle(
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

               
                  Navigator.of(context).popUntil((route) => route.isFirst);
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
                          child: const Text(
                            '开始使用',
                            style: TextStyle(
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
          color: Colors.white,
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
            style: const TextStyle(
              color: Color.fromRGBO(60, 60, 67, 0.6),
            ),
          ),
          horizontalTitleGap: 16.0,
        ),
      ),
    );
  }
}
