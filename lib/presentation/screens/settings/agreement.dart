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



class SettingAgreementScreen extends StatefulWidget {
  final bool showBack;

  const SettingAgreementScreen({super.key, this.showBack = true});

  @override
  State<StatefulWidget> createState() => SettingAgreementScreenState();
}

class SettingAgreementScreenState extends State<SettingAgreementScreen> {
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
        toolbarCoverBody: true,
        title:'用户协议',
         onClearThirdWidget: clearThirdWidget,
        builder: (padding) {
          final widgets = <Widget>[
            pra(),
            
         
         
            
          ];
          return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(
                      decelerationRate: ScrollDecelerationRate.fast)),
              padding: padding.copyWith(
                  bottom: padding.bottom +
                      MediaQuery.of(context).padding.bottom +
                      20),
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(
                      left: 16.0, right: 16.0, top: 12, bottom: 12),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: DecoratedBox(
                        decoration: BoxDecoration(
                            color:
                                Theme.of(context).flixColors.background.secondary,
                            borderRadius: BorderRadius.circular(10)),
                        child: widgets[index]),
                  ),
                );
              },
              itemCount: widgets.length);
        });
  }

  Widget pra() {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 0),
    child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start, 
        children: [
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
                      '请您仔细阅读以下用户协议（以下简称“本协议”），它约束了您（以下简称“用户”或“您”）与Flix应用程序（以下简称“本应用”或“我们”）之间的权利与义务。通过下载、安装或使用本应用，您即表示接受并同意遵守本协议中的所有条款。如果您不同意这些条款，请立即停止使用本应用。',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 10),
                    buildSectionTitle('1. 使用许可'),
                    buildSectionContent(
                      '根据本协议的条款和条件，Flix授予您一项非排他性、不可转让、不可再许可的有限使用许可，允许您仅出于个人、非商业目的下载、安装和使用本应用。该许可仅适用于合法用途，并受限于以下规定：',
                    ),
                    buildBulletPoint('本应用仅用于通过局域网进行本地设备之间的文件传输。'),
                    buildBulletPoint('您不得将本应用用于任何非法、违反公共政策或本协议条款的用途。'),
                    buildSectionTitle('2. 用户的责任和义务'),
                    buildSectionContent(
                      '在使用本应用时，用户需承诺遵守所有适用的法律法规，并不得从事任何可能损害本应用或其他用户权益的行为。具体包括但不限于以下条款：',
                    ),
                    buildSectionContent('2.1 禁止行为'),
                    buildBulletPoint('禁止逆向工程、反编译、反汇编：用户不得对本应用进行逆向工程、反编译、反汇编，或以其他方式试图获取本应用的源代码、设计、架构等技术细节。'),
                    buildBulletPoint('禁止修改或制作衍生作品：用户不得修改、改编或创建本应用的任何衍生作品，亦不得删除、修改或隐藏本应用的任何标识或提示信息。'),
                    buildBulletPoint('禁止绕过技术保护措施：用户不得规避、破解或绕过本应用为保护其内容和功能而设计的任何安全机制或技术措施。'),
                   buildSectionContent('2.2 内容传输'),
                   buildSectionContent('用户在使用本应用进行文件传输时，需确保其传输的内容符合以下要求：'),
                   buildBulletPoint('禁止传输非法或有害内容：用户不得通过本应用传输任何非法、有害、威胁性、侮辱性、诽谤性、淫秽、侵犯他人隐私或违反法律的内容，包括但不限于侵犯他人合法权益的文件。'),
                   buildBulletPoint('禁止传输恶意软件：用户不得通过本应用传输任何包含恶意代码、病毒、特洛伊木马或其他破坏性程序的文件。'),
                   buildBulletPoint('遵守数据保护法：用户在传输涉及他人个人信息的文件时，需确保符合所有适用的数据保护和隐私法律，且已获得必要的授权。'),
                    buildSectionTitle('3. 应用权限及合规使用'),
                    buildSectionContent(
                      '为了保证本应用的正常运行，您可能需要授予我们访问某些设备权限，例如存储权限和网络权限。我们将严格按照最小权限原则申请和使用这些权限，详见《Flix 隐私政策》。',
                    ),
                    buildSectionContent(
                      '所有权限的使用均严格限定在本应用的正常功能范围内，且用户可以随时在设备设置中管理这些权限。',
                    ),
                    buildSectionTitle('4. 数据安全'),
                    buildSectionContent(
                      '尽管本应用不存储任何传输数据，我们仍采取合理的技术和组织措施，确保您在使用过程中的数据隐私和安全。',
                    ),
                    buildBulletPoint('传输安全：本应用所有的文件传输均限于局域网设备之间，不经过任何外部服务器。传输过程完全由用户控制，我们不参与数据的存储、查看或备份。'),
                    buildBulletPoint('用户责任：用户需对其传输的文件及其内容负责。我们不承担因用户传输违法或违规内容而产生的法律责任。'),
                    buildSectionTitle('5. 终止'),
                    buildSectionContent(
                      '在以下情况下，我们保留立即终止或暂停您的使用许可的权利：',
                    ),
                    buildBulletPoint('您违反了本协议的任何条款；'),
                    buildBulletPoint('您使用本应用进行非法、欺诈或恶意活动；'),
                    buildBulletPoint('您试图干扰或破坏本应用的正常运行。'),
                    buildSectionContent('在终止后，您必须立即停止使用本应用，并删除所有相关的副本和文件。'),
                    buildSectionTitle('6. 免责声明'),
                    buildSectionContent(
                      '本应用按“现状”提供，Flix对其性能、功能和可用性不作任何明示或暗示的保证。在适用法律允许的最大范围内，以下免责声明条款适用于您使用本应用的所有情形。',
                    ),
                    buildSectionContent('6.1 性能与可用性'),
                    buildBulletPoint('我们不对本应用的性能、功能性或其是否能满足用户的特定需求做出任何明示或暗示的保证。我们不保证应用始终无中断、延迟、错误或缺陷，也不保证文件传输过程中的数据完整性或准确性。'),
                    buildBulletPoint('我们不对本应用在任何特定设备、操作系统或硬件环境下的兼容性作出保证。不同设备和系统配置可能影响应用的运行效果，用户应自行承担相应风险。'),
                    buildSectionContent('6.2 数据安全与隐私'),
                    buildBulletPoint('数据安全的限制：尽管我们采取合理措施保护数据传输过程中的安全，但我们不对传输数据的绝对安全性作出担保。用户在局域网环境中使用本应用时，应了解并接受潜在的安全风险，尤其是在网络环境不安全的情况下。'),
                    buildBulletPoint('隐私风险：本应用不收集或存储用户数据，但我们无法控制或监控用户传输的内容。如果用户通过本应用传输敏感或机密信息，需自行承担相应的隐私风险。'),
                    buildSectionContent('6.3 责任限制'),
                    buildSectionContent('在适用法律允许的最大范围内，对于因使用或无法使用本应用所引发的任何直接、间接、附带、特殊、惩罚性或后果性损害，包括但不限于以下情形，我们概不负责：'),
                    buildBulletPoint('数据丢失或损坏：用户传输的文件可能因设备故障、网络问题或其他技术原因而丢失、损坏或无法恢复。我们不对任何数据丢失、损坏或无法传输承担责任。'),
                    buildBulletPoint('业务中断：我们不对因本应用无法正常运行、功能限制或故障导致的业务中断、收入损失或生产效率下降负责。'),
                    buildBulletPoint('设备或系统损害：我们不对因用户安装或使用本应用而导致的任何设备、系统或数据的损坏承担责任，用户应自行承担这些风险。'),
                    buildSectionContent('6.4 法律责任'),
                    buildBulletPoint('用户行为责任：用户应对其在使用本应用过程中所作出的所有行为承担责任，包括但不限于因传输非法或侵权内容而产生的法律责任。我们不对用户在使用本应用时产生的任何法律后果负责。'),
                    buildBulletPoint('第三方风险：我们不对用户因使用本应用而接触或依赖的任何第三方网络、设备或服务的安全性、可靠性或功能性负责，用户需自行承担相关风险。'),
                    buildBulletPoint('不可抗力事件：在不可抗力事件（包括但不限于自然灾害、战争、网络攻击或政府行为）导致的服务中断、数据丢失或其他损害情况下，我们不承担任何责任。'),
                    buildSectionContent('6.5 传输内容的限制'),
                    buildSectionContent('我们不对用户传输的内容进行任何审核或监督，用户需自行承担因传输内容产生的任何法律或民事责任。用户应确保其通过本应用传输的文件不违反任何适用的法律法规，包括但不限于数据保护法、版权法或其他相关法律。'),
                    buildSectionTitle('7. 适用法律和争议解决'),
                    buildSectionContent(
                      '本协议受中华人民共和国法律管辖。任何因本协议引发的争议，应首先通过友好协商解决；若协商不成，双方同意将争议提交至法院进行裁决。'
                      
                    ),
                    buildSectionTitle('8. 协议变更'),
                    buildSectionContent('我们保留在任何时候对本协议进行修改的权利。如果我们对本协议做出重大修改，我们将在本应用内显著位置通知用户。继续使用本应用即表示您接受修改后的条款。'),
                    buildSectionTitle('9. 联系我们'),
                    buildSectionContent('如您对本协议有任何疑问，或需要与我们联系解决任何问题，请通过以下方式联系我们：\n'
                    '用户QQ群1：539943326\n用户QQ群2：992894289\n用户QQ群3：779244909',),

                    const SizedBox(height: 10),
                    buildSectionTitle('本协议适用于所有使用 Flix 的用户。'),
                
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

  
}
