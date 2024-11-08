import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PaymentScreen extends StatefulWidget {
  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String? _userEmail;
  String? _vipDate;
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
  }

  // 从 SharedPreferences 加载用户邮箱
  Future<void> _loadUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userEmail = prefs.getString('loggedInEmail');
    });
    if (_userEmail != null) {
      _fetchVipDate();
    }
  }

  // 使用GET请求获取 VIP 日期
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

  // 调用 API 更新 VIP 日期
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
          _fetchVipDate(); // 更新 VIP 日期显示
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_userEmail ?? 'Payment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_vipDate != null)
              Text(
                'VIP 日期: $_vipDate',
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
            // 添加按钮
            ElevatedButton(
              onPressed: () => _updateVipDate(31),
              child: Text('增加 1 月 VIP'),
            ),
            ElevatedButton(
              onPressed: () => _updateVipDate(365),
              child: Text('增加1年 VIP'),
            ),
            ElevatedButton(
              onPressed: () => _updateVipDate(36500),
              child: Text('永久 VIP'),
            ),
          ],
        ),
      ),
    );
  }
}
