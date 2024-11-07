import 'dart:convert';
import 'package:flix/presentation/widgets/segements/navigation_scaffold.dart';
import 'package:flix/theme/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; 


class LoginPage extends StatefulWidget {
  @override
  bool showBack = true;
  LoginPage({super.key, required this.showBack});


  
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _verificationCodeController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isAccountExists = false;
  bool _isCodeSent = false;
  bool _isVerified = false;
  bool _emailSubmitted = false;
  bool _isSendingCode = false;
  String _generatedCode = '';
  String _statusMessage = '';
  String? _loggedInEmail; 
  String _title = '登录';
  

  @override
  void initState() {
    super.initState();
    _checkLoginStatus(); 
  }


  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _loggedInEmail = prefs.getString('loggedInEmail');
      _title = '我的账户';
    });
  }

 
  Future<void> _saveLoggedInEmail(String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('loggedInEmail', email);
  }


  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('loggedInEmail');
    setState(() {
      _loggedInEmail = null;
      _emailSubmitted = false; 
      _isAccountExists = false; 
      _statusMessage = ''; 
      _title = '登录';
    });
  }

 


  Future<void> _checkAccountExists() async {
    final email = _emailController.text.trim();

    if (email.isEmpty || !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      setState(() {
        _statusMessage = '请输入有效的邮箱地址';
      });
      return;
    }

    setState(() {
      _isSendingCode = true;
    });

    final url = Uri.parse('http://test-flix.cdnfree.cn/login.php');
    final response = await http.post(url, body: {
      'username': email,
      'action': 'check',
    });

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['status'] == 'success') {
        setState(() {
          _isAccountExists = true;
          _emailSubmitted = true;
          //_statusMessage = '用户存在，请输入密码';
          _statusMessage = '';
          _title = '输入密码';
          _isSendingCode = false;
        });
      } else {
       setState(() {
      _isSendingCode =false;
    });
        // final bool test = await FlutterNumberCaptcha.show(
        //          context,
        //          titleText: '注册账户',
        //          placeholderText: '输入验证码',
        //          checkCaption: '确认',
        //          accentColor: Color.fromRGBO(0, 122, 255, 1),
         //         invalidText: '验证码错误',
//       );

   

       setState(() {
          
          _isAccountExists = false;
          _isSendingCode = true;
          _emailSubmitted = true;
          _statusMessage = '';
         _statusMessage = '';
          _sendVerificationCode();
        });
    
       
      }
    } else {
      setState(() {
        _statusMessage = '服务器错误';
      });
    }

   
  }

  // 发送验证码
  Future<void> _sendVerificationCode() async {
    final email = _emailController.text.trim();

    if (email.isEmpty || !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      setState(() {
        _statusMessage = '请输入有效的邮箱地址';
      });
      return;
    }

    setState(() {
      _isSendingCode = true;
    });

    final url = Uri.parse('http://test-flix.cdnfree.cn/mail/send_verification_code.php');
    final response = await http.post(url, body: {
      'email': email,
    });

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['status'] == 'success') {
        setState(() {
          _generatedCode = responseData['code'].toString();
          _isCodeSent = true;
          _statusMessage = '验证码已发送到邮箱';
          _title = '邮箱验证';
          _isSendingCode = false;
        });
      } else {
        setState(() {
          _statusMessage = responseData['message'];
          _isSendingCode = false;
        });
      }
    } else {
      setState(() {
        _statusMessage = '服务器错误';
        _isSendingCode = false;
      });
    }
  }


  Future<void> _verifyCode() async {
    final inputCode = _verificationCodeController.text.trim();

      setState(() {
     
        _isSendingCode = true;
      });


    if (inputCode.isEmpty) {
      setState(() {
        _statusMessage = '请输入验证码';
        _isSendingCode = false;
      });
      return;
    }

    if (inputCode == _generatedCode) {
      setState(() {
        _isVerified = true;
        _statusMessage = '验证码验证成功，请设置密码';
        _title = '设置密码';
        _isSendingCode = false;
      });
    } else {
      setState(() {
        _statusMessage = '验证码错误';
        _isSendingCode = false;
      });
    }
  }

  // 登录
  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    setState(() {
     
        _isSendingCode = true;
      });

    if (password.isEmpty) {
      setState(() {
        _statusMessage = '请输入密码';
        _isSendingCode = false;
      });
      return;
    }

    final url = Uri.parse('http://test-flix.cdnfree.cn/login.php');
    final response = await http.post(url, body: {
      'username': email,
      'password': password,
      'action': 'login_or_register',
    });

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['status'] == 'success') {
        await _saveLoggedInEmail(email); 
        setState(() {
          _statusMessage = responseData['message'];
          _loggedInEmail = email; 
          _emailSubmitted = false; 
          _isAccountExists = false; 
          _isVerified = false; 
          _title = '我的账户';
          _isSendingCode = false;
        });
      } else {
        setState(() {
          _statusMessage = responseData['message'];
          _isSendingCode = false;
        });
      }
    } else {
      setState(() {
        _statusMessage = '服务器错误';
        _isSendingCode = false;
      });
    }
  }

  // 注册用户
  Future<void> _register() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

 setState(() {
     
        _isSendingCode = true;
      });


    if (password.isEmpty) {
      setState(() {
        _statusMessage = '请输入密码';
        _isSendingCode = false;
      });
      return;
    }

    final url = Uri.parse('http://test-flix.cdnfree.cn/login.php');
    final response = await http.post(url, body: {
      'username': email,
      'password': password,
      'action': 'login_or_register',
    });

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['status'] == 'success') {
        await _saveLoggedInEmail(email); 
        setState(() {
          _statusMessage = responseData['message'];
          _loggedInEmail = email; 
          _emailSubmitted = false; 
          _isAccountExists = false; 
          _isVerified = false; 
          _title = '我的账户';
          _isSendingCode = false;
        });
      } else {
        setState(() {
          _statusMessage = responseData['message'];
          _isSendingCode = false;
        });
      }
    } else {
      setState(() {
        _statusMessage = '服务器错误';
        _isSendingCode = false;
      });
    }
  }

  InputDecoration _buildInputDecoration(String labelText) {
  return InputDecoration(
    labelText: labelText,
    filled: true,
    fillColor: Theme.of(context).flixColors.background.primary,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide.none,
    ),
    labelStyle: TextStyle(
      color: Theme.of(context).flixColors.text.tertiary, 
    ),
    floatingLabelBehavior: FloatingLabelBehavior.never, 
    hoverColor: Colors.transparent,
    contentPadding: const EdgeInsets.only(left: 16), 
  );
}




    @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return NavigationScaffold(
      title: _title,
      showBackButton: widget.showBack,
      builder: (EdgeInsets padding) {
        return Stack(
       children: [
          Container(
          margin: const EdgeInsets.only(top: 6),
          width: double.infinity,
          child: Column(
            children: [
              Expanded( 
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      color: Theme.of(context).flixColors.background.secondary,
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          
                          // 已经登录
                          if (_loggedInEmail != null) ...[
                            Text('已登录账户: $_loggedInEmail', style: const TextStyle(fontSize: 18)),
                            const SizedBox(height: 20),
                         
                          ],
                          // 未登录显示登录表单
                          if (_loggedInEmail == null && !_emailSubmitted) ...[
                            Container(
                              width: double.infinity, 
                              margin: const EdgeInsets.only(bottom: 10), 
                              child: Text(
                                '请输入邮箱',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context).flixColors.text.secondary,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            TextField(
                              controller: _emailController,
                              decoration: _buildInputDecoration('example@xx.com'),
                            ),
                            const SizedBox(height: 20),
                           
                          ],
                          if (_emailSubmitted && _isAccountExists) ...[
                               Container(
                              width: double.infinity, 
                              margin: const EdgeInsets.only(bottom: 10), 
                              child: Text(
                                '邮箱',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context).flixColors.text.secondary,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            Container(
                              width: double.infinity, 
                              height: 48, 
                              margin: const EdgeInsets.only(bottom: 10), 
                              padding: const EdgeInsets.symmetric(horizontal: 10), 
                              decoration: BoxDecoration(
                                color:  Theme.of(context).flixColors.background.primary, 
                                borderRadius: BorderRadius.circular(15), 
                              ),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  _emailController.text,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Theme.of(context).flixColors.text.secondary,
                                  ),
                                ),
                              ),
                            ),
                              Container(
                              width: double.infinity, 
                              margin: const EdgeInsets.only(bottom: 10,top: 10), 
                              child: Text(
                                '请输入密码',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context).flixColors.text.secondary,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            TextField(
                              controller: _passwordController,
                              decoration: _buildInputDecoration('密码'),
                              obscureText: true,
                            ),
                            const SizedBox(height: 20),
                          ],


                         

                          if (_emailSubmitted && !_isAccountExists && _isCodeSent && !_isVerified) ...[
                            Container(
                              width: double.infinity, 
                              margin: const EdgeInsets.only(bottom: 10), 
                              child: Text(
                                '邮箱',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context).flixColors.text.secondary,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            Container(
                              width: double.infinity, 
                              height: 48, 
                              margin: const EdgeInsets.only(bottom: 10), 
                              padding: const EdgeInsets.symmetric(horizontal: 10), 
                              decoration: BoxDecoration(
                                color:  Theme.of(context).flixColors.background.primary, 
                                borderRadius: BorderRadius.circular(15), 
                              ),
                              child: Align(
                                alignment: Alignment.centerLeft, 
                                child: Text(
                                  _emailController.text,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Theme.of(context).flixColors.text.secondary,
                                  ),
                                ),
                              ),
                            ),
                              Container(
                              width: double.infinity, 
                              margin: const EdgeInsets.only(bottom: 10,top: 10), 
                              child: Text(
                                '请输入验证码',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context).flixColors.text.secondary,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            TextField(
                              controller: _verificationCodeController,
                              decoration: _buildInputDecoration('输入验证码'),
                            ),
                            const SizedBox(height: 20),
                          ],
                          if (_isVerified) ...[
                            Container(
                              width: double.infinity, 
                              margin: const EdgeInsets.only(bottom: 10), 
                              child: Text(
                                '邮箱',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context).flixColors.text.secondary,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            Container(
                              width: double.infinity, 
                              height: 48,
                              margin: const EdgeInsets.only(bottom: 10), 
                              padding: const EdgeInsets.symmetric(horizontal: 10), 
                              decoration: BoxDecoration(
                                color:  Theme.of(context).flixColors.background.primary, 
                                borderRadius: BorderRadius.circular(15), 
                              ),
                              child: Align(
                                alignment: Alignment.centerLeft, 
                                child: Text(
                                  _emailController.text,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Theme.of(context).flixColors.text.secondary,
                                  ),
                                ),
                              ),
                            ),
                              Container(
                              width: double.infinity, 
                              margin: const EdgeInsets.only(bottom: 10,top: 10),
                              child: Text(
                                '请设置密码',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context).flixColors.text.secondary,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            TextField(
                              controller: _passwordController,
                              decoration: _buildInputDecoration('设置密码'),
                              obscureText: true,
                            ),
                            const SizedBox(height: 20),
                          ],
                          const SizedBox(height: 20),
                          if (_statusMessage.isNotEmpty) ...[
                            Text(
                              _statusMessage,
                              style:TextStyle(color: Theme.of(context).flixColors.text.secondary,),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // 按钮
              Padding(
                padding: const EdgeInsets.all(16.0), 
                child: Column(
                  children: [
                    if (_loggedInEmail == null && !_emailSubmitted)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20), 
                        child: SizedBox(
                          width: 140, 
                          height: 50, 
                          child: ElevatedButton(
                            onPressed: _checkAccountExists,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromRGBO(0, 122, 255, 1),
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              '下一步',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ),
                            
                          ),
                        ),
                      ),
                      if (_loggedInEmail == null && !_emailSubmitted)
                      Padding(
                          padding: const EdgeInsets.only(bottom: 100), 
                          child: Text(
                        '未注册用户将自动注册', 
                        style: TextStyle(
                          fontSize: 14, 
                          color: Theme.of(context).flixColors.text.secondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                       ),
                    
                    if (_emailSubmitted && _isAccountExists)
                     
                     Padding(
                        padding: const EdgeInsets.only(bottom: 120),
                      child: SizedBox(
                        width: 140,
                        height: 50, 
                        child: ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromRGBO(0, 122, 255, 1),
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            '登录',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      ),
                    if (_emailSubmitted && !_isAccountExists && _isCodeSent && !_isVerified)

                       Padding(
                        padding: const EdgeInsets.only(bottom: 120),
                      child: SizedBox(
                        width: 140, 
                        height: 50, 
                        child: ElevatedButton(
                          onPressed: _verifyCode,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromRGBO(0, 122, 255, 1),
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text(
                            '下一步',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                        ), ),
                      ),
                    if (_isVerified)
                       Padding(
                        padding: const EdgeInsets.only(bottom: 120),
                      child:SizedBox(
                        width: 140, 
                        height: 50, 
                        child: ElevatedButton(
                          onPressed: _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromRGBO(0, 122, 255, 1),
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text(
                            '完成注册',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),),
                    if (_loggedInEmail != null)
                       Padding(
                        padding: const EdgeInsets.only(bottom: 120),
                      child: SizedBox(
                        width: 140, 
                        height: 50, 
                        child: ElevatedButton(
                          onPressed: _logout,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text(
                            '退出登录',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                       ),
                 ],
                  ),
                ),
              ],
            ),
          ),
          // 全屏进度条
          if (_isSendingCode)
            Container(
              color: Colors.black.withOpacity(0),
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            ),
        ],
      );
    },
  );
}

 

  
}
