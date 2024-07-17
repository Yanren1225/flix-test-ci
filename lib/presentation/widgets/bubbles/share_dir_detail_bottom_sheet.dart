import 'dart:async';

import 'package:flix/domain/database/database.dart';
import 'package:flix/domain/ship_server/ship_service_proxy.dart';
import 'package:flix/model/ship/primitive_bubble.dart';
import 'package:flix/model/ui_bubble/shared_file.dart';
import 'package:flix/model/ui_bubble/ui_bubble.dart';
import 'package:flix/presentation/basic/corner/flix_decoration.dart';
import 'package:flix/presentation/widgets/flix_bottom_sheet.dart';
import 'package:flix/presentation/widgets/flix_toast.dart';
import 'package:flix/utils/bubble_convert.dart';
import 'package:flix/utils/file/file_helper.dart';
import 'package:flix/utils/file/size_utils.dart';
import 'package:flix/utils/text/text_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gradient_txt/gradient_text.dart';

showDirectoryDetailBottomSheet(
    BuildContext context, String dirBubbleId, String dirName) async {
  await showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return DirectoryDetailBottomSheet(
            dirBubbleId: dirBubbleId, dirName: dirName);
      });
}

class DirectoryDetailBottomSheet extends StatefulWidget {
  final String dirBubbleId;
  final String dirName;

  const DirectoryDetailBottomSheet(
      {super.key, required this.dirBubbleId, required this.dirName});

  @override
  BottomSheetContentState createState() => BottomSheetContentState();
}

class BottomSheetContentState extends State<DirectoryDetailBottomSheet> {
  // 模拟不同状态
  _BottomSheetState _bottomSheetState = _BottomSheetState.loading;

  String get dirBubbleId => widget.dirBubbleId;

  String get dirName => widget.dirName;
  List<PrimitiveBubble>? _bubbles;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _loadData(false);
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadData(bool refresh) async {
    try {
      final bubbles =
          await appDatabase.bubblesDao.getDirectoryFileByGroupid(dirBubbleId);
      var state = _bottomSheetState;
      if (bubbles == null) {
        if(refresh) return;
        state = _BottomSheetState.error;
      } else if (bubbles.isEmpty) {
        if(refresh) return;
        state = _BottomSheetState.empty;
      } else {
        state = _BottomSheetState.list;
      }
      setState(() {
        _bubbles = bubbles;
        _bottomSheetState = state;
      });
    } catch (e) {
      if(refresh) return;
      setState(() {
        _bottomSheetState = _BottomSheetState.error;
      });
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      _loadData(true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FlixBottomSheet(
        title: '文件夹内容',
        subTitle: dirName,
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
          child: _buildContent(),
        ));
  }

  Widget _buildContent() {
    List<PrimitiveBubble>? realBubbles = _bubbles?.where((element) => element.type != BubbleType.Directory).toList();
    switch (_bottomSheetState) {
      case _BottomSheetState.loading:
        return const Center(
          child: CircularProgressIndicator(
            color: Color.fromRGBO(0, 122, 255, 1),
          ),
        );
      case _BottomSheetState.list:
        return ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(
                    decelerationRate: ScrollDecelerationRate.fast)),
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: realBubbles?.length ?? 0,
            itemBuilder: (context, index) {
              final file = realBubbles![index];
              return _SendFileItem(entity: toUIBubble(file));
            });
      case _BottomSheetState.error:
        return Container(
            margin: const EdgeInsets.only(bottom: 15),
            width: double.infinity,
            height: 80,
            child: const Center(
              child: Text('加载错误了哦，一会再试试吧~'),
            ));
      case _BottomSheetState.empty:
        return Container(
            margin: const EdgeInsets.only(bottom: 15),
            width: double.infinity,
            height: 80,
            child: const Center(
              child: Text('无数据'),
            ));
      default:
        return Container();
    }
  }
}

enum _BottomSheetState { loading, list, error, empty }

class _SendFileItem extends StatefulWidget {
  const _SendFileItem({
    required this.entity,
  });

  final UIBubble entity;

  @override
  State<StatefulWidget> createState() {
    return _SendFileItemState();
  }
}

