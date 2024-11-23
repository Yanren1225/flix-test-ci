import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flix/domain/web_server.dart';
import 'package:flix/presentation/screens/main_screen.dart';
import 'package:flix/presentation/style/colors/flix_color.dart';
import 'package:flix/presentation/widgets/segements/navigation_scaffold.dart';
import 'package:flix/theme/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class FileUploadServer extends StatefulWidget {
  bool showBack = true;

FileUploadServer({super.key,required this.showBack});
  @override
  _FileUploadServerState createState() => _FileUploadServerState();
}

class _FileUploadServerState extends State<FileUploadServer> {
  final TextEditingController _textController = TextEditingController();
  late WebSocket _socket;

Timer? _timer; 

  @override
  void initState() {
    super.initState();
    //TODO:临时方案
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {}); 
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  
 void clearThirdWidget() {
    Provider.of<BackProvider>(context, listen: false).backMethod();
  }

 @override
Widget build(BuildContext context) {
  return NavigationScaffold(
    title: 'Web Flix',
    onClearThirdWidget: clearThirdWidget,
    showBackButton: widget.showBack,
    builder: (EdgeInsets padding) {
      return Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 100), 
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return _buildBubble(messages[index]);
              },
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Theme.of(context).flixColors.background.secondary,
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          style: TextStyle(fontSize: 16),
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          decoration: InputDecoration(
                            isDense: true,
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            filled: true,
                            fillColor: Theme.of(context).cardColor,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          cursorColor: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      ElevatedButton(
                        onPressed: _sendMessage,
                        child: const Text("发送"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _pickAndSendFile,
                      child: const Text("发送文件"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    },
  );
}
 
  

  

  
  Widget _buildBubble(Map<String, dynamic> message) {
  bool isFlutter = message['from'] == 'flutter';
  bool isFile = message['type'] == 'file';
  return Align(
    alignment: isFlutter ? Alignment.centerRight : Alignment.centerLeft,
    child: ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: 270, 
      ),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
        padding: EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: isFile
              ? Theme.of(context).flixColors.background.primary
              : isFlutter
                  ? FlixColor.blue
                  : Theme.of(context).flixColors.background.primary,
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: isFile
            ? GestureDetector(
                onTap: () => _downloadFile(message['content']),
                child: 
                
                Text(
                  isFlutter?
                  message['content']
                  :message['fileName'],
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: Colors.blue[900],
                  ),
                ),
              )
            : Text(
                message['content'],
                style: TextStyle(
                  color: isFlutter ? Colors.white : Colors.black,
                ),
              ),
      ),
    ),
  );
}

  
  void _sendMessage() {
    if (_textController.text.trim().isNotEmpty) {
      setState(() {
        messages.add({
          'type': 'text',
          'content': _textController.text.trim(),
          'from': 'flutter'
        });
      });
      notifyClients(); 
      _textController.clear();
    }
  }

  
  Future<void> _pickAndSendFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      String filePath = result.files.single.path!;
      await saveUploadedFile(filePath);
      notifyClients(); 
    }
  }

  /// 下载文件
  Future<void> _downloadFile(String filePath) async {
    try {
      final directory = await getDownloadsDirectory();
      if (directory != null) {
        final fileName = filePath.split('/').last;
        final destination = File('${directory.path}/$fileName');
        await File(filePath).copy(destination.path);
        print("文件已保存到: ${destination.path}");
      } else {
        print("无法获取下载目录");
      }
    } catch (e) {
      print("文件下载失败: $e");
    }
  }
}