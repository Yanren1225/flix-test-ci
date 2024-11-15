import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/presentation/basic/corner/flix_clip_r_rect.dart';
import 'package:flix/presentation/screens/main_screen.dart';
import 'package:flix/presentation/widgets/flix_toast.dart';
import 'package:flix/presentation/widgets/segements/cupertino_navigation_scaffold.dart';
import 'package:flix/presentation/widgets/segements/navigation_scaffold.dart';
import 'package:flix/theme/theme_extensions.dart';
import 'package:flix/presentation/screens/settings/dev/dev_config.dart';
import 'package:flix/utils/download_nonweb_logs.dart';
import 'package:flix/utils/text/text_extension.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:talker/talker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../l10n/l10n.dart';

class SettingPravicyScreen extends StatefulWidget {
  final bool showBack;

  const SettingPravicyScreen({super.key, this.showBack = true});

  @override
  State<StatefulWidget> createState() => SettingPravicyScreenState();
}

class SettingPravicyScreenState extends State<SettingPravicyScreen> {
  var versionTapCount = 0;
  int lastTapTime = 0;

  final ValueNotifier<String> _version = ValueNotifier('');

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((packageInfo) {
      _version.value = packageInfo.version;
    });
  }

     void clearThirdWidget() {
    Provider.of<BackProvider>(context, listen: false).backMethod();
  }

  @override
  Widget build(BuildContext context) {
    return NavigationScaffold(
        showBackButton: widget.showBack,
        title:'隐私政策',
       onClearThirdWidget: clearThirdWidget,
        builder: (EdgeInsets padding) {
           return Container(
            margin: const EdgeInsets.only( top: 10,right: 16,left: 16,bottom: 30),
          width: double.infinity,
            child: pra(),
           );
        });
  }

  Widget pra() {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 0),
    child: SingleChildScrollView(
      child: Align(
        alignment: Alignment.centerLeft, 
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start, 
          children: [
            const Text(
              '更新日期：2024年10月24日',
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.left,
            ),
            const Text(
              '生效日期：2024年10月24日',
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 10),
            const Text(
              'Flix（以下简称“本应用”）是一款通过局域网实现快速文件传输的工具。本隐私政策旨在阐明本应用在用户隐私和数据安全方面的原则和做法。我们致力于保护您的隐私，并遵循相关法律法规的要求。',
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.left,
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
              '如您对本隐私政策有任何疑问或疑虑，请通过以下方式联系我们：\n用户QQ群1：539943326\n用户QQ群2：992894289\n用户QQ群3：779244909',
            ),
            const SizedBox(height: 10),
            buildSectionTitle('本协议适用于所有使用 Flix 的用户。'),
          ],
        ),
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

  
}
