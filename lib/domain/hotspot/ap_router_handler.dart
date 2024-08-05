import 'package:flix/domain/router_handler.dart';
import 'package:flix/presentation/screens/hotpots/connect_hotspot_screen.dart';
import 'package:flutter/cupertino.dart';

class ApRouterHandler implements RouterHandler {
  @override
  final String host = 'ap';

  @override
  Future<bool> handle(BuildContext context, Uri uri) async {
    if (uri.pathSegments.length >= 2) {
      Navigator.of(context).pushReplacement(CupertinoPageRoute(
        builder: (context) => ConnectHotspotScreen(
          apSSID: uri.pathSegments[0],
          apKey: uri.pathSegments[1],
        ),
      ));
      return true;
    }
    return false;
  }
}