import 'dart:io';
import 'dart:ui';

import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/presentation/basic/corner/flix_decoration.dart';
import 'package:flix/presentation/screens/main_screen.dart';
import 'package:flix/presentation/widgets/flix_toast.dart';
import 'package:flix/presentation/widgets/flixtitlebar.dart';
import 'package:flix/theme/theme_extensions.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flix/presentation/widgets/bubble_context_menu/delete_bottom_sheet_util.dart';
import 'package:flix/utils/drawin_file_security_extension.dart';
import 'package:flutter_svg/svg.dart';
import 'package:screen_capturer/screen_capturer.dart';
import 'package:flix/utils/file/file_utils.dart';
import 'package:flix/utils/text/text_extension.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flix/domain/concert/concert_provider.dart';
import 'package:flix/domain/device/device_profile_repo.dart';
import 'package:flix/domain/notification/badge_service.dart';
import 'package:flix/domain/settings/settings_repo.dart';
import 'package:flix/model/device_info.dart';
import 'package:flix/model/pickable.dart';
import 'package:flix/model/ship/primitive_bubble.dart';
import 'package:flix/model/ui_bubble/shareable.dart';
import 'package:flix/model/ui_bubble/shared_file.dart';
import 'package:flix/model/ui_bubble/ui_bubble.dart';
import 'package:flix/presentation/basic/corner/flix_decoration.dart';
import 'package:flix/presentation/screens/base_screen.dart';
import 'package:flix/presentation/screens/concert/bubble_list.dart';
import 'package:flix/presentation/screens/concert/files_confirm_bottom_sheet.dart';
import 'package:flix/presentation/widgets/bubble_context_menu/delete_message_bottom_sheet.dart';
import 'package:flix/presentation/widgets/bubble_context_menu/multi_select_actions.dart';
import 'package:flix/presentation/widgets/pick_actions.dart';
import 'package:flix/presentation/widgets/segements/navigation_appbar_scaffold.dart';
import 'package:flix/theme/theme_extensions.dart';
import 'package:flix/utils/drawin_file_security_extension.dart';
import 'package:flix/utils/file/file_helper.dart';
import 'package:flix/utils/text/text_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modals/modals.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:window_manager/window_manager.dart';

import '../../../l10n/l10n.dart';
import '../../widgets/segements/bubble_context_menu.dart';
import 'droper.dart';

class ConcertScreen extends StatefulWidget {
  final DeviceInfo deviceInfo;
  final String? anchor;
  final bool showBackButton;
  final bool playable;

  const ConcertScreen(
      {super.key,
      required this.deviceInfo,
      this.anchor,
      required this.showBackButton,
      this.playable = true});

  @override
  State<StatefulWidget> createState() {
    return _ConcertScreenState();
  }
}

