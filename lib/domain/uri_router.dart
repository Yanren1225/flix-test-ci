import 'package:flix/domain/router_handler.dart';
import 'package:flutter/cupertino.dart';

class UriRouter {
  final Map<String, RouterHandler> _handlers = {};

  Future<bool> navigateTo(BuildContext context, String uri) async {
    final parsedUri = Uri.parse(uri);
    final handler = _handlers[parsedUri.host];
    if (handler != null) {
      return handler.handle(context, parsedUri);
    }
    return false;
  }

  void registerHandler(String host, RouterHandler handler) {
    _handlers[host] = handler;
  }
}

final uriRouter = UriRouter();
