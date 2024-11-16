import 'dart:io';
import 'dart:math';
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
  final random = Random();
  int randomNumber = 0;
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
      
     
        randomNumber = 1000 + random.nextInt(9000); 


      server = await HttpServer.bind(InternetAddress.anyIPv4, port);
      server!.listen((HttpRequest request) async {
        print(request.uri.path);
        if (request.uri.path == '/$randomNumber') {
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
        } else{
            request.response.headers.contentType = ContentType.html;
          request.response.write(_generateMainpage());
          request.response.close();
        }
      });

      print("Server running at http://$localIP:$port");
    } catch (e) {
      print("Error starting server: $e");
    }
  }


  String _generateMainpage() {
  StringBuffer html = StringBuffer("""
    <!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <title>Flix 网页版</title>
    <style>
        html, body {
            font-family: Arial, sans-serif;
            background: #1A1A1A;
            color: #fff;
            margin: 0;
            padding: 0;
            height: 100%;
            overflow: hidden; /* 禁止滚动 */
        }

        /* 顶栏样式 */
        .top-bar {
            width: 100%;
            max-width: 1200px;
            height: 70px; /* 确定顶栏的固定高度 */
            margin: 0 auto;
            padding: 10px 20px;
            display: flex;
            align-items: center;
            justify-content: flex-start;
            box-sizing: border-box;
        }

        .logo {
            height: 30px;
            width: auto;
        }

        /* 页面内容样式 */
        .content {
            display: flex;
            justify-content: center;
            align-items: center;
            height: calc(100vh - 70px); /* 减去顶栏高度 */
            padding: 0 20px;
            box-sizing: border-box;
        }

        /* 移动端调整为靠顶部 */
        @media (max-width: 768px) {
            .content {
                flex-direction: column; /* 防止横向排版 */
                justify-content: flex-start; /* 靠顶部对齐 */
                align-items: stretch; /* 默认拉伸宽度 */
                height: auto; /* 高度不限制 */
                margin-top: 20px;
            }
        }

        .container {
            text-align: center;
            background: rgba(255, 255, 255, 0.1);
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.3);
            width: 90%;
            max-width: 400px;
        }

        .title {
            margin-bottom: 20px;
            font-size: 24px;
            font-weight: bold;
        }

        .form-group {
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 10px;
        }

        input[type="text"] {
            flex: 1; /* 输入框占用剩余空间 */
            padding: 10px;
            border: none;
            border-radius: 5px;
            font-size: 16px;
            outline: none;
            color: #fff;
            background: #333;
        }

        input[type="text"]::placeholder {
            color: #bbb;
        }

        button {
            padding: 10px 20px;
            border: none;
            border-radius: 5px;
            background-color: #ffffff;
            color: #1A1A1A;
            font-size: 16px;
            cursor: pointer;
            transition: background-color 0.3s, color 0.3s;
        }

        button:hover {
            background-color: #555;
            color: #fff;
        }

        @media (max-width: 768px) {
            .title {
                font-size: 20px;
            }
            input[type="text"], button {
                font-size: 14px;
            }
        }
    </style>
</head>
<body>
    <!-- 顶栏 -->
    <div class="top-bar">
       <svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="178.50140380859375" height="32" viewBox="0 0 178.50140380859375 32" fill="none" class="logo" role="img" aria-label="Web Logo">
  <g clip-path="url(#clip-path-433_1256)">
    <path d="M8.65167 4.68006L7.54871 9.09193L28.261 9.09193C30.2749 9.09193 32.0303 7.72128 32.5188 5.76746L32.5954 5.46122C32.8032 4.6302 32.1747 3.8252 31.318 3.8252L9.74654 3.8252C9.22868 3.8252 8.77727 4.17765 8.65167 4.68006Z" fill="#F0F6FC"></path>
    <path d="M5.14142 23.995L4.03845 28.4069L8.7312 28.4069C10.7451 28.4069 12.5006 27.0362 12.9891 25.0824L13.0656 24.7762C13.2734 23.9451 12.6449 23.1401 11.7883 23.1401L6.23629 23.1401C5.71843 23.1401 5.26702 23.4926 5.14142 23.995Z" fill="#F0F6FC"></path>
    <path d="M6.8963 14.3363L5.79333 18.7482L17.0526 18.7482C17.9157 18.7482 18.668 18.1608 18.8774 17.3234L19.2536 15.8186C19.5504 14.6315 18.6525 13.4814 17.4288 13.4814L7.99117 13.4814C7.47331 13.4814 7.0219 13.8339 6.8963 14.3363Z" fill="#007AFF"></path>
    <path d="M15.226 21.601L26.1018 14.2845C26.4613 14.0426 26.2901 13.4814 25.8568 13.4814L17.0912 13.4814L15.226 21.601Z" fill="#0A84FF"></path>
  </g>
  <path fill-rule="evenodd" fill="#F0F6FC" d="M50.3112 8.94227L50.3112 14.3501L58.8512 14.3501L58.8512 17.8332L50.3112 17.8332L50.3112 26.5408L46.0574 26.5408L46.0574 5.45923L60.28 5.45923L60.28 8.94227L50.3112 8.94227ZM68.1381 26.5408C65.7027 26.5408 64.3552 25.2881 64.3552 25.2881C63.0076 24.0354 63.0076 21.7134 63.0076 21.7134L63.0076 5.45923L67.0341 5.45923L67.0341 21.469C67.0341 22.4467 67.4075 22.8591 67.4075 22.8591C67.7809 23.2716 68.6252 23.2716 68.6252 23.2716L69.989 23.2716L69.989 26.5408L68.1381 26.5408ZM72.4893 10.6532L76.4833 10.6532L76.4833 26.5408L72.4893 26.5408L72.4893 10.6532ZM72.4244 5.45923L76.5158 5.45923L76.5158 8.48397L72.4244 8.48397L72.4244 5.45923ZM88.8226 26.5408L85.7053 21.5301L82.9127 26.5408L78.6914 26.5408L83.757 18.3526L78.9836 10.6532L83.205 10.6532L85.9975 15.1751L88.4978 10.6532L92.7192 10.6532L87.8809 18.2304L93.0114 26.5408L88.8226 26.5408Z"></path>
</svg>

    </div>

    <!-- 主内容 -->
    <div class="content">
        <div class="container">
          
            <form onsubmit="redirect(event)">
                <div class="form-group">
                    <input type="text" id="ipInput" placeholder="输入连接码" required>
                    <button type="submit">连接</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        function redirect(event) {
            event.preventDefault();
            const ip = document.getElementById('ipInput').value.trim();
            if (ip == $randomNumber) {
                window.location.href = "/" + ip;
            } else {
                alert("连接码错误，请重新输入！");
            }
        }
    </script>
</body>
</html>

  """);

  

  return html.toString();
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
          div.className = 'bubble left'; 
          div.textContent = message;
          container.appendChild(div); // 添加到聊天区域
          scrollToBottom(); 
        }

       
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

          scrollToBottom();
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
      
      body: Column(
        children: [
           Padding(
                 padding: const EdgeInsets.only(left: 20, top: 44, right: 20),
                  child: Text(
                    '打开浏览器输入：$localIP:$port，连接码：$randomNumber',
                    style: TextStyle(
                          fontSize: 13.5,
                           fontWeight: FontWeight.normal,
                          color: Theme.of(context).flixColors.text.secondary)
                      
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