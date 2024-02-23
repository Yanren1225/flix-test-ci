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
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class ConcertScreen extends StatelessWidget {
  final DeviceInfo deviceInfo;
  final String? anchor;

  const ConcertScreen(
      {super.key, required this.deviceInfo, this.anchor = null});

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: const Icon(
          Icons.arrow_back_ios,
          color: Colors.black,
          size: 20,
        ),
      ),
      title: Text(deviceInfo.name),
      titleTextStyle: const TextStyle(
          color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500),
      backgroundColor: const Color.fromRGBO(247, 247, 247, 0.8),
      surfaceTintColor: const Color.fromRGBO(247, 247, 247, 0.8),
    );
    final appBarHeight =
        appBar.preferredSize.height + MediaQuery.of(context).padding.top;
    return ChangeNotifierProvider<ConcertProvider>(
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
            Padding(
                padding:
                    const EdgeInsets.only(left: 8, top: 2, right: 8, bottom: 2),
                child: PickActionsArea(onPicked: onPicked)),
            ConstrainedBox(
                constraints:
                    const BoxConstraints(minHeight: 18, maxHeight: 200),
                child: SingleChildScrollView(
                  child: TextField(
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: const InputDecoration(
                        hintText: 'Input something.',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(left: 16, right: 16)),
                    cursorColor: Colors.black,
                    onChanged: (value) {
                      input(value);
                    },
                    onSubmitted: (value) {
                      submitText(value);
                    },
                  ),
                )),
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 16, bottom: 18),
                child: SizedBox(
                  width: 30,
                  height: 30,
                  child: GestureDetector(
                    onTap: () {
                      FocusScope.of(context).unfocus();
                      submitText(inputContent);
                    },
                    child: Container(
                      decoration: const BoxDecoration(
                          color: Color.fromRGBO(0, 122, 255, 1),
                          borderRadius: BorderRadius.all(Radius.circular(100))),
                      child: const SizedBox(
                        width: 30,
                        height: 30,
                        child: Icon(
                          Icons.arrow_upward_sharp,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
          ]),
        ),
      ),
    );
  }
}

typedef OnSubmit = void Function(Shareable shareable, BubbleType type);
