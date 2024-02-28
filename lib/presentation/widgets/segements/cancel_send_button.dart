import 'package:androp/domain/concert/concert_provider.dart';
import 'package:androp/model/ui_bubble/ui_bubble.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:modals/modals.dart';
import 'package:provider/provider.dart';

class CancelSendButton extends  StatelessWidget {
  final UIBubble entity;

  const CancelSendButton({super.key, required this.entity});

  @override
  Widget build(BuildContext context) {
    final concertProvider = context.watch<ConcertProvider>();
    return ModalAnchor(
      tag: 'cancel_anchor',
      child: IconButton(
          onPressed: () {
            showModal(ModalEntry.anchored(context,
                tag: 'cancel_anchor_modal',
                anchorTag: 'cancel_anchor',
                aboveTag: 'cancel_anchor',
                barrierColor: const Color.fromRGBO(0, 0, 0, 0.45),
                removeOnPop: true,
                barrierDismissible: true,
                child: Material(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  child: InkWell(
                    onTap: () {
                      concertProvider.cancel(entity);
                    },
                    child: const Padding(
                      padding:
                      EdgeInsets.only(left: 20, top: 14, right: 40, bottom: 14),
                      child: Text(
                        '取消发送',
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
            'assets/images/ic_cancel.svg',
          )),
    );

  }
}