import 'dart:developer';

import 'package:flix/domain/concert/concert_provider.dart';
import 'package:flix/model/ui_bubble/ui_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:modals/modals.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class ResendButton extends  StatefulWidget {
  final UIBubble entity;
  // late String anchorTag;

  ResendButton({super.key, required this.entity}) {
    // anchorTag = 'resend_button_${entity.shareable.id}';
  }

  @override
  State<ResendButton> createState() => _ResendButtonState();
}

class _ResendButtonState extends State<ResendButton> {
  late String anchorTag;

  @override
  void initState() {
    super.initState();
    anchorTag = Uuid().v4();
  }

  @override
  void dispose() {
    removeModal(anchorTag);
    log('resend button disposed: $anchorTag');
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
              if (!context.mounted) {return;}
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
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    child: InkWell(
                      onTap: () {
                        removeAllModals();
                        concertProvider.resend(widget.entity);
                      },
                      child: const Padding(
                        padding:
                        EdgeInsets.only(left: 20, top: 14, right: 40, bottom: 14),
                        child: Text(
                          '重新发送',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color.fromRGBO(255, 59, 48, 1)),
                        ),
                      ),
                    ),
                  )));
            },
            icon: SvgPicture.asset(
              'assets/images/ic_trans_fail.svg',
            )),
      ),
    );

  }
}