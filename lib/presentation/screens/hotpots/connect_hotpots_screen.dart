import 'package:flutter/cupertino.dart';
import 'package:wifi_iot/wifi_iot.dart';

class ConnectHotpotsScreen extends StatefulWidget {
  final String apSSID;
  final String apKey;

  const ConnectHotpotsScreen({super.key, required this.apSSID, required this.apKey});

  @override
  State<StatefulWidget> createState() {
    return ConnectHotpotsScreenState();
  }

}

class ConnectHotpotsScreenState extends State<ConnectHotpotsScreen> {

  @override
  void initState() {
    super.initState();
    WiFiForIoTPlugin.setEnabled(true, shouldOpenSettings: true);
    WiFiForIoTPlugin.connect(widget.apSSID, password: widget.apKey, security: NetworkSecurity.WPA).then((value) {
      if (value) {
        WiFiForIoTPlugin.forceWifiUsage(true);
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Text("正在连接");
  }

}