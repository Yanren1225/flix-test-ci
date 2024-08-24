import 'package:flix/network/discover/discover_param.dart';

abstract class DiscoverApi {
  Future<void> startScan(DiscoverParam param);
  void stop();
  void initConfig();
  String getFrom();
}
