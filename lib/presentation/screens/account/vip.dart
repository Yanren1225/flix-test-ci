import 'dart:convert';
import 'dart:async';
import 'package:flix/theme/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    Future<void> _loadUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userEmail = prefs.getString('loggedInEmail');
    });
    if (_userEmail != null) {
      _fetchVipDate();
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

  
  String generateMD5Sign(Map<String, String> params, String key) {
    params.removeWhere((k, v) => k == 'sign' || k == 'sign_type' || v.isEmpty);
    var sortedKeys = params.keys.toList()..sort();
    String signStr = sortedKeys.map((k) => '$k=${params[k]}').join('&');
    String finalStr = '$signStr$key';
    return md5.convert(utf8.encode(finalStr)).toString();
  }

  
  Future<void> _generatePayLink() async {
    String type = 'alipay';
    String outTradeNo = DateTime.now().millisecondsSinceEpoch.toString();
    String notifyUrl = 'http://www.example.com/notify';
    String returnUrl = 'http://www.example.com/return';
    String name = 'Flix Elite For 30 Days';
    String money = '0.01';
    String clientIp = '192.168.1.100';
    String signType = 'MD5';

    Map<String, String> params = {
      'pid': _merchantId,
      'type': type,
      'out_trade_no': outTradeNo,
      'notify_url': notifyUrl,
      'return_url': returnUrl,
      'name': name,
      'money': money,
      'clientip': clientIp,
    };

    String sign = generateMD5Sign(params, _key);
    params['sign'] = sign;
    params['sign_type'] = signType;

    Uri url = Uri.parse('https://payment-flix.cdnfree.cn/mapi.php');
    Map<String, String> headers = {'Content-Type': 'application/x-www-form-urlencoded'};

    http.Response response = await http.post(url, headers: headers, body: params);

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      if (jsonResponse['code'] == 1) {
        setState(() {
          _payLink = jsonResponse['payurl'] ?? jsonResponse['qrcode'] ?? jsonResponse['urlscheme'];
          _orderId = outTradeNo; // 保存订单号用于后续查询
          _paymentStatus = '支付链接已生成，等待支付';
        });

        
        _startCheckingStatus();
      } else {
        setState(() {
          _payLink = '支付失败: ${jsonResponse['msg']}';
        });
      }
    } else {
      setState(() {
        _payLink = '请求失败: ${response.statusCode}';
      });
    }
  }

  
  void _startCheckingStatus() {
    setState(() {
      _isCheckingStatus = true;
    });
    Timer.periodic(Duration(seconds: 1), (timer) async {
      if (!_isCheckingStatus) {
        timer.cancel();
      } else {
        await _checkPaymentStatus();
      }
    });
  }

  // 查询支付状态
  Future<void> _checkPaymentStatus() async {
    Uri url = Uri.parse(
        'https://payment-flix.cdnfree.cn/api.php?act=order&pid=$_merchantId&key=$_key&out_trade_no=$_orderId');
    http.Response response = await http.get(url);

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      print('订单查询响应: $jsonResponse'); 
      print('code类型: ${jsonResponse['code'].runtimeType}, status类型: ${jsonResponse['status'].runtimeType}'); 

      
      if (jsonResponse['code'].toString() == '1' && jsonResponse['status'].toString() == '1') {
        setState(() {
          _paymentStatus = '支付成功，已增加30天VIP';
          _isCheckingStatus = false; 
          _payLink = ''; 
        });
        _updateVipDate(31);
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

  @override
  void dispose() {
    _isCheckingStatus = false; 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Theme.of(context).flixColors.background.secondary, // 设置背景颜色
    body: Center( // 将内容居中
      child: Padding(
        padding: const EdgeInsets.only(top:60.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, // 水平居中
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  SvgPicture.asset(
                    'assets/images/ic_cross_device.svg',
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Theme.of(context).flixColors.text.primary,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    '成为 Flix Elite 用户',
                    style: const TextStyle(fontSize: 30),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '升级到 Flix Elite，为 Flix 添砖加瓦，我们也为你准备了以下功能：',
                    style: TextStyle(
                      fontSize: 16,
                  
                      color: Theme.of(context).flixColors.text.secondary,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                ],
              ),
            ),
            if (_vipDate != null)
              Text(
                'VIP 到期日期: $_vipDate',
                style: TextStyle(fontSize: 18),
              )
            else if (_statusMessage.isNotEmpty)
              Text(
                _statusMessage,
                style: TextStyle(fontSize: 16, color: Colors.red),
              )
            else
              Center(child: CircularProgressIndicator()),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _generatePayLink,
              child: Text('生成支付链接'),
            ),
            if (_payLink.isNotEmpty)
              Center(
                child: QrImageView(
                  data: _payLink,
                  version: QrVersions.auto,
                  size: 200.0,
                ),
              ),
            SizedBox(height: 20),
            Text('支付状态: $_paymentStatus'),
          ],
        ),
      ),
    ),
  );
}

}
