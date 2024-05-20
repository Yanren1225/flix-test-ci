import 'dart:math';

import 'package:flix/utils/text/text_extension.dart';
import 'package:flix/domain/androp_context.dart';
import 'package:flix/domain/concert/concert_provider.dart';
import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/model/ui_bubble/shareable.dart';
import 'package:flix/model/ui_bubble/ui_bubble.dart';
import 'package:flix/presentation/screens/concert/free_copy_screen.dart';
import 'package:flix/presentation/widgets/bubble_context_menu/delete_message_bottom_sheet.dart';
import 'package:flix/presentation/widgets/flix_toast.dart';
import 'package:flix/presentation/widgets/segements/bubble_context_menu.dart';
import 'package:flix/utils/platform_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:modals/modals.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

class ShareTextBubble extends StatefulWidget {
  final UIBubble entity;

  ShareTextBubble({super.key, required this.entity});

  @override
  State<StatefulWidget> createState() => ShareTextBubbleState();
}

class ShareTextBubbleState extends State<ShareTextBubble> {
  UIBubble get entity => widget.entity;
  Offset? tapDown;
  late String contextMenuTag;
  TextSelection? textSelection;
  final FocusNode _focusNode = FocusNode();
  int _focusId = 0;

  @override
  void initState() {
    super.initState();
    contextMenuTag = Uuid().v4();
    _focusNode.addListener(() {
      if (!_focusNode.hasPrimaryFocus) {
        setState(() {
          _focusId++;
        });
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AndropContext andropContext = context.watch();
    ConcertProvider concertProvider = Provider.of(context, listen: false);
    final SharedText sharedText = entity.shareable as SharedText;
    final Color contentColor;
    final Color backgroundColor;
    final Color selectIndicatorColor;
    if (entity.isFromMe(andropContext.deviceId)) {
      contentColor = Colors.white;
      backgroundColor = const Color.fromRGBO(0, 122, 255, 1);
      selectIndicatorColor = const Color.fromRGBO(255, 255, 255, 0.6);
    } else {
      contentColor = Colors.black;
      backgroundColor = Colors.white;
      selectIndicatorColor = const Color.fromRGBO(0, 122, 255, 0.6);
    }

    final Alignment alignment;
    if (entity.isFromMe(andropContext.deviceId)) {
      alignment = Alignment.centerRight;
    } else {
      alignment = Alignment.centerLeft;
    }
    final textStyle = TextStyle(
            color: contentColor, fontSize: 16, decorationColor: contentColor ,fontWeight: FontWeight.w400)
        .fix();
    final content = Padding(
      padding: const EdgeInsets.all(10),
      child: Theme(
        data: ThemeData(
          textSelectionTheme: TextSelectionThemeData(
            selectionColor: selectIndicatorColor,
            cursorColor: Colors.black,
            selectionHandleColor: Colors.black,
          ),
        ),
        child: SelectableLinkify(
          key: ValueKey(_focusId),
          text: sharedText.content,
          focusNode: _focusNode,
          onOpen: (link) async {
            if (!await launchUrl(Uri.parse(link.url))) {
              talker.error('Could not launch ${link.url}');
            }
          },
          onSelectionChanged: (TextSelection selection,
              SelectionChangedCause? cause) {
            textSelection = selection;
          },
          contextMenuBuilder: (
              BuildContext context,
              EditableTextState editableTextState,
              ) {
            return _buildContextMenu(concertProvider, context,
                editableTextState.contextMenuAnchors);
          },
          linkStyle: textStyle,
          style: textStyle,
          cursorColor: Colors.black,
        ),
      ),
    );
    return Align(
      alignment: alignment,
      child: LayoutBuilder(
        builder: (_context, _) => Material(
          color: backgroundColor,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          child: ModalAnchor(
            key: ValueKey(entity.shareable.id),
            tag: contextMenuTag,
            child: isDesktop() ? content : GestureDetector(
              onDoubleTap: () {
                _startFreeCopyScreen(context);
              },
              child: content,
            ),
          ),
        ),
      ),
    );
  }

  void _showBubbleContextMenu(BuildContext context, Offset clickPosition,
      AndropContext andropContext, ConcertProvider concertProvider) {
    talker
        .debug('show anchor tag: $contextMenuTag, id: ${entity.shareable.id}');

    Future.delayed(Duration.zero, () {
      showBubbleContextMenu(
          context,
          contextMenuTag,
          clickPosition,
          andropContext.deviceId,
          concertProvider.concertMainKey,
          entity,
          _getMenuItems(),
          _getMenuActions(concertProvider, context));
    });
  }

  Widget _buildContextMenu(ConcertProvider concertProvider,
      BuildContext context, TextSelectionToolbarAnchors anchors) {
    return BubbleContextMenuWithMask(
      anchors: anchors,
      itemTypes: _getMenuItems(),
      itemActions: _getMenuActions(concertProvider, context),
    );
  }

  List<BubbleContextMenuItemType> _getMenuItems() {
    return [
      BubbleContextMenuItemType.Copy,
      BubbleContextMenuItemType.MultiSelect,
      BubbleContextMenuItemType.FreeCopy,
      BubbleContextMenuItemType.Delete,
    ];
  }

  Map<BubbleContextMenuItemType, VoidCallback> _getMenuActions(
      ConcertProvider concertProvider, BuildContext context) {
    return {
      BubbleContextMenuItemType.Copy: () {
        final sharedText = entity.shareable as SharedText;
        if (textSelection == null) {
          _copyContentToClipboard(sharedText.content);
        } else {
          int start =
              min(textSelection!.baseOffset, textSelection!.extentOffset);
          int end = max(textSelection!.baseOffset, textSelection!.extentOffset);
          if (start == end) {
            _copyContentToClipboard(sharedText.content);
          } else {
            _copyContentToClipboard(sharedText.content.substring(start, end));
          }
        }
      },
      BubbleContextMenuItemType.MultiSelect: () {
        concertProvider.enterEditing();
      },
      BubbleContextMenuItemType.FreeCopy: () {
        _startFreeCopyScreen(context);
      },
      BubbleContextMenuItemType.Delete: () {
        showCupertinoModalPopup(
            context: context,
            builder: (context) => DeleteMessageBottomSheet(onConfirm: () {
              concertProvider.deleteBubble(entity);
            }));
      },
    };
  }

  void _startFreeCopyScreen(BuildContext context) {
    showCupertinoModalPopup(
        context: context,
        builder: (_) {
          return FreeCopyScreen(text: (entity.shareable as SharedText).content);
        });
  }

  void _copyContentToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    flixToast.info("已复制到剪切板");
  }
}
