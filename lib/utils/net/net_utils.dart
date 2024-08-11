import 'dart:convert';
import 'dart:io';

import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/network/nearby_service_info.dart';
import 'package:flutter/foundation.dart';

enum NetworkType {
  Ethernet,
  WiFi,
  Other,
}

class NetInterface {
  final String name;
  final NetworkType type;
  final String address;

  NetInterface(this.name, this.type, this.address);

}

class PairInfo {
  final List<String> ips;
  final int port;

  PairInfo(this.ips, this.port);
}

String toNetAddress(String ip, int? port) {
  return '$ip:${port ?? defaultPort}';
}

Future<List<NetInterface>>
    getAvailableNetworkInterfaces() async {
  List<NetInterface> networkInterfaces = [];

  try {
    List<NetworkInterface> interfaces = await NetworkInterface.list(
        includeLoopback: false,
        includeLinkLocal: false,
        type: InternetAddressType.IPv4);
    for (var interface in interfaces) {
      NetworkType type;
      if (interface.name.startsWith('eth')) {
        type = NetworkType.Ethernet;
      } else if (interface.name.startsWith('wlan')) {
        type = NetworkType.WiFi;
      } else {
        type = NetworkType.Other;
      }

      final ip = interface.addresses.firstOrNull?.address;
      if (ip != null) {
        networkInterfaces.add(NetInterface(interface.name, type, ip));
      }
    }
  } catch (e, s) {
    talker.error('Failed to get network interfaces', e, s);
  }

  // 按照Wifi, Ethernet, Other的顺序给networkInterfaces排序
  networkInterfaces.sort((a, b) {
    if (a.type == NetworkType.WiFi) {
      return -1;
    } else if (b.type == NetworkType.WiFi) {
      return 1;
    } else if (a.type == NetworkType.Ethernet) {
      return -1;
    } else if (b.type == NetworkType.Ethernet) {
      return 1;
    } else {
      return 0;
    }
  });
  return networkInterfaces;
}

String encodeIpPortToBase64(String ip, int port) {
  // 将IP地址分割成4个字节
  List<String> ipParts = ip.split('.');
  Uint8List ipBytes = Uint8List(4);
  for (int i = 0; i < 4; i++) {
    ipBytes[i] = int.parse(ipParts[i]);
  }

  // 将端口转换为2个字节
  Uint8List portBytes = Uint8List(2);
  portBytes[0] = (port >> 8) & 0xFF;
  portBytes[1] = port & 0xFF;

  // 合并IP地址和端口的字节数组
  Uint8List combinedBytes = Uint8List(6);
  combinedBytes.setRange(0, 4, ipBytes);
  combinedBytes.setRange(4, 6, portBytes);

  // 编码为Base64字符串
  String base64Str = base64Encode(combinedBytes);

  return base64Str;
}

String encodeIpToBase64(String ip) {
  // 将IP地址分割成4个字节
  List<String> ipParts = ip.split('.');
  Uint8List ipBytes = Uint8List(4);
  for (int i = 0; i < 4; i++) {
    ipBytes[i] = int.parse(ipParts[i]);
  }

  // 编码为Base64字符串
  String base64Str = base64Encode(ipBytes);

  return base64Str;
}

String encodePortToBase64(int port) {
  // 将端口转换为2个字节
  Uint8List portBytes = Uint8List(2);
  portBytes[0] = (port >> 8) & 0xFF;
  portBytes[1] = port & 0xFF;

  // 编码为Base64字符串
  String base64Str = base64Encode(portBytes);

  return base64Str;
}

String encodeMultipleIpsAndPortToBase64(List<String> ips, int port) {
  // 将所有IP地址分割成字节数组
  List<int> ipBytes = [];
  for (String ip in ips) {
    List<String> ipParts = ip.split('.');
    for (String part in ipParts) {
      ipBytes.add(int.parse(part));
    }
  }

  // 将端口转换为字节数组
  Uint8List portBytes = Uint8List(2);
  portBytes[0] = (port >> 8) & 0xFF;
  portBytes[1] = port & 0xFF;

  // 合并IP地址和端口的字节数组
  Uint8List combinedBytes = Uint8List(ipBytes.length + portBytes.length);
  combinedBytes.setRange(0, ipBytes.length, ipBytes);
  combinedBytes.setRange(ipBytes.length, ipBytes.length + portBytes.length, portBytes);

  // 编码为Base64字符串
  String base64Str = base64Encode(combinedBytes);

  return base64Str;
}

PairInfo decodeBase64ToMultipleIpsAndPort(String base64Str) {
  // 解码Base64字符串为字节数组
  Uint8List bytes = base64Decode(base64Str);

  // 计算IP地址的数量
  int ipCount = (bytes.length - 2) ~/ 4;

  // 提取IP地址
  List<String> ips = [];
  for (int i = 0; i < ipCount; i++) {
    Uint8List ipBytes = bytes.sublist(i * 4, (i + 1) * 4);
    String ip = ipBytes.map((byte) => byte.toString()).join('.');
    ips.add(ip);
  }

  // 提取端口
  Uint8List portBytes = bytes.sublist(ipCount * 4, ipCount * 4 + 2);
  int port = (portBytes[0] << 8) + portBytes[1];

  return PairInfo(ips, port);
}

/// 验证IP地址是否合法
bool isValidIp(String ip) {
  if (ip.isEmpty) {
    return false;
  }

  List<String> parts = ip.split('.');
  if (parts.length != 4) {
    return false;
  }

  for (String part in parts) {
    int value = int.tryParse(part) ?? -1;
    if (value < 0 || value > 255) {
      return false;
    }
  }

  return true;
}

/// 验证端口是否合法
bool isValidPort(String port) {
  if (port.isEmpty) {
    return false;
  }

  int value = int.tryParse(port) ?? -1;
  return value >= 0 && value <= 65535;
}
