import 'dart:io';
import 'dart:ui';

import 'package:file_selector/file_selector.dart';
import 'package:flix/domain/concert/concert_provider.dart';
import 'package:flix/domain/device/device_manager.dart';
import 'package:flix/domain/notification/BadgeService.dart';
import 'package:flix/model/device_info.dart';
import 'package:flix/model/pickable.dart';
import 'package:flix/model/ship/primitive_bubble.dart';
import 'package:flix/model/ui_bubble/shareable.dart';
import 'package:flix/model/ui_bubble/shared_file.dart';
import 'package:flix/model/ui_bubble/ui_bubble.dart';
import 'package:flix/presentation/screens/base_screen.dart';
import 'package:flix/presentation/screens/concert/bubble_list.dart';
import 'package:flix/presentation/screens/concert/files_confirm_bottom_sheet.dart';
import 'package:flix/presentation/widgets/bubble_context_menu/delete_message_bottom_sheet.dart';
import 'package:flix/presentation/widgets/bubble_context_menu/multi_select_actions.dart';
import 'package:flix/presentation/widgets/pick_actions.dart';
import 'package:flix/presentation/widgets/segements/navigation_scaffold.dart';
import 'package:flix/utils/file/file_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import 'droper.dart';

class ConcertScreen extends StatelessWidget {
  final DeviceInfo deviceInfo;
  final String? anchor;
  final bool showBackButton;
  final bool playable;

  const ConcertScreen(
      {super.key,
      required this.deviceInfo,
      this.anchor = null,
      required this.showBackButton,
      this.playable = true});

  @override
  Widget build(BuildContext context) {
    final main = LayoutBuilder(
      builder: (_context, constraints) {
        final concertProvider =
            Provider.of<ConcertProvider>(_context, listen: true);
        return ValueListenableBuilder(
          valueListenable: concertProvider.deviceName,
          builder: (_context, value, child) {
            return PopScope(
              canPop: false,
              onPopInvoked: (didPop) {
                if (!didPop) {
                  Future.delayed(Duration.zero, () {
                    if (concertProvider.isEditing) {
                      concertProvider.existEditing();
                    } else {
                      Navigator.pop(context);
                    }
                  });
                }
                // Navigator.pop(context);
              },
              child: NavigationScaffold(
                  showBackButton: showBackButton,
                  title: value,
                  isEditing: concertProvider.isEditing,
                  editTitle: '退出多选',
                  onExitEditing: () {
                    concertProvider.existEditing();
                  },
                  builder: (padding) {
                    return ShareConcertMainView(
                      key: concertProvider.concertMainKey,
                      deviceInfo: concertProvider.deviceInfo,
                      padding: padding,
                      anchor: anchor,
                      playable: playable,
                    );
                  }),
            );
          },
        );
      },
    );
    return ChangeNotifierProvider<ConcertProvider>(
        key: Key(deviceInfo.id),
        create: (BuildContext context) {
          return ConcertProvider(deviceInfo: deviceInfo);
        },
        child: playable
            ? Droper(
                deviceInfo: deviceInfo,
                child: main,
              )
            : main);
  }
}

class ShareConcertMainView extends StatefulWidget {
  final DeviceInfo deviceInfo;
  final EdgeInsets padding;
  final String? anchor;
  final bool playable;

  const ShareConcertMainView(
      {super.key,
      required this.deviceInfo,
      required this.padding,
      required this.anchor,
      required this.playable});

  @override
  State<StatefulWidget> createState() {
    return ShareConcertMainViewState();
  }
}

class ShareConcertMainViewState extends BaseScreenState<ShareConcertMainView> {
  EdgeInsets get padding => widget.padding;

  String? get anchor => widget.anchor;
  bool isAnchored = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    BadgeService.instance.clearBadgesFrom(widget.deviceInfo.id);
  }

  @override
  void dispose() {
    BadgeService.instance.clearBadgesFrom(widget.deviceInfo.id);
    super.dispose();
  }

  void submit(ConcertProvider concertProvider, Shareable shareable,
      BubbleType type) async {
    _scrollController.animateTo(_scrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 200), curve: Curves.easeInOut);
    await concertProvider.send(UIBubble(
        from: DeviceManager.instance.did,
        to: Provider.of<ConcertProvider>(context, listen: false).deviceInfo.id,
        type: type,
        shareable: shareable));
  }

  @override
  Widget build(BuildContext context) {
    final concertProvider = Provider.of<ConcertProvider>(context, listen: true);
    final items = concertProvider.bubbles.reversed.toList();

    return Stack(
      fit: StackFit.loose,
      children: [
        BubbleList(
          scrollController: _scrollController,
          padding: padding,
          items: items,
          reverse: true,
          shrinkWrap: true,
        ),
        Align(
          alignment: Alignment.bottomLeft,
          child: SizedBox(
            width: double.infinity,
            child: AnimatedCrossFade(
              crossFadeState: concertProvider.isEditing
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: Visibility(
                visible: widget.playable,
                child: InputArea(
                  // onSubmit: (content) => submit(content),
                  onSubmit: (shareable, type) {
                    submit(concertProvider, shareable, type);
                  },
                ),
              ),
              secondChild: MultiSelectActions(
                onDelete: () {
                  showCupertinoModalPopup(
                      context: context,
                      builder: (context) {
                        return DeleteMessageBottomSheet(onConfirm: () {
                          if (concertProvider.selectedItems.isEmpty) {
                            return;
                          }
                          for (var uiBubble in concertProvider.selectedItems) {
                            concertProvider.existEditing();
                            concertProvider.deleteBubble(uiBubble);
                          }
                        });
                      });
                },
              ),
              duration: const Duration(milliseconds: 100),
            ),
          ),
        ),
      ],
    );
  }
}

