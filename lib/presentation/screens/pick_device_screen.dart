import 'dart:developer';

import 'package:flix/domain/androp_context.dart';
import 'package:flix/domain/ship_server/ship_service.dart';
import 'package:flix/model/device_info.dart';
import 'package:flix/model/ship/primitive_bubble.dart';
import 'package:flix/model/ui_bubble/shareable.dart';
import 'package:flix/model/ui_bubble/shared_file.dart';
import 'package:flix/model/ui_bubble/ui_bubble.dart';
import 'package:flix/network/multicast_client_provider.dart';
import 'package:flix/presentation/screens/concert_screen.dart';
import 'package:flix/presentation/widgets/devices/device_list.dart';
import 'package:flix/utils/device/device_utils.dart';
import 'package:flix/utils/file/file_helper.dart';
import 'package:flix/utils/meida/media_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_handler/share_handler.dart';
import 'package:uuid/uuid.dart';

class PickDeviceScreen extends StatefulWidget {
  final SharedMedia sharedMedia;

  const PickDeviceScreen({super.key, required this.sharedMedia});

  @override
  PickDeviceScreenState createState() => PickDeviceScreenState();
}

class PickDeviceScreenState extends State<PickDeviceScreen> {
  @override
  Widget build(BuildContext context) {
    final deviceProvider = MultiCastClientProvider.of(context, listen: true);

    final devices =
        deviceProvider.deviceList.map((d) => d.toDeviceInfo()).toList();
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 247, 247, 247),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 247, 247, 247),
        title: const Text('选择一个设备',
            style: TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.w500)),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: DeviceList(
          devices: devices,
          onDeviceSelected: _onDeviceSelected,
          showHistory: false,
          history: [],
        ),
      ),
    );
  }

  Future<void> _onDeviceSelected(DeviceInfo deviceInfo) async {
    final bubbles = await _createUIBubbleFromSharedMedia(deviceInfo);
    for (final bubble in bubbles) {
      ShipService.instance.send(bubble);
    }
    if (context.mounted) {
      if (isOverMediumWidth(context)) {
        Navigator.pop(context, deviceInfo);
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
          return ConcertScreen(
            deviceInfo: deviceInfo,
            showBackButton: true,
          );
        }));
      }
    } else {
      log('无法跳转会话页，选择设备页面已销毁');
    }
  }

  Future<List<UIBubble>> _createUIBubbleFromSharedMedia(
      DeviceInfo deviceInfo) async {
    final self = Provider.of<AndropContext>(context, listen: false).deviceId;
    final bubbles = <UIBubble>[];
    if (widget.sharedMedia.attachments?.isNotEmpty == true) {
      for (final SharedAttachment? attachment
          in widget.sharedMedia.attachments ?? []) {
        if (attachment != null) {
          final shareable = SharedFile(
              id: const Uuid().v4(),
              state: FileState.picked,
              content: await attachment.toFileMeta());
          bubbles.add(UIBubble(
              from: self,
              to: deviceInfo.id,
              type: _sharedType2BubbleType(attachment.type),
              shareable: shareable));
        }
      }
    } else if (widget.sharedMedia.content?.isNotEmpty == true) {
      bubbles.add(UIBubble(
          from: self,
          to: deviceInfo.id,
          type: BubbleType.Text,
          shareable: SharedText(
              id: const Uuid().v4(), content: widget.sharedMedia.content!)));
    } else {
      log('无法创建UIBubble，分享内容为空');
    }

    return bubbles;
  }

  BubbleType _sharedType2BubbleType(SharedAttachmentType type) {
    switch (type) {
      case SharedAttachmentType.image:
        return BubbleType.Image;
      case SharedAttachmentType.video:
        return BubbleType.Video;
      case SharedAttachmentType.audio:
      case SharedAttachmentType.file:
        return BubbleType.File;
    }
  }
}