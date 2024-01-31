import 'package:androp/model/device_info.dart';
import 'package:flutter/material.dart';

class ConcertProvider extends ChangeNotifier {
  final DeviceInfo deviceInfo;

  ConcertProvider({required this.deviceInfo});
}