class _ConcertScreenState extends State<ConcertScreen>
    with SingleTickerProviderStateMixin {
  DeviceInfo get deviceInfo => widget.deviceInfo;

  String? get anchor => widget.anchor;

  bool get showBackButton => widget.showBackButton;

  bool get playable => widget.playable;
  bool _isContentReady = false;

  late AnimationController _controller;
  late Animation<double> _animation;


  void clearThirdWidget() {
Provider.of<BackProvider>(context, listen: false).backMethod();
  }


  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300), // 淡入效果持续2秒
      vsync: this,
    );
    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller);
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _isContentReady = true;
      });
      _controller.forward();
    });
    startAccessPathOnMacos(SettingsRepo.instance.savedDir).then((value) {
      if (_isContentReady && mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    stopAccessPathOnMacos(SettingsRepo.instance.savedDir);
    super.dispose();
  }

  @override
 @override
Widget build(BuildContext context) {
  final main = LayoutBuilder(
    builder: (context, constraints) {
      final concertProvider = Provider.of<ConcertProvider>(context, listen: true);
      return ValueListenableBuilder(
        valueListenable: concertProvider.deviceName,
        builder: (context, value, child) {
          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 0), 
                child: PopScope(
                  canPop: !concertProvider.isEditing,
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
                  },

                  // 解决 Linkify 菜单无法收起的问题
                  child: GestureDetector(
                    behavior: HitTestBehavior.deferToChild,
                    onTapDown: (TapDownDetails details) {
                      FocusScope.of(context).unfocus();
                      ContextMenuController.removeAny();
                    },
                    child: Container(
                      color: Theme.of(context).flixColors.background.secondary,
                      child: Padding(
                        padding: (Platform.isMacOS || Platform.isWindows || Platform.isLinux)
                            ? const EdgeInsets.only(top: 20)
                            : EdgeInsets.zero,
                        child: GestureDetector(
                          child: NavigationAppbarScaffold(
                            showBackButton: showBackButton,
                            title: value,
                            isEditing: concertProvider.isEditing,
                            onClearThirdWidget: clearThirdWidget,
                            editTitle: '退出多选',
                            onExitEditing: () {
                              concertProvider.existEditing();
                            },
                            builder: (padding) {
                              return _isContentReady
                                  ? FadeTransition(
                                      opacity: _animation,
                                      child: ShareConcertMainView(
                                        key: concertProvider.concertMainKey,
                                        deviceInfo: concertProvider.deviceInfo,
                                        padding: padding,
                                        anchor: anchor,
                                        playable: playable,
                                      ),
                                    )
                                  : const SizedBox();
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: FlixTitleBar(), 
              ),
            ],
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
        : main,
  );
}


  FadeTransition createFadeTransition(
      ConcertProvider concertProvider, EdgeInsets padding) {
    return FadeTransition(
      opacity: _animation,
      child: ShareConcertMainView(
        key: concertProvider.concertMainKey,
        deviceInfo: concertProvider.deviceInfo,
        padding: padding,
        anchor: anchor,
        playable: playable,
      ),
    );
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
    concertProvider.send(UIBubble(
        time: DateTime.now().millisecondsSinceEpoch,
        from: DeviceProfileRepo.instance.did,
        to: Provider.of<ConcertProvider>(context, listen: false).deviceInfo.id,
        type: type,
        shareable: shareable));
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && _scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.minScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final concertProvider = Provider.of<ConcertProvider>(context, listen: true);
    final items = concertProvider.bubbles.reversed.toList();

    return Stack(
      children: [
        BubbleList(
          scrollController: _scrollController,
          padding: padding,
          items: items,
          reverse: true,
          shrinkWrap: true,
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Visibility(
            visible: !widget.playable,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 30.0),
              child: Text(
                "此设备已离线",
                style: TextStyle(
                  color: Theme.of(context).flixColors.text.secondary,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomLeft,
          child: Container(
            padding: padding,
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
                  BottomSheetUtil.showMessageDelete(context, () {
                    if (concertProvider.selectedItems.isEmpty) {
                      return;
                    }
                    for (var uiBubble in concertProvider.selectedItems) {
                      concertProvider.existEditing();
                      concertProvider.deleteBubble(uiBubble);
                    }
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
  State<StatefulWidget> createState() => InputAreaState();
}

class InputAreaState extends State<InputArea> {
  String inputContent = '';
  final textEditController = TextEditingController();

  void input(String content) {
    setState(() {
      inputContent = content;
    });
  }

  void submitText(String content) {
    widget.onSubmit(
        SharedText(id: const Uuid().v4(), content: content), BubbleType.Text);
  }

  void submitImage(FileMeta meta) {
    widget.onSubmit(
        SharedFile(
            id: const Uuid().v4(), state: FileState.picked, content: meta),
        BubbleType.Image);
  }

  void submitVideo(FileMeta meta) {
    widget.onSubmit(
        SharedFile(
            id: const Uuid().v4(), state: FileState.picked, content: meta),
        BubbleType.Video);
  }

  void submitApp(FileMeta meta) {
    // onSubmit(SharedApp(id: Uuid().v4(), content: app), BubbleType.App);
    widget.onSubmit(
        SharedFile(
            id: const Uuid().v4(), state: FileState.picked, content: meta),
        BubbleType.App);
  }

  void submitFile(FileMeta meta) async {
    widget.onSubmit(
        SharedFile(
            id: const Uuid().v4(), state: FileState.picked, content: meta),
        BubbleType.File);
  }

  void submitDirectory(DirectoryMeta meta, List<FileMeta> files) async {
    final directoryId = const Uuid().v4();
    widget.onSubmit(
        SharedDirectory(
            id: directoryId,
            state: FileState.picked,
            meta: meta,
            content: files
                .map((e) => SharedFile(
                    id: const Uuid().v4(),
                    groupId: directoryId,
                    state: FileState.picked,
                    content: e))
                .toList()),
        BubbleType.Directory);
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
        case PickedFileType.Directory:
          final directory = (element as PickableDirectory);
          if (directory.content.isEmpty) {
            FlixToast.withContext(context)
                .info(S.of(context).toast_msg_empty_folder);
            return;
          }
          submitDirectory(directory.meta, directory.content);
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
          decoration: FlixDecoration(
            color: Theme.of(context).flixColors.background.tertiary,
          ),
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
                                    return null;
                                  },
                                ),
                                SubmitIntent: CallbackAction<SubmitIntent>(
                                  onInvoke: (intent) {
                                    trySubmitText();
                                    return null;
                                  },
                                ),
                                PasteIntent: CallbackAction<PasteIntent>(
                                  onInvoke: (intent) async {
                                    _paste(concertProvider.deviceInfo);
                                    return null;
                                  },
                                )
                              },
                              child: TapRegion(
                                  groupId: contextMenuGroupId,
                                  consumeOutsideTaps: false,
                                  onTapOutside: (event) {
                                    // talker.debug("event11 = " +
                                    //     event.toString() +
                                    //     " down " +
                                    //     event.down.toString());
                                    //   removeAllModals();
                                  },
                                  child: TextField(
                                    contextMenuBuilder: (BuildContext context,
                                        EditableTextState editableTextState) {
                                      return TapRegion(
                                        groupId: contextMenuGroupId,
                                        consumeOutsideTaps: true,
                                        child:
                                            buildAdaptiveTextSelectionToolbar(
                                                editableTextState,
                                                concertProvider),
                                      );
                                    },
                                    controller: textEditController,
                                    style: TextStyle(
                                            color: Theme.of(context)
                                                .flixColors
                                                .text
                                                .primary,
                                            fontSize: 16,
                                            fontWeight: FontWeight.normal)
                                        .fix(),
                                    keyboardType: TextInputType.multiline,
                                    minLines: null,
                                    maxLines: null,
                                    decoration: InputDecoration(
                                        isDense: true,
                                        // hintText: 'Input something.',
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide.none,
                                          gapPadding: 0,
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        filled: true,
                                        fillColor: Theme.of(context)
                                            .flixColors
                                            .background
                                            .primary,
                                        hoverColor: Colors.transparent,
                                        contentPadding: EdgeInsets.only(
                                            left: 12,
                                            right: 12,
                                            top: 8,
                                            bottom: Platform.isMacOS ||
                                                    Platform.isWindows ||
                                                    Platform.isLinux
                                                ? 16
                                                : 8)),
                                    cursorColor: Theme.of(context)
                                        .flixColors
                                        .text
                                        .primary,
                                    onChanged: (value) {
                                      input(value);
                                    },
                                    onSubmitted: (value) {
                                      trySubmitText();
                                    },
                                  )),
                            ),
                          ),
                        )),
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                 
                  
                ],
              ),
              Row(
                children: [
                  PickActionsArea(onPicked: onPicked),
                  if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) ...[
                    IconButton(
                      icon: SvgPicture.asset(
                        'assets/images/screenshot.svg',
                        width: 22,
                        height: 22,
                        color: Theme.of(context).flixColors.text.primary,
                      ),
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        screenshot(concertProvider.deviceInfo, context);
                      },
                    ),
                    const SizedBox(width: 16),
                  ],
                  const Spacer(), 
                  IconButton(
                    icon: SvgPicture.asset(
                      'assets/images/send.svg',
                      width: 22,
                      height: 22,                     
                    ),
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      trySubmitText();
                    },
                  ),                 
                  const SizedBox(
                    width: 16,
                  ),
                ],
              )
            ]),
          ),
        ),
      ),
    );
  }

  Future<void> screenshot(DeviceInfo deviceInfo, BuildContext context) async {
    windowManager.minimize();
    try {
      await ScreenCapturer.instance.capture(
        mode: CaptureMode.region,
        imagePath: null,
        copyToClipboard: true,
      );

      await Future.delayed(const Duration(milliseconds: 500));
      windowManager.show();

      final filePaths = await Pasteboard.files();
      if (filePaths.isNotEmpty == true) {
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
        final imageFile = await FileUtils.getTargetFile(
            cachePath, '${const Uuid().v4()}.jpg');
        await imageFile.writeAsBytes(imageBytes);
        showCupertinoModalPopup(
          context: context,
          builder: (_) {
            return FilesConfirmBottomSheet(
              deviceInfo: deviceInfo,
              files: [XFile(imageFile.path)],
            );
          },
        );
      } else {
        // 用户取消截图
      }
    } catch (e) {
      //print('Error: $e');
    }
  }

  AdaptiveTextSelectionToolbar buildAdaptiveTextSelectionToolbar(
      EditableTextState editableTextState, ConcertProvider concertProvider) {
    return AdaptiveTextSelectionToolbar.editable(
      anchors: editableTextState.contextMenuAnchors,
      clipboardStatus: ClipboardStatus.pasteable,
      // to apply the normal behavior when click on copy (copy in clipboard close toolbar)
      // use an empty function `() {}` to hide this option from the toolbar
      onCopy: () =>
          editableTextState.copySelection(SelectionChangedCause.toolbar),
      // to apply the normal behavior when click on cut
      onCut: () =>
          editableTextState.cutSelection(SelectionChangedCause.toolbar),
      onPaste: () {
        // editableTextState.pasteText(SelectionChangedCause.toolbar);
        _paste(concertProvider.deviceInfo);
        editableTextState.hideToolbar();
      },
      // to apply the normal behavior when click on select all
      onSelectAll: () =>
          editableTextState.selectAll(SelectionChangedCause.toolbar),
      onLookUp: () =>
          editableTextState.lookUpSelection(SelectionChangedCause.toolbar),
      onSearchWeb: () => editableTextState
          .searchWebForSelection(SelectionChangedCause.toolbar),
      onShare: () =>
          editableTextState.shareSelection(SelectionChangedCause.toolbar),
      onLiveTextInput: () {},
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
      if (filePaths.isNotEmpty == true) {
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
        final imageFile = await FileUtils.getTargetFile(
            cachePath, '${const Uuid().v4()}.jpg');
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
      textEditController.value =
          textEditController.value.replaced(selection, text!);
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
