import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flix/presentation/screens/account/pay.dart';
import 'package:flix/presentation/widgets/flix_bottom_sheet.dart';
import 'package:flix/theme/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class PayScreen extends StatefulWidget {
  @override
  _PayScreenState createState() => _PayScreenState();
}

class _PayScreenState extends State<PayScreen> {
  String _payLink = '';
  String _orderId = '';
  bool _isCheckingStatus = false;
  String _paymentStatus = '未支付';
  final String _merchantId = '1000';
  final String _key = 'tM4mIOvt0ockkId38zIzV8IZ834fwiiZ';
  String? _userEmail;
  String? _vipDate;
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
  }

  // 检查未完成的支付订单
  Future<void> _loadUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userEmail = prefs.getString('loggedInEmail');
    });
    if (_userEmail != null) {
      await _checkPendingPayment(); 
      _fetchVipDate();
    }
  }

  
  Future<void> _checkPendingPayment() async {
    final url = Uri.parse('http://test-flix.cdnfree.cn/get_payid.php?email=$_userEmail');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['status'] == 'success' && responseData['payid'] != null) {
        _orderId = responseData['payid'];
        await _checkPaymentStatus(); 
      }
    }
  }

  
  Future<void> _fetchVipDate() async {
    final url = Uri.parse('http://test-flix.cdnfree.cn/get_vip_date.php?email=$_userEmail');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      setState(() {
        if (responseData['status'] == 'success') {
          _vipDate = responseData['vip_date'];
        } else {
          _statusMessage = responseData['message'];
        }
      });
    } else {
      setState(() {
        _statusMessage = '无法获取 VIP 日期，请稍后再试。';
      });
    }
  }

  // 更新 VIP 日期
  Future<void> _updateVipDate(int days) async {
    final url = Uri.parse('http://test-flix.cdnfree.cn/update_vip_date.php');
    final response = await http.post(url, body: {
      'email': _userEmail,
      'days': days.toString(),
    });

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      setState(() {
        if (responseData['status'] == 'success') {
          _statusMessage = 'VIP 日期已更新';
          _fetchVipDate();
        } else {
          _statusMessage = responseData['message'];
        }
      });
    } else {
      setState(() {
        _statusMessage = '无法更新 VIP 日期，请稍后再试。';
      });
    }
  }

  // 生成 MD5 签名
  String generateMD5Sign(Map<String, String> params, String key) {
    params.removeWhere((k, v) => k == 'sign' || k == 'sign_type' || v.isEmpty);
    var sortedKeys = params.keys.toList()..sort();
    String signStr = sortedKeys.map((k) => '$k=${params[k]}').join('&');
    String finalStr = '$signStr$key';
    return md5.convert(utf8.encode(finalStr)).toString();
  }

 
  Future<void> _checkPaymentStatus() async {
    Uri url = Uri.parse(
        'https://payment-flix.cdnfree.cn/api.php?act=order&pid=$_merchantId&key=$_key&out_trade_no=$_orderId');
    http.Response response = await http.get(url);

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);

      if (jsonResponse['code'].toString() == '1' && jsonResponse['status'].toString() == '1') {
        setState(() {
          _paymentStatus = '支付成功，已增加30天VIP';
          _isCheckingStatus = false;
          _payLink = '';
        });
        _updateVipDate(31);
        _deleteOrderId();
      
      } else {
        setState(() {
          _paymentStatus = '支付未完成';
        });
      }
    } else {
      setState(() {
        _paymentStatus = '请求失败: ${response.statusCode}';
      });
    }
  }




  // 删除订单号
  Future<void> _deleteOrderId() async {
    final url = Uri.parse('http://test-flix.cdnfree.cn/delete_payid.php');
    final response = await http.post(url, body: {
      'email': _userEmail,
    });

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['status'] != 'success') {
        setState(() {
          _statusMessage = responseData['message'];
        });
      }
    } else {
      setState(() {
        _statusMessage = '无法删除订单号，请稍后再试。';
      });
    }
  }

  @override
  void dispose() {
    _isCheckingStatus = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).flixColors.background.secondary,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 60.0,left: 16,right: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    SvgPicture.asset(
                      'assets/images/elite.svg',
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                     
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      '成为 Flix Elite 用户',
                      style: TextStyle(fontSize: 30),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '升级到 Flix Elite，为 Flix 添砖加瓦，',
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).flixColors.text.secondary,
                      ),
                    ),
                    Text(
                      '我们也为你准备了以下功能：',
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).flixColors.text.secondary,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(
                  maxWidth: 450, 
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).flixColors.background.primary,
                  border: Border.all(
                    color: Color.fromRGBO(7, 144, 255, 1),
                    width: 1.6,
                  ),
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '30天订阅',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '请我们喝一杯奶茶',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '¥ 0.01',
                        style: TextStyle(
                          fontSize: 18,
                          color: Color.fromRGBO(7, 144, 255, 1),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
            
              ElevatedButton(
                onPressed: (){
                    Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => PayVIPScreen()),
                                );
                },
                child: const Text('订阅'),
              ),
            
         //     Text('支付状态: $_paymentStatus'),
            ],
          ),
        ),
      ),
    );
  }
}
