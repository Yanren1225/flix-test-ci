import 'dart:io';
import 'package:flix/domain/device/device_profile_repo.dart';
import 'package:flix/main.dart';
import 'package:flix/presentation/style/colors/flix_color.dart';
import 'package:flix/theme/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;

class FileUploadServer extends StatefulWidget {
  @override
  _FileUploadServerState createState() => _FileUploadServerState();
}

class _FileUploadServerState extends State<FileUploadServer> {
  String? localIP;
  int port = 11451;
  HttpServer? server;
  final List<Map<String, dynamic>> messages = [];
  Directory? uploadDirectory;
  final List<WebSocket> clients = [];
  final TextEditingController _textController = TextEditingController();
  var deviceName = DeviceProfileRepo.instance.deviceName;

  @override
  void initState() {
    super.initState();
    startServer();
  }

  Future<void> startServer() async {
    try {
      uploadDirectory = await Directory.systemTemp.createTemp('flutter_uploads');
      for (var interface in await NetworkInterface.list()) {
        for (var addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4) {
            setState(() {
              localIP = addr.address;
            });
          }
        }
      }
      

      server = await HttpServer.bind(InternetAddress.anyIPv4, port);
      server!.listen((HttpRequest request) async {
        if (request.uri.path == '/files') {
          request.response.headers.contentType = ContentType.html;
          request.response.write(_generateChatHtml());
          request.response.close();
        } else if (request.uri.path.startsWith('/download/')) {
          // 文件下载处理逻辑
          String fileName = request.uri.pathSegments.last;
          File file = File(path.join(uploadDirectory!.path, fileName));
          if (file.existsSync()) {
            String encodedFileName = Uri.encodeComponent(fileName);
            String contentDispositionHeader =
                "attachment; filename*=UTF-8''$encodedFileName";

            request.response.headers.contentType = ContentType.binary;
            request.response.headers
                .add('Content-Disposition', contentDispositionHeader);
            request.response.add(file.readAsBytesSync());
          } else {
            request.response.statusCode = HttpStatus.notFound;
            request.response.write("File not found");
          }
          request.response.close();
        } else if (request.uri.path == '/ws') {
          if (WebSocketTransformer.isUpgradeRequest(request)) {
            WebSocket socket = await WebSocketTransformer.upgrade(request);
            clients.add(socket);
            socket.listen((data) {
              setState(() {
                messages.add({'type': 'text', 'content': data, 'from': 'html'});
              });
              notifyClients();
            }, onDone: () {
              clients.remove(socket);
            });
          }
        } else {
          request.response.write("Server is running!");
          request.response.close();
        }
      });

      print("Server running at http://$localIP:$port");
    } catch (e) {
      print("Error starting server: $e");
    }
  }

  String _generateChatHtml() {
  StringBuffer html = StringBuffer("""
    <!DOCTYPE html>
    <html>
    <head>
      <title>Flix 网页版</title>
      <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
      <style>
        body {
          font-family: Arial, sans-serif;
          background-color: #ffffff;
          margin: 0;
          padding: 0;
          display: flex;
          flex-direction: column;
          height: 100vh;
          overflow: hidden;
        }
        .header {
          width: 100%;
          max-width: 600px;
          background-color: #F2F2F2;
          padding: 15px;
          text-align: center;
          font-size: 18px;
          font-weight: bold;
          color: #000000;
          flex-shrink: 0;
          margin: auto; 
          box-sizing: border-box;
        }
        .chat-container {
          background-color: #F2F2F2;
          margin: auto; 
          flex: 1;
          max-width: 600px;
          width: 100%;
          overflow-y: auto;
          padding: 10px;
          padding-bottom: 80px; /* 为底部输入框留出空间 */
          display: flex;
          flex-direction: column;
          gap: 10px;
          box-sizing: border-box;
        }
        .bubble {
          padding: 10px 15px;
          border-radius: 15px;
          max-width: 80%;
          word-wrap: break-word;
          word-break: break-word;
        }
        .left {
          align-self: flex-start;
          background-color: #ffffff;
          color: #000000;
        }
        .right {
          align-self: flex-end;
          background-color: #007bff;
          color: #ffffff;
        }
        .footer {
          width: 100%;
          max-width: 600px;
          position: fixed; /* 固定在屏幕底部 */
          bottom: 0;
          left: 50%;
          transform: translateX(-50%);
          display: flex;
          align-items: center;
          background-color: #F2F2F2;
          padding: 10px;
         
          box-sizing: border-box;
          z-index: 10;
        }
        .footer input {
          flex: 1;
          padding: 10px;
          font-size: 16px;
          border: 1px solid #ccc;
          border-radius: 5px;
          margin-right: 10px;
          box-sizing: border-box;
        }
        .footer button {
          padding: 10px 20px;
          background-color: #007bff;
          color: #ffffff;
          border: none;
          border-radius: 5px;
          font-size: 16px;
          cursor: pointer;
        }
        .footer button:hover {
          background-color: #0056b3;
        }
      </style>
      <script>
        const socket = new WebSocket("ws://$localIP:$port/ws");
        
        // 监听消息事件
        socket.onmessage = function(event) {
          const message = event.data;

          // 如果消息是 "refresh"，执行刷新逻辑
          if (message === "refresh") {
            location.reload(); // 重新加载页面内容
          } else {
            appendMessage(message); // 处理并显示有效消息
          }
        };

        // 动态追加消息到聊天列表
        function appendMessage(message) {
          const container = document.querySelector('.chat-container');
          const div = document.createElement('div');
          div.className = 'bubble left'; // 默认左侧显示
          div.textContent = message;
          container.appendChild(div); // 添加到聊天区域
          scrollToBottom(); // 确保滚动到最新消息
        }

        // 滚动到聊天区域底部
        function scrollToBottom() {
          const container = document.querySelector('.chat-container');
          container.scrollTop = container.scrollHeight;
        }

        // 页面加载完成时初始化事件监听
        document.addEventListener("DOMContentLoaded", () => {
          const sendButton = document.getElementById("sendButton");
          const messageInput = document.getElementById("messageInput");

          // 监听发送按钮点击事件
          sendButton.addEventListener("click", () => {
            const message = messageInput.value.trim();
            if (message) {
              socket.send(message); // 将消息发送到服务器
              appendMessage(message); // 本地追加消息到聊天列表
              messageInput.value = ""; // 清空输入框
            }
          });

          scrollToBottom(); // 页面初次加载时滚动到底部
        });
      </script>
    </head>
    <body>
      <div class="header">$deviceName</div>
      <div class="chat-container">
  """);

  for (var message in messages) {
    if (message['type'] == 'file') {
      html.writeln("""
        <div class="bubble ${message['from'] == 'flutter' ? 'left' : 'right'}">
          <a href="/download/${message['content']}">${message['content']}</a>
        </div>
      """);
    } else if (message['type'] == 'text') {
      html.writeln("""
        <div class="bubble ${message['from'] == 'flutter' ? 'left' : 'right'}">
          ${message['content']}
        </div>
      """);
    }
  }

  html.writeln("""
      </div>
      <div class="footer">
        <input id="messageInput" type="text" placeholder="消息">
        <button id="sendButton">发送</button>
      </div>
    </body>
    </html>
  """);

  return html.toString();
}
  // 上传文件
  Future<void> pickAndSaveFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      PlatformFile file = result.files.first;
      File savedFile = File(path.join(uploadDirectory!.path, file.name));
      await File(file.path!).copy(savedFile.path);

      setState(() {
        messages.add({'type': 'file', 'content': file.name, 'from': 'flutter'});
      });
      notifyClients();
    }
  }

  // 通知 WebSocket 客户端
  void notifyClients() {
    for (var client in clients) {
      client.add("refresh");
    }
  }

  @override
  void dispose() {
    server?.close();
    for (var client in clients) {
      client.close();
    }
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).flixColors.background.secondary,
      appBar: AppBar(
        title: Text('$localIP:$port/files'),
      ),
      body: Column(
        children: [
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
                                            color: Theme.of(context)
                                                .flixColors
                                                .text
                                                .primary,
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
                  ),
                ),
                SizedBox(width: 8.0),
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
                      notifyClients();
                      _textController.clear();
                    }
                  },
                  child: Text("发送"),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: pickAndSaveFile,
                child: Text("发送文件"),
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
}