class InputArea extends StatefulWidget {
  final OnSubmit onSubmit;

  const InputArea({super.key, required this.onSubmit});

  @override
  State<StatefulWidget> createState() {
    return InputAreaState(onSubmit: onSubmit);
  }
}

class InputAreaState extends State<InputArea> {
  final OnSubmit onSubmit;
  String inputContent = '';
  final textEditController = TextEditingController();

  InputAreaState({required this.onSubmit});

  void input(String content) {
    setState(() {
      inputContent = content;
    });
  }

  void submitText(String content) {
    onSubmit(SharedText(id: Uuid().v4(), content: content), BubbleType.Text);
  }

  void submitImage(FileMeta meta) {
    onSubmit(
        SharedFile(id: Uuid().v4(), state: FileState.picked, content: meta),
        BubbleType.Image);
  }

  void submitVideo(FileMeta meta) {
    onSubmit(
        SharedFile(id: Uuid().v4(), state: FileState.picked, content: meta),
        BubbleType.Video);
  }

  void submitApp(FileMeta meta) {
    // onSubmit(SharedApp(id: Uuid().v4(), content: app), BubbleType.App);
    onSubmit(
        SharedFile(id: Uuid().v4(), state: FileState.picked, content: meta),
        BubbleType.App);
  }

  void submitFile(FileMeta meta) async {
    onSubmit(
        SharedFile(id: Uuid().v4(), state: FileState.picked, content: meta),
        BubbleType.File);
  }

