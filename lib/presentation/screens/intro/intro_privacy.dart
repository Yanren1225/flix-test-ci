import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flix/theme/theme_extensions.dart'; 

class IntroPrivacyPage extends StatefulWidget {
  const IntroPrivacyPage({Key? key}) : super(key: key);

  @override
  _IntroPrivacyPageState createState() => _IntroPrivacyPageState();
}

class _IntroPrivacyPageState extends State<IntroPrivacyPage> {
  @override
  void initState() {
    super.initState();
  }

   @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initSystemChrome();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Theme.of(context).flixColors.background.secondary;
   
    final double statusBarHeight = (Platform.isWindows || Platform.isLinux || Platform.isMacOS) 
      ? 10.0 
      : MediaQuery.of(context).padding.top;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        color: backgroundColor,
        child: Column(
          children: [
          
            Container(
              padding: EdgeInsets.only(top: statusBarHeight, left: 16, right: 16),
              color: backgroundColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon:  Icon(Icons.arrow_back, color: Theme.of(context).flixColors.text.primary),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                   Expanded(
                    child: Text(
                      '隐私政策',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 18,
                       
                        color: Theme.of(context).flixColors.text.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), 
                ],
              ),
            ),
          
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView(
                   padding: const EdgeInsets.only(top: 10), 
                  children: [
                  
                    const Text(
                      'Flix 隐私政策',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      '更新日期：2024年10月24日',
                      style: TextStyle(fontSize: 14),
                    ),
                    const Text(
                      '生效日期：2024年10月24日',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Flix（以下简称“本应用”）是一款通过局域网实现快速文件传输的工具。本隐私政策旨在阐明本应用在用户隐私和数据安全方面的原则和做法。我们致力于保护您的隐私，并遵循相关法律法规的要求。',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 10),
                    buildSectionTitle('1. 信息的收集和使用'),
                    buildSectionContent(
                      '本应用在运行过程中不收集、存储或传输任何个人身份信息。我们不会将您的数据传输至第三方，也不会存储您传输的文件或相关信息。所有操作和数据均在设备本地完成。',
                    ),
                    buildSectionTitle('2. 权限申请及其用途'),
                    buildSectionContent(
                      '为了确保本应用功能的正常运行，您在使用过程中可能需要授予以下权限。我们将严格遵循最小权限原则，仅在必需时申请并使用这些权限。',
                    ),
                    buildBulletPoint('WiFi权限：用于扫描附近的设备，以发现可用的局域网连接。本权限不会用于连接互联网或收集其他网络信息。'),
                    buildBulletPoint('存储权限：用于保存用户接收到的文件。该权限仅用于存储传输文件，不会访问其他文件或数据。'),
                    buildBulletPoint('通知权限：用于通知用户收到新文件。该权限仅限于显示与文件传输相关的通知，不会推送其他类型的消息。'),
                    buildBulletPoint('定位权限：用于获取设备的网络名称，以帮助识别局域网中的其他设备。该权限不会收集精确的地理位置信息。'),
                    buildBulletPoint('相机权限：用于扫描二维码，帮助快速连接设备进行文件传输。该权限仅限于文件传输过程中的二维码扫描，不会用于其他目的。'),
                    buildSectionTitle('3. 数据安全'),
                    buildSectionContent(
                      '虽然本应用不收集任何个人数据，但我们通过合理的技术措施来确保文件传输的安全性。所有文件传输均仅在设备之间进行，不涉及第三方服务器或云存储。',
                    ),
                    buildSectionTitle('4. 第三方服务'),
                    buildSectionContent(
                      '本应用不使用任何第三方服务进行文件传输或数据处理。您的所有文件和信息都仅在设备之间进行传输，不涉及任何外部服务器或服务，因此不会向第三方共享您的任何个人信息或数据。',
                    ),
                    buildSectionTitle('5. 隐私政策的变更'),
                    buildSectionContent(
                      '我们保留在必要时更新此隐私政策的权利。若隐私政策发生重大变更，我们将在应用内显著位置发布更新通知，并提供清晰的说明，以确保您了解最新的隐私政策内容。我们建议您定期查看隐私政策的更新，以便了解我们如何保护您的隐私。',
                    ),
                   
                    buildSectionTitle('6. 适用法律和争议解决'),
                    buildSectionContent(
                      '本隐私政策受您所在国家或地区的法律约束。若因本应用的隐私政策或数据使用问题引发任何争议，您有权通过法律途径寻求解决。我们将积极配合并遵守相关法律法规，以保障您的合法权益。',
                    ),
                    buildSectionTitle('7. 联系我们'),
                    buildSectionContent(
                      '如您对本隐私政策有任何疑问或疑虑，请通过以下方式联系我们：\n'
                      '用户QQ群1：539943326\n用户QQ群2：992894289\n用户QQ群3：779244909',
                    ),
                    const SizedBox(height: 10),
                    buildSectionTitle('本协议适用于所有使用 Flix 的用户。\n\n\n'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget buildBulletPoint(String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 14)),
          Expanded(
            child: Text(content, style: const TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget buildSectionContent(String content, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Text(
        content,
        style: TextStyle(
          fontSize: 14,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  void _initSystemChrome() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Theme.of(context).flixColors.background.secondary, // 状态栏颜色与自定义栏一致
        statusBarIconBrightness: Brightness.dark, // 状态栏图标颜色
        systemNavigationBarColor: Colors.transparent, // 底部导航栏透明
        systemNavigationBarIconBrightness: Brightness.dark, // 底部导航栏图标颜色
      ),
    );
  }
}
