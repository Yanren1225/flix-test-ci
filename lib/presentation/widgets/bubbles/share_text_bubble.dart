import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flix/domain/androp_context.dart';
import 'package:flix/domain/concert/concert_provider.dart';
import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/model/ui_bubble/shareable.dart';
import 'package:flix/model/ui_bubble/ui_bubble.dart';
import 'package:flix/presentation/widgets/bubble_context_menu/delete_message_bottom_sheet.dart';
import 'package:flix/presentation/widgets/flix_toast.dart';
import 'package:flix/presentation/widgets/segements/bubble_context_menu.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
  @override
  void initState() {
    super.initState();
    contextMenuTag = Uuid().v4();
  }

  @override
  Widget build(BuildContext context) {
    AndropContext andropContext = context.watch();
    ConcertProvider concertProvider = Provider.of(context, listen: false);
    final SharedText sharedText = entity.shareable as SharedText;
    final Color backgroundColor;
    if (entity.isFromMe(andropContext.deviceId)) {
      backgroundColor = const Color.fromRGBO(0, 122, 255, 1);
    } else {
      backgroundColor = Colors.white;
    }

    final Color contentColor;
    if (entity.isFromMe(andropContext.deviceId)) {
      contentColor = Colors.white;
    } else {
      contentColor = Colors.black;
    }

    final Alignment alignment;
    if (entity.isFromMe(andropContext.deviceId)) {
      alignment = Alignment.centerRight;
    } else {
      alignment = Alignment.centerLeft;
    }
    return Align(
      alignment: alignment,
      child: LayoutBuilder(
        builder: (_context, _) => Material(
          color: backgroundColor,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          child: ModalAnchor(
            key: ValueKey(entity.shareable.id),
            tag: contextMenuTag,
            child: InkWell(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              onTapDown: (TapDownDetails details) {
                tapDown = details.localPosition;
              },
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: SelectableLinkify(
                  text: sharedText.content,
                  onOpen: (link) async {
                    if (!await launchUrl(Uri.parse(link.url))) {
                      throw Exception('Could not launch ${link.url}');
                    }
                  },
                  onSelectionChanged:
                      (TextSelection selection, SelectionChangedCause? cause) {
                    textSelection = selection;
                  },
                  contextMenuBuilder: (
                    BuildContext context,
                    EditableTextState editableTextState,
                  ) {
                    final TextEditingValue value =
                        editableTextState.textEditingValue;
                    final List<ContextMenuButtonItem> buttonItems =
                        editableTextState.contextMenuButtonItems;
                    buttonItems.clear();

                    buttonItems.add(ContextMenuButtonItem(
                      label: '复制',
                      onPressed: () {
                        ContextMenuController.removeAny();
                        _copyContentToClipboard();
                      },
                    ));

                    buttonItems.add(ContextMenuButtonItem(
                      label: '多选',
                      onPressed: () {
                        ContextMenuController.removeAny();
                        concertProvider.enterEditing();
                      },
                    ));

                    buttonItems.add(ContextMenuButtonItem(
                      label: '删除',
                      onPressed: () {
                        ContextMenuController.removeAny();
                        showCupertinoModalPopup(
                            context: context,
                            builder: (context) =>
                                DeleteMessageBottomSheet(onConfirm: () {
                                  concertProvider.deleteBubble(entity);
                                }));
                      },
                    ));

                    return AdaptiveTextSelectionToolbar.buttonItems(
                      anchors: editableTextState.contextMenuAnchors,
                      buttonItems: buttonItems,
                    );
                  },
                  linkStyle: TextStyle(
                      color: contentColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w400).useSystemChineseFont(),
                  style: TextStyle(
                      color: contentColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w400).useSystemChineseFont(),
                ),
              ),
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
      showBubbleContextMenu(context, contextMenuTag, clickPosition,
          andropContext.deviceId, concertProvider.concertMainKey, entity, [
        BubbleContextMenuItemType.Copy,
        BubbleContextMenuItemType.MultiSelect,
        BubbleContextMenuItemType.Delete,
        // BubbleContextMenuItemType.Location,
      ], {
        BubbleContextMenuItemType.Copy: () {
          _copyContentToClipboard();
        },
        BubbleContextMenuItemType.MultiSelect: () {
          concertProvider.enterEditing();
        },
        BubbleContextMenuItemType.Delete: () {
          showCupertinoModalPopup(
              context: context,
              builder: (context) => DeleteMessageBottomSheet(onConfirm: () {
                    concertProvider.deleteBubble(entity);
                  }));
        },
      });
    });
  }

  void _copyContentToClipboard() {
    if (textSelection == null) {
      Clipboard.setData(
          ClipboardData(text: (entity.shareable as SharedText).content));
    } else {
      Clipboard.setData(ClipboardData(
          text: (entity.shareable as SharedText).content.substring(
              textSelection!.baseOffset, textSelection!.extentOffset)));
    }
    FlixToast.instance.alert("已复制到剪切板");

    // FlixToast.(
    //     msg: "已复制到剪切板",
    //     toastLength: Toast.LENGTH_SHORT,
    //     gravity: ToastGravity.CENTER,
    //     timeInSecForIosWeb: 1,
    //     backgroundColor: Colors.grey.shade200,
    //     textColor: Colors.black,
    //     fontSize: 16.0);
  }
}
