import 'dart:convert';
import 'dart:io';
import 'package:flix/domain/web_server.dart';
import 'package:flix/presentation/style/colors/flix_color.dart';
import 'package:flix/theme/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';


class FileUploadServer extends StatefulWidget {
  @override
  _FileUploadServerState createState() => _FileUploadServerState();
}

class _FileUploadServerState extends State<FileUploadServer> {
  final TextEditingController _textController = TextEditingController();
late WebSocket _socket;

  @override
  void initState() {
    super.initState();
    _connectWebSocket();
  }

  /// 连接 WebSocket
  void _connectWebSocket() async {
    try {
      _socket = await WebSocket.connect('ws://$localIP:$port/ws');
      _socket.listen((data) {
        if (data == "refresh") {
          setState(() {}); // 收到刷新通知时，更新界面
        } else {
          final message = jsonDecode(data);
          setState(() {
            messages.add(message); // 添加新消息到列表
          });
        }
      });
    } catch (e) {
      print("WebSocket connection error: $e");
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).flixColors.background.secondary,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 44, right: 20),
            child: Text(
              '打开浏览器输入：$localIP:$port，连接码：$randomNumber',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.normal,
               
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return _buildBubble(messages[index]);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    style: TextStyle(
                    
                      fontSize: 16,
                    ),
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
                          horizontal: 12, vertical: 8),
                    ),
                    cursorColor: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(width: 8.0),
                ElevatedButton(
                  onPressed: () {
                    if (_textController.text.trim().isNotEmpty) {
                      setState(() {
                        messages.add({
                          'type': 'text',
                          'content': _textController.text.trim(),
                          'from': 'flutter'
                        });
                      });
                      notifyClients(); // 通知 WebSocket 客户端
                      _textController.clear();
                    }
                  },
                  child: const Text("发送"),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _pickAndSendFile,
                child: const Text("发送文件"),
              ),
            ),
          ),
        ],
      ),
    );
  }

   Widget _buildBubble(Map<String, dynamic> message) {
  bool isFlutter = message['from'] == 'flutter';
  bool isFile = message['type'] == 'file';
  return Align(
    alignment: isFlutter ? Alignment.centerRight : Alignment.centerLeft,
    child: Container(
      margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
      padding: EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: isFile
            ? Theme.of(context).flixColors.background.primary 
            : isFlutter
                ? FlixColor.blue 
                : Theme.of(context).flixColors.background.primary , 
        borderRadius: BorderRadius.circular(15.0),
        
      ),
      child: isFile
          ? GestureDetector(
              onTap: () {
                
                print("Download link: /download/${message['content']}");
              },
              child: Text(
                message['content'],
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
    );
  }

  /// 选择并发送文件
  Future<void> _pickAndSendFile() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles();
  if (result != null) {
    String filePath = result.files.single.path!;
    await saveUploadedFile(filePath); // 调用 server.dart 的文件保存逻辑

    // 不手动添加消息到 messages，交给 WebSocket 通信处理
    notifyClients(); // 通知 WebSocket 客户端刷新
  }
}

}
