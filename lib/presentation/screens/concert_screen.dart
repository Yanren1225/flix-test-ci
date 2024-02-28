import 'dart:ui';

import 'package:androp/domain/concert/concert_provider.dart';
import 'package:androp/domain/device/device_manager.dart';
import 'package:androp/model/ship/primitive_bubble.dart';
import 'package:androp/model/ui_bubble/shared_file.dart';
import 'package:androp/model/ui_bubble/ui_bubble.dart';
import 'package:androp/model/device_info.dart';
import 'package:androp/model/pickable.dart';
import 'package:androp/model/ui_bubble/shareable.dart';
import 'package:androp/presentation/widgets/blur_appbar.dart';
import 'package:androp/presentation/widgets/bubbles/share_bubble.dart';
import 'package:androp/presentation/widgets/pick_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class ConcertScreen extends StatelessWidget {
  final DeviceInfo deviceInfo;
  final String? anchor;
  final bool showBackButton;

  const ConcertScreen(
      {super.key,
      required this.deviceInfo,
      this.anchor = null,
      required this.showBackButton});

  @override
  Widget build(BuildContext context) {
    final Widget? backButton;
    if (showBackButton) {
      backButton = GestureDetector(
        onTap: () => Navigator.pop(context),
        child: const Icon(
          Icons.arrow_back_ios,
          color: Colors.black,
          size: 20,
        ),
      );
    } else {
      backButton = null;
    }
    final appBar = AppBar(
      leading: backButton,
      title: Text(deviceInfo.name),
      titleTextStyle: const TextStyle(
          color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500),
      backgroundColor: const Color.fromRGBO(247, 247, 247, 0.8),
      surfaceTintColor: const Color.fromRGBO(247, 247, 247, 0.8),
    );
    final appBarHeight =
        appBar.preferredSize.height + MediaQuery.of(context).padding.top;
    return ChangeNotifierProvider<ConcertProvider>(
      key: Key(deviceInfo.id),
      create: (BuildContext context) {
        return ConcertProvider(deviceInfo: deviceInfo);
      },
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(247, 247, 247, 1),
        extendBodyBehindAppBar: true,
        appBar: BlurAppBar(
          appBar: appBar,
        ),
        body:
            // const ShareConcertMainView()
            ShareConcertMainView(
          padding: EdgeInsets.only(top: appBarHeight),
          anchor: anchor,
        ),
      ),
    );
  }
}

class ShareConcertMainView extends StatefulWidget {
  final EdgeInsets padding;
  final String? anchor;

  const ShareConcertMainView(
      {super.key, required this.padding, required this.anchor});

  @override
  State<StatefulWidget> createState() {
    return ShareConcertMainViewState();
  }
}

class ShareConcertMainViewState extends State<ShareConcertMainView> {
  EdgeInsets get padding => widget.padding;

  String? get anchor => widget.anchor;
  bool isAnchored = false;
  final ScrollController _scrollController = ScrollController();

  // List<BubbleEntity> shareList = [];

  void submit(ConcertProvider concertProvider, Shareable shareable,
      BubbleType type) async {
    _scrollController.animateTo(_scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 200), curve: Curves.easeInOut);
    await concertProvider.send(UIBubble(
        from: DeviceManager.instance.did,
        to: Provider.of<ConcertProvider>(context, listen: false).deviceInfo.id,
        type: type,
        shareable: shareable));
  }

  @override
  Widget build(BuildContext context) {
    final concertProvider = Provider.of<ConcertProvider>(context, listen: true);
    final shareList = concertProvider.bubbles;
    // if (!isInit && anchor != null) {
    //   for (int i = 0; i < shareList.length; i++) {
    //     final item = shareList[i];
    //     if (item.shareable.id == anchor) {
    //       _scrollController.jumpTo(i * 50);
    //       break;
    //     }
    //   }
    // }
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!isAnchored && shareList.isNotEmpty) {
        isAnchored = true;
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });

    return Stack(
      fit: StackFit.expand,
      children: [
        ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.only(top: padding.top, bottom: 260),
            itemCount: shareList.length,
            itemBuilder: (context, index) {
              final item = shareList[index];
              return Padding(
                padding: const EdgeInsets.only(
                    left: 16.0, right: 16.0, top: 12, bottom: 12),
                child: ShareBubble(
                  key: Key('$index'),
                  uiBubble: item,
                ),
              );
            }),
        Align(
          alignment: Alignment.bottomLeft,
          child: InputArea(
            // onSubmit: (content) => submit(content),
            onSubmit: (shareable, type) {
              submit(concertProvider, shareable, type);
            },
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
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10)),
                          child: TextField(
                            controller: textEditController,
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.normal),
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            decoration: InputDecoration(
                                hintText: 'Input something.',
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  gapPadding: 0,
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                contentPadding: const EdgeInsets.only(
                                    left: 12, right: 12, top: 8, bottom: 8)),
                            cursorColor: Colors.black,
                            onChanged: (value) {
                              input(value);
                            },
                            onSubmitted: (value) {
                              trySubmitText(value);
                            },
                          ),
                        ),
                      )),
                ),
                const SizedBox(
                  width: 10,
                ),
                IconButton(
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      trySubmitText(inputContent);
                    },
                    padding: const EdgeInsets.all(9.0),
                    iconSize: 22,
                    style: ButtonStyle(
                        backgroundColor: MaterialStateColor.resolveWith(
                            (states) => const Color.fromRGBO(0, 122, 255, 1)),
                        shape: MaterialStatePropertyAll<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ))),
                    icon: const Icon(
                      Icons.arrow_upward_sharp,
                      color: Colors.white,
                      size: 22,
                    )),
                const SizedBox(
                  width: 16,
                ),
              ],
            ),
            PickActionsArea(onPicked: onPicked),
          ]),
        ),
      ),
    );
  }

  void trySubmitText(String content) {
    if (content.trim().isNotEmpty) {
      textEditController.clear();
      submitText(content);
    }
  }
}

typedef OnSubmit = void Function(Shareable shareable, BubbleType type);
