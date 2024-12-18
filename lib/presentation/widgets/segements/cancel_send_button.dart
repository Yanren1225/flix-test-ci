
import 'package:flix/domain/concert/concert_provider.dart';
import 'package:flix/model/ui_bubble/ui_bubble.dart';
import 'package:flix/theme/theme_extensions.dart';
import 'package:flix/utils/text/text_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:modals/modals.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../l10n/l10n.dart';

class CancelSendButtonState extends State<CancelSendButton> {
  late String anchorTag;

  @override
  void initState() {
    super.initState();
    anchorTag = const Uuid().v4();
  }

  @override
  void dispose() {
    removeModal(anchorTag);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final concertProvider = context.watch<ConcertProvider>();
    return ModalAnchor(
      tag: anchorTag,
      child: SizedBox(
        width: 20,
        height: 20,
        child: IconButton(
            iconSize: 20,
            padding: EdgeInsets.zero,
            onPressed: () {
              if (!context.mounted) {
                return;
              }
              showModal(ModalEntry.anchored(context,
                  tag: 'cancel_anchor_modal',
                  anchorTag: anchorTag,
                  aboveTag: anchorTag,
                  modalAlignment: Alignment.bottomLeft,
                  anchorAlignment: Alignment.topRight,
                  barrierColor: const Color.fromRGBO(0, 0, 0, 0.45),
                  removeOnPop: true,
                  barrierDismissible: true,
                  child: Material(
                    color: Theme.of(context).flixColors.background.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    child: InkWell(
                      onTap: () {
                        removeAllModals();
                        concertProvider.cancelSend(widget.entity);
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 20, top: 14, right: 40, bottom: 14),
                        child: Text(
                          S.of(context).button_cancel_send,
                          style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Color.fromRGBO(255, 59, 48, 1))
                              .fix(),
                        ),
                      ),
                    ),
                  )));
            },
            icon: SvgPicture.asset(
              'assets/images/ic_cancel.svg',
            )),
      ),
    );
  }
}

class CancelSendButton extends StatefulWidget {
  final UIBubble entity;

  const CancelSendButton({super.key, required this.entity});

  @override
  State<StatefulWidget> createState() => CancelSendButtonState();
}
