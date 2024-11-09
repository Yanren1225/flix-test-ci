import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flix/presentation/widgets/flix_bottom_sheet.dart';
import 'package:flix/theme/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class PayVIPScreen extends StatefulWidget {
  @override
  _PayVIPScreenState createState() => _PayVIPScreenState();
}

class _PayVIPScreenState extends State<PayVIPScreen> {
  String _payLink = '';
  String _orderId = '';
  bool _isCheckingStatus = false;
  String _paymentStatus = '未支付';
  final String _merchantId = '1000';
  final String _key = 'tM4mIOvt0ockkId38zIzV8IZ834fwiiZ';
  String? _userEmail;
  String? _vipDate;
  String _statusMessage = '';
  Timer? _statusCheckTimer;


  String type = 'alipay';
    String outTradeNo = DateTime.now().millisecondsSinceEpoch.toString();
    String notifyUrl = 'http://www.example.com/notify';
    String returnUrl = 'https://test-flix.cdnfree.cn/success.html';
    String name = 'Flix Elite For 30 Days';
    String money = '0.01';
    String clientIp = '192.168.1.100';
    String signType = 'MD5';
    String deviceType = 'mobile';

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

  // 生成支付链接并保存订单号
  Future<void> _generatePayLink() async {
    

    Map<String, String> params = {
      'pid': _merchantId,
      'type': type,
      'device': deviceType,
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
  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw '无法打开链接: $url';
    }
  }
    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      if (jsonResponse['code'] == 1) {
        setState(() {
          _payLink = jsonResponse['payurl'] ?? jsonResponse['qrcode'] ?? jsonResponse['urlscheme'];
          _orderId = outTradeNo;
          _paymentStatus = '支付链接已生成，等待支付';
        });
        _saveOrderId(_orderId);
        _startCheckingStatus();
        // 检测平台并在移动设备上打开链接
        if (Platform.isAndroid || Platform.isIOS) {
          _launchURL(_payLink);
        }
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

  // 保存订单号到数据库
  Future<void> _saveOrderId(String orderId) async {
    final url = Uri.parse('http://test-flix.cdnfree.cn/save_payid.php');
    final response = await http.post(url, body: {
      'email': _userEmail,
      'payid': orderId,
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
        _statusMessage = '无法保存订单号，请稍后再试。';
      });
    }
  }

 
  // 检查支付状态，最多检测600次
 void _startCheckingStatus() {
  setState(() {
    _isCheckingStatus = true;
  });

  int checkCount = 0;

  _statusCheckTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
    // 检查组件是否已被移除或计数已达到上限
    if (!_isCheckingStatus || !mounted || checkCount >= 600) {
      timer.cancel();
      if (mounted) {
        setState(() {
          _isCheckingStatus = false;
          if (checkCount >= 600) {
            _paymentStatus = '检测超时，停止检测';
          }
        });
      }
      return;
    }

    checkCount++;
    await _checkPaymentStatus();
  });
}


Future<void> _checkPaymentStatus() async {
  if (!mounted) return; // 在开始执行时检查挂载状态

  Uri url = Uri.parse(
      'https://payment-flix.cdnfree.cn/api.php?act=order&pid=$_merchantId&key=$_key&out_trade_no=$_orderId');
  http.Response response = await http.get(url);

  if (!mounted) return; // 再次检查挂载状态

  if (response.statusCode == 200) {
    var jsonResponse = json.decode(response.body);

    if (jsonResponse['code'].toString() == '1' && jsonResponse['status'].toString() == '1') {
      if (mounted) {
        setState(() {
          _paymentStatus = '支付成功，已增加30天VIP';
          _isCheckingStatus = false;
          _payLink = '';
        });
      }
      _updateVipDate(31);
      _deleteOrderId();
      _showSuccessBottomSheet();
    } else if (mounted) {
      setState(() {
        _paymentStatus = '支付未完成';
      });
    }
  } else if (mounted) {
    setState(() {
      _paymentStatus = '请求失败: ${response.statusCode}';
    });
  }
}


// 显示支付成功
void _showSuccessBottomSheet() {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return FlixBottomSheet(
        title: '支付成功',
        subTitle: '您的 VIP 已成功延长 30 天。',
        buttonText: '确认',
        onClickFuture: () async {
         Navigator.of(context).pop();
      },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            '感谢您支持 Flix Elite！',
            style: TextStyle(
              color: Theme.of(context).flixColors.text.primary,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      );
    },
  );
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
     _statusCheckTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).flixColors.background.secondary,
      appBar: AppBar(
        
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 60.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                   
                    const SizedBox(height: 30),
                    Text(
                      '￥$money',
                      style: const TextStyle(fontSize: 30),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).flixColors.text.secondary,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                  ],
                ),
              ),
            //  if (_vipDate != null)
               // Text(
               //   'VIP 到期日期: $_vipDate',
               //   style: const TextStyle(fontSize: 18),
              //  )
             // else if (_statusMessage.isNotEmpty)
             //   Text(
             //     _statusMessage,
             //     style: const TextStyle(fontSize: 16, color: Colors.red),
             //   )
            //  else
             //   const Center(child: CircularProgressIndicator()),
            //  const SizedBox(height: 20),
              ElevatedButton(
                onPressed:() async {
                  await _loadUserEmail();
                  _generatePayLink();

                } ,
                child: const Text('生成支付链接'),
              ),
             // 仅在桌面端显示二维码
            if (_payLink.isNotEmpty && (Platform.isMacOS || Platform.isWindows))
              Center(
                child: QrImageView(
                  data: _payLink,
                  version: QrVersions.auto,
                  size: 200.0,
                ),
              ),
              const SizedBox(height: 20),
         //     Text('支付状态: $_paymentStatus'),
            ],
          ),
        ),
      ),
    );
  }
}