  void onPicked(List<Pickable> pickables) {
    for (var element in pickables) {
      switch (element.type) {
        case PickedFileType.Image:
          submitImage((element as PickableFile).content);
          break;
        case PickedFileType.Video:
          submitVideo((element as PickableFile).content);
          break;
        case PickedFileType.App:
          submitApp((element as PickableFile).content);
          break;
        case PickedFileType.File:
          submitFile((element as PickableFile).content);
          break;
        default:
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final concertProvider =
        Provider.of<ConcertProvider>(context, listen: false);
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: const BoxDecoration(
              color: Color.fromRGBO(247, 247, 247, 0.8),
              border: Border(
                  top: BorderSide(
                color: Color.fromRGBO(240, 240, 240, 1),
              ))),
          child: Padding(
            padding:
                EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const SizedBox(
                height: 10,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const SizedBox(
                    width: 16,
                  ),
                  Expanded(
                    child: ConstrainedBox(
                        constraints:
                            const BoxConstraints(minHeight: 40, maxHeight: 200),
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(
                                  decelerationRate:
                                      ScrollDecelerationRate.fast)),
                          child: Shortcuts(
                            shortcuts: {
                              LogicalKeySet(LogicalKeyboardKey.control,
                                      LogicalKeyboardKey.enter):
                                  const BreakLineIntent(),
                              LogicalKeySet(LogicalKeyboardKey.enter):
                                  const SubmitIntent(),
                              LogicalKeySet(
                                  Platform.isMacOS
                                      ? LogicalKeyboardKey.meta
                                      : LogicalKeyboardKey.control,
                                  LogicalKeyboardKey.keyV): const PasteIntent()
                            },
                            child: Actions(
                              actions: <Type, Action<Intent>>{
                                BreakLineIntent:
                                    CallbackAction<BreakLineIntent>(
                                  onInvoke: (intent) {
                                    textEditController.text += '\n';
                                  },
                                ),
                                SubmitIntent: CallbackAction<SubmitIntent>(
                                  onInvoke: (intent) {
                                    trySubmitText();
                                  },
                                ),
                                PasteIntent: CallbackAction<PasteIntent>(
                                  onInvoke: (intent) async {
                                    _paste(concertProvider.deviceInfo);
                                  },
                                )
                              },
                              child: TextField(
                                contextMenuBuilder: (BuildContext context,
                                    EditableTextState editableTextState) {
                                  return AdaptiveTextSelectionToolbar.editable(
                                    anchors:
                                        editableTextState.contextMenuAnchors,
                                    clipboardStatus: ClipboardStatus.pasteable,
                                    // to apply the normal behavior when click on copy (copy in clipboard close toolbar)
                                    // use an empty function `() {}` to hide this option from the toolbar
                                    onCopy: () =>
                                        editableTextState.copySelection(
                                            SelectionChangedCause.toolbar),
                                    // to apply the normal behavior when click on cut
                                    onCut: () => editableTextState.cutSelection(
                                        SelectionChangedCause.toolbar),
                                    onPaste: () {
                                      // editableTextState.pasteText(SelectionChangedCause.toolbar);
                                      _paste(concertProvider.deviceInfo);
                                      editableTextState.hideToolbar();
                                    },
                                    // to apply the normal behavior when click on select all
                                    onSelectAll: () =>
                                        editableTextState.selectAll(
                                            SelectionChangedCause.toolbar),
                                    onLookUp: () =>
                                        editableTextState.lookUpSelection(
                                            SelectionChangedCause.toolbar),
                                    onSearchWeb: () =>
                                        editableTextState.searchWebForSelection(
                                            SelectionChangedCause.toolbar),
                                    onShare: () =>
                                        editableTextState.shareSelection(
                                            SelectionChangedCause.toolbar),
                                    onLiveTextInput: () {},
                                  );
                                },
                                controller: textEditController,
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal),
                                keyboardType: TextInputType.multiline,
                                minLines: null,
                                maxLines: null,
                                decoration: InputDecoration(
                                    isDense: true,
                                    // hintText: 'Input something.',
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      gapPadding: 0,
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    hoverColor: Colors.white,
                                    contentPadding: EdgeInsets.only(
                                        left: 12,
                                        right: 12,
                                        top: 8,
                                        bottom: Platform.isMacOS ||
                                                Platform.isWindows ||
                                                Platform.isLinux
                                            ? 16
                                            : 8)),
                                cursorColor: Colors.black,
                                onChanged: (value) {
                                  input(value);
                                },
                                onSubmitted: (value) {
                                  trySubmitText();
                                },
                              ),
                            ),
                          ),
                        )),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: IconButton(
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          trySubmitText();
                        },
                        // padding: const EdgeInsets.all(9.0),
                        iconSize: 22,
                        style: ButtonStyle(
                            backgroundColor: MaterialStateColor.resolveWith(
                                (states) =>
                                    const Color.fromRGBO(0, 122, 255, 1)),
                            shape: MaterialStatePropertyAll<
                                RoundedRectangleBorder>(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ))),
                        icon: const Icon(
                          Icons.arrow_upward_sharp,
                          color: Colors.white,
                          size: 22,
                        )),
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                ],
              ),
              PickActionsArea(onPicked: onPicked),
            ]),
          ),
        ),
      ),
    );
  }

  void trySubmitText() {
    if (textEditController.text.trim().isNotEmpty) {
      submitText(textEditController.text);
      textEditController.clear();
    }
    inputContent = '';
  }

  void _paste(
    DeviceInfo deviceInfo,
  ) async {
    if (!Platform.isAndroid) {
      final filePaths = await Pasteboard.files();
      if (filePaths?.isNotEmpty == true) {
        final files = filePaths.map((e) => XFile(e)).toList();
        showCupertinoModalPopup(
            context: context,
            builder: (_) {
              return FilesConfirmBottomSheet(
                  deviceInfo: deviceInfo, files: files);
            });
        return;
      }
      final imageBytes = await Pasteboard.image;
      if (imageBytes != null) {
        final cachePath = await getCachePath();
        final imageFile = await createFile(cachePath, '$cachePath/${Uuid().v4()}.jpg');
        await imageFile.writeAsBytes(imageBytes);
        showCupertinoModalPopup(
            context: context,
            builder: (_) {
              return FilesConfirmBottomSheet(
                  deviceInfo: deviceInfo, files: [XFile(imageFile.path)]);
            });
        return;
      }
 
    }
    
    


    final text = await Pasteboard.text;
    if (text?.isNotEmpty == true) {
      final selection = textEditController.selection;
      // final offset = selection.baseOffset;
      textEditController.value = textEditController.value.replaced(selection, text!);
      return;
    }
  }
}

typedef OnSubmit = void Function(Shareable shareable, BubbleType type);

class BreakLineIntent extends Intent {
  const BreakLineIntent();
}

class SubmitIntent extends Intent {
  const SubmitIntent();
}

class PasteIntent extends Intent {
  const PasteIntent();
}
