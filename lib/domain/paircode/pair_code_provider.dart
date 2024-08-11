import 'package:flix/domain/ship_server/ship_service_proxy.dart';
import 'package:flix/utils/net/net_utils.dart';
import 'package:flutter/foundation.dart';


class PairCodeProvider extends ChangeNotifier {
  String? _pairCode = null;
  List<NetInterface> _netInterfaces = [];
  int _port = 0;

  String? get pairCode => _pairCode;
  String? get pairCodeUri => "qrcode://pair/${Uri.encodeComponent(_pairCode ?? "")}";
  List<NetInterface> get netInterfaces => _netInterfaces;
  int get port => _port;


  void refreshPairCode() async {
    _netInterfaces = await getAvailableNetworkInterfaces();
    _port = await shipService.getPort();
    final ips = _netInterfaces.take(3).map((e) => e.address).toList();
    if (ips.isEmpty) {
      _pairCode = null;
    } else {
      _pairCode = encodeMultipleIpsAndPortToBase64(ips, _port);
    }
    notifyListeners();
  }


}