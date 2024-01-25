import 'dart:math';
import 'dart:ui';

import 'package:androp/model/bubble_entity.dart';
import 'package:androp/model/device_info.dart';
import 'package:androp/model/pickable.dart';
import 'package:androp/model/shareable.dart';
import 'package:androp/presentation/widgets/pick_actions.dart';
import 'package:androp/presentation/widgets/share_bubble.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class ShareConcertScreen extends StatelessWidget {
  final DeviceInfo deviceInfo;

  const ShareConcertScreen({super.key, required this.deviceInfo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
        backgroundColor: const Color.fromRGBO(247, 247, 247, 1),
        surfaceTintColor: const Color.fromRGBO(247, 247, 247, 1),
      ),
      body: Container(
          decoration:
              const BoxDecoration(color: Color.fromRGBO(247, 247, 247, 1)),
          child: const ShareConcertMainView()),
    );
  }
}

class ShareConcertMainView extends StatefulWidget {
  const ShareConcertMainView({super.key});

  @override
  State<StatefulWidget> createState() {
    return ShareConcertMainViewState();
  }
}

class ShareConcertMainViewState extends State<ShareConcertMainView> {
  List<BubbleEntity> shareList = [];

  void submit(Shareable shareable) {
    const device0 = 'Xiaomi 13';
    const device1 = 'Macbook';
    final random = Random();
    final fromMe = random.nextBool();
    final from = fromMe ? device0 : device1;
    final to = fromMe ? device1 : device0;
    setState(() {
      shareList.add(BubbleEntity(from: from, to: to, shareable: shareable));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ListView(
          children: [
            ...shareList
                .map((e) => Padding(
                      padding: const EdgeInsets.only(
                          left: 16.0, right: 16.0, top: 12, bottom: 12),
                      child: ShareBubble(
                        entity: e,
                      ),
                    ))
                .toList(),
            const SizedBox(
              height: 260,
            )
          ],
        ),
        Align(
          alignment: Alignment.bottomLeft,
          child: InputArea(
            // onSubmit: (content) => submit(content),
            onSubmit: submit,
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
  final Uuid uuid = const Uuid();
  final OnSubmit onSubmit;
  String inputContent = '';

  InputAreaState({required this.onSubmit});

  void input(String content) {
    setState(() {
      inputContent = content;
    });
  }

  void submitText(String content) {
    onSubmit(SharedText(id: uuid.v1(), content: content));
  }

  void submitImage(String path) {
    onSubmit(SharedImage(id: uuid.v1(), content: path));
  }

  void submitVideo(String path) {
    onSubmit(SharedVideo(id: uuid.v1(), content: path));
  }

  void submitApp(Application app) {
    onSubmit(SharedApp(id: uuid.v1(), content: app));
  }

  void onPicked(List<Pickable> pickables) {
    for (var element in pickables) {
      switch (element.type) {
        case PickedFileType.Image:
          submitImage((element as PickableFile).content.path);
          break;
        case PickedFileType.Video:
          submitVideo((element as PickableFile).content.path);
          break;
        case PickedFileType.App:
          submitApp((element as PickableApp).content);
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

typedef OnSubmit = void Function(Shareable);
