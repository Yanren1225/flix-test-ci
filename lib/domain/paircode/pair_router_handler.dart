
import 'package:flix/domain/device/device_discover.dart';
import 'package:flix/domain/router_handler.dart';
import 'package:flix/domain/ship_server/ship_service_proxy.dart';
import 'package:flix/network/discover/network_connect_manager.dart';
import 'package:flix/network/protocol/device_modal.dart';
import 'package:flix/presentation/widgets/flix_toast.dart';
import 'package:flix/utils/net/net_utils.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/widgets.dart';
import 'package:simple_loading_dialog/simple_loading_dialog.dart';

class PairRouterHandler implements RouterHandler {
  static final deviceDiscover = DeviceDiscover.instance;

  @override
  Future<bool> handle(BuildContext context, Uri uri) async {
    Future<bool> handleUri() {
      final path = Uri.decodeComponent(uri.path).substring(1);
      final result = decodeBase64ToMultipleIpsAndPort(path);
      return addDevice(result);
    }
    final result = await showSimpleLoadingDialog<bool>(
      context: context,
      future: handleUri,
    );
    if (context.mounted) {
      Navigator.of(context).pop();
    }
    if (result) {
      flixToast.info("添加成功");
    } else {
      flixToast.info("添加失败");
    }
    return result;
  }

  static Future<bool> addDevice(PairInfo pairInfo) async {
    for (final ip in pairInfo.ips) {
      if (await NetworkConnectManager.instance.connect(DeviceFrom.manual, ip)) {
        return true;
      }
    }
    return false;
  }

  @override
  String host = "pair";
}
