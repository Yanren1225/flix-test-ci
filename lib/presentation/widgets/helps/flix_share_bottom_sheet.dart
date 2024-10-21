import 'package:flix/presentation/style/colors/flix_color.dart';
import 'package:flix/presentation/widgets/flix_bottom_sheet.dart';
import 'package:flix/presentation/widgets/flix_toast.dart';
import 'package:flix/theme/theme_extensions.dart';
import 'package:flix/utils/text/text_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../l10n/l10n.dart';

class FlixShareBottomSheet extends StatelessWidget {
  const FlixShareBottomSheet(BuildContext context, {super.key});

  @override
  Widget build(BuildContext context) {
    return FlixBottomSheet(
      title: S.of(context).share_flix,
      buttonText: S.of(context).share_flix_action,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ConstrainedBox(
                      constraints:
                          const BoxConstraints(maxHeight: 200, maxWidth: 200),
                      child: QrImageView(
                          eyeStyle: QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: Theme.of(context).flixColors.text.primary,
                          ),
                          dataModuleStyle: QrDataModuleStyle(
                              dataModuleShape: QrDataModuleShape.square,
                              color: Theme.of(context).flixColors.text.primary),
                          data: "https://flix.center/?utm_source=app_share",
                          padding: const EdgeInsets.all(0))),
                  Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: GestureDetector(
                          child: Text(S.of(context).share_flix_website,
                              style: const TextStyle(
                                      color: FlixColor.blue,
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal)
                                  .fix()),
                          onTap: () {
                            Clipboard.setData(const ClipboardData(
                                text: "https://flix.center"));
                            flixToast.info(S.of(context).share_flix_copied);
                          })),
                ],
              ),
            ]),
      ),
    );
  }
}
