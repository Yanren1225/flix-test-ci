import 'dart:math';
import 'dart:ui';

import 'package:androp/model/bubble_entity.dart';
import 'package:androp/model/device_info.dart';
import 'package:androp/model/shareable.dart';
import 'package:androp/presentation/share_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

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

  void submit(String content) {
    const device0 = 'Xiaomi 13';
    const device1 = 'Macbook';
    final random = Random();
    final fromMe = random.nextBool();
    final from = fromMe ? device0 : device1;
    final to = fromMe ? device1 : device0;
    setState(() {
      shareList.add(BubbleEntity(
          from: from,
          to: to,
          shareable: SharedText(id: '0', content: content)));
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
  final Function(String) onSubmit;

  const InputArea({super.key, required this.onSubmit});

  @override
  State<StatefulWidget> createState() {
    return InputAreaState(onSubmit: onSubmit);
  }
}

class InputAreaState extends State<InputArea> {
  final Function(String) onSubmit;
  String inputContent = '';

  InputAreaState({required this.onSubmit});

  void input(String content) {
    setState(() {
      inputContent = content;
    });
  }

  void submit(String content) {
    onSubmit(content);
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
              child: Row(
                children: [
                  SizedBox(
                    width: 36,
                    height: 36,
                    child: IconButton(
                        padding: const EdgeInsets.all(0),
                        iconSize: 20,
                        onPressed: () {},
                        icon: SvgPicture.asset('images/ic_image.svg')),
                  ),
                  SizedBox(
                    width: 36,
                    height: 36,
                    child: IconButton(
                        padding: const EdgeInsets.all(0),
                        iconSize: 20,
                        onPressed: () {},
                        icon: SvgPicture.asset('images/ic_video.svg')),
                  ),
                  SizedBox(
                    width: 36,
                    height: 36,
                    child: IconButton(
                      padding: const EdgeInsets.all(0),
                      iconSize: 20,
                      onPressed: () {},
                      icon: SvgPicture.asset('images/ic_app.svg'),
                    ),
                  ),
                  SizedBox(
                    width: 36,
                    height: 36,
                    child: IconButton(
                      padding: const EdgeInsets.all(0),
                      iconSize: 20,
                      onPressed: () {},
                      icon: SvgPicture.asset('images/ic_file.svg'),
                    ),
                  ),
                ],
              ),
            ),
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
                      submit(value);
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
                      submit(inputContent);
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