class _SendFileItemState extends State<_SendFileItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final SharedFile sharedFile = widget.entity.shareable as SharedFile;

    const Color contentColor = Colors.black;

    Widget stateIcon = const SizedBox(width: 20, height: 20);
    final size = sharedFile.content.size.formateBinarySize();
    String? stateDes;
    Color? stateDesColor;
    List<Color>? stateDesGradient;
    bool clickable = false;
    bool isSender = widget.entity.isSender();
    if (isSender) {
      switch (sharedFile.state) {
        case FileState.picked:
          break;
        case FileState.waitToAccepted:
          stateDes = '等待对方确认';
          stateDesColor = const Color.fromRGBO(60, 60, 67, 0.6);
          break;
        case FileState.inTransit:
          stateDes = _formatToPercentage(sharedFile.progress);
          stateDesGradient = [
            const Color.fromRGBO(0, 122, 255, 1),
            const Color.fromRGBO(81, 181, 252, 1)
          ];
          stateIcon = RotationTransition(
              turns: _controller,
              child: SvgPicture.asset(
            'assets/images/ic_loading.svg',
          ));
          break;
        case FileState.sendCompleted:
        case FileState.receiveCompleted:
        case FileState.completed:
          stateDes = '已发送';
          stateDesColor = const Color.fromRGBO(26, 189, 91, 1);
          stateIcon = SvgPicture.asset(
            'assets/images/ic_done.svg',
          );
          break;
        case FileState.sendFailed:
        case FileState.receiveFailed:
        case FileState.failed:
          stateDes = '发送异常';
          stateDesColor = const Color.fromRGBO(255, 59, 48, 1);
          clickable = true;
          stateIcon = SvgPicture.asset(
            'assets/images/ic_send_fail.svg',
          );
          break;
        case FileState.cancelled:
          stateDes = '已取消';
          stateDesColor = const Color.fromRGBO(255, 59, 48, 1);
          break;
        case FileState.unknown:
          throw StateError('Unknown send state: ${sharedFile.state}');
      }
    } else {
      switch (sharedFile.state) {
        case FileState.waitToAccepted:
          stateDes = '待接收';
          stateDesColor = const Color.fromRGBO(60, 60, 67, 0.6);
          break;
        case FileState.inTransit:
        case FileState.sendCompleted:
          stateDes = _formatToPercentage(sharedFile.progress);
          stateDesGradient = [
            const Color.fromRGBO(0, 122, 255, 1),
            const Color.fromRGBO(81, 181, 252, 1)
          ];
          stateIcon = RotationTransition(
              turns: _controller,
              child: SvgPicture.asset(
                'assets/images/ic_loading.svg',
              ));
          break;
        case FileState.receiveCompleted:
        case FileState.completed:
          stateDes = '已下载';
          stateDesColor = const Color.fromRGBO(26, 189, 91, 1);
          stateIcon = SvgPicture.asset(
            'assets/images/ic_done.svg',
          );
          break;
        case FileState.sendFailed:
        case FileState.receiveFailed:
        case FileState.failed:
          stateDes = '接收失败';
          clickable = true;
          stateDesColor = const Color.fromRGBO(255, 59, 48, 1);
          stateIcon = SvgPicture.asset(
            'assets/images/ic_send_fail.svg',
          );
          break;
        case FileState.cancelled:
          stateDes = '已取消';
          stateDesColor = const Color.fromRGBO(255, 59, 48, 1);
          break;
        case FileState.unknown:
        default:
          throw StateError('Unknown send state: ${sharedFile.state}');
      }
    }

    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: InkWell(
          onTap:  () {
            if(!clickable) {
              return;
            }
            if (isSender) {
              shipService.resend(widget.entity);
              flixToast.info("重新发送文件");
            } else {
              shipService.reReceive(widget.entity);
              flixToast.info("重新接收文件");
            }
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration:
                    FlixDecoration(borderRadius: BorderRadius.circular(6)),
                alignment: Alignment.center,
                child:
                    SvgPicture.asset(mimeIcon(sharedFile.content.path ?? '')),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sharedFile.content.name,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                              decoration: TextDecoration.none)
                          .fix(),
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Visibility(
                          visible: sharedFile.content.size > 0,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: Text(
                              size,
                              style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: Color.fromRGBO(60, 60, 67, 0.6))
                                  .fix(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        Visibility(
                          visible: stateDes != null,
                          child: stateDesGradient == null
                              ? Text(
                                  stateDes ?? '',
                                  style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                          color: stateDesColor ?? Colors.grey)
                                      .fix(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                )
                              : GradientText(
                                  text: stateDes ?? '',
                                  gradient:
                                      LinearGradient(colors: stateDesGradient),
                                  style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                          color: contentColor.withOpacity(0.5))
                                      .fix(),
                                ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: stateIcon,
              )
            ],
          ),
        ));
  }

  String _formatToPercentage(double number) {
    double percentage = (number * 100) % 100;
    return '${percentage.toStringAsFixed(1)}%';
  }
}
