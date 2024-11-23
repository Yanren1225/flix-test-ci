import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flix/domain/device/device_profile_repo.dart';
import 'package:flix/domain/webconnected.dart';
import 'package:flix/presentation/widgets/flix_toast.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';

final List<Map<String, dynamic>> messages = [];
Directory? uploadDirectory;
final List<WebSocket> clients = [];
String? localIP;
int port = 8892;
int randomNumber = 0;
var deviceName = DeviceProfileRepo.instance.deviceName;


/// 启动服务器
Future<void> startWebServer() async {
  try {
    uploadDirectory = await Directory.systemTemp.createTemp('flutter_uploads');
    for (var interface in await NetworkInterface.list()) {
      for (var addr in interface.addresses) {
        if (addr.type == InternetAddressType.IPv4) {
          localIP = addr.address;
        }
      }
    }

    randomNumber = 1000 + Random().nextInt(9000); 

    HttpServer server = await HttpServer.bind(InternetAddress.anyIPv4, port);
    server.listen((HttpRequest request) async {
      if (request.uri.path == '/validate-code') {
        String body = await utf8.decoder.bind(request).join();
        Map<String, dynamic> data = jsonDecode(body);
        if (data['code'] == randomNumber.toString()) {
          request.response.statusCode = HttpStatus.ok;
        } else {
          request.response.statusCode = HttpStatus.unauthorized;
        }
        await request.response.close();
      } else if (request.uri.path == '/$randomNumber') {
       
        WebConnectionManager().setWebConnected(true);
        request.response.headers.contentType = ContentType.html;
        request.response.write(_generateChatHtml());
        request.response.close();
        
      } else if (request.uri.path.startsWith('/download/')) {
        // 文件下载逻辑
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
      }  else if (request.uri.path == '/ws') {
        if (WebSocketTransformer.isUpgradeRequest(request)) {
          WebSocket socket = await WebSocketTransformer.upgrade(request);
          clients.add(socket);
          socket.listen((data) {
            messages.add({'type': 'text', 'content': data, 'from': 'html'});
            notifyClients();
            
          }, onDone: () {
            clients.remove(socket);
          });
        }
      }else if (request.uri.path == '/upload' && request.method == 'POST') {
       
  final contentType = request.headers.contentType;
  if (contentType?.mimeType == 'multipart/form-data') {
    final boundary = contentType!.parameters['boundary']!;
    final transformer = MimeMultipartTransformer(boundary);

   
    final parts = await transformer.bind(request).toList();
    for (var part in parts) {
      final contentDisposition = part.headers['content-disposition'];
      final filenameMatch = RegExp(r'filename="(.+)"').firstMatch(contentDisposition ?? '');
      if (filenameMatch != null) {
        final fileName = filenameMatch.group(1);
        final file = File(path.join(uploadDirectory!.path, fileName!));
final savedFilePath = path.join(uploadDirectory!.path, fileName);
        // 保存文件
        final sink = file.openWrite();
        await part.pipe(sink);
        await sink.close();

      
       final message = {
  'type': 'file',
  'content': savedFilePath, 
  'fileName': fileName,
  'from': 'html'
};
 messages.add(message);
       notifyClients();
        
      }
    }
  }
  request.response.statusCode = HttpStatus.ok;
  await request.response.close();
}else if (request.uri.path == '/logout') {
          WebConnectionManager().setWebConnected(false);
        request.response.headers.contentType = ContentType.html;
        request.response.write(_generateMainpage());
        request.response.close();
        
      } else {
        request.response.headers.contentType = ContentType.html;
        request.response.write(_generateMainpage());
        request.response.close();
      }
    });

    print("Server running at http://$localIP:$port \nConnect code: $randomNumber");
  } catch (e) {
    print("Error starting server: $e");
  }
}

void notifyClients() {
  for (var client in clients) {
    client.add("refresh");
  }
}

/// 上传文件
Future<void> saveUploadedFile(String filePath) async {
  File file = File(filePath);
  File savedFile = File(path.join(uploadDirectory!.path, path.basename(filePath)));
  await file.copy(savedFile.path);

  messages.add({'type': 'file', 'content': path.basename(filePath), 'from': 'flutter'});
  notifyClients();
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
    async function redirect(event) {
        event.preventDefault();
        const ip = document.getElementById('ipInput').value.trim();
        try {
            const response = await fetch('/validate-code', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ code: ip })
            });
            if (response.ok) {
                window.location.href = "/" + ip;
            } else {
                alert("连接码错误，请重新输入！");
            }
        } catch (e) {
            console.error("请求失败：", e);
            alert("连接码验证失败，请稍后再试！");
        }
    }
</script>

</body>
</html>

  """);

  

  return html.toString();
}


/// 生成聊天页面 HTML
String _generateChatHtml() {
  StringBuffer html = StringBuffer("""
    <!DOCTYPE html>
    <html>
    <head>
      <title>Flix 网页版</title>
      <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
      
      <style>
       


       html, body {
       font-family: Arial, sans-serif;
          background-color: #ffffff;
    margin: 0;
    padding: 0;
    height: 100%;
    overflow: hidden;
    display: flex;
    flex-direction: column; 
}

      .header {
    position: sticky; 
    top: 0; 
    width: 100%;
    max-width: 600px;
    background-color: #F2F2F2;
    padding: 15px;
    text-align: center;
    font-size: 18px;
    font-weight: bold;
    box-sizing: border-box;
    z-index: 10; 
}
        .chat-container {
    position: relative;
    overflow-y: auto;
    box-sizing: border-box;
    padding: 10px;
}

  .bubble {
    padding: 10px 15px;
    border-radius: 12.5px;
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
        .chat-container {
          background-color: #F2F2F2;
          margin: auto; 
          flex: 1;
          max-width: 600px;
          width: 100%;
          overflow-y: auto;
          padding: 10px;
          padding-bottom: 100px; 
          display: flex;
          flex-direction: column;
          gap: 10px;
          box-sizing: border-box;
        }
        .bubble {
          padding: 10px 15px;
          border-radius: 12.5px;
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
          position: fixed; 
          bottom: 0;
          left: 50%;
          transform: translateX(-50%);
          display: flex;
          flex-wrap: wrap; 
          gap: 10px;
          background-color: #F2F2F2;
          padding: 10px;
          box-sizing: border-box;
          z-index: 10;
        }
        .footer input[type="text"] {
          flex: 1;
          padding: 10px;
          font-size: 16px;
          border: 1px solid #ccc;
          border-radius: 5px;
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
        .footer input[type="file"] {
          display: none; 
        }
      </style>
      <script>
       document.addEventListener("visibilitychange", function () {
            if (document.visibilityState === "visible") {
                location.reload();
            }
        });


       
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
    container.appendChild(div);

    
    setTimeout(() => scrollToBottom(true), 100);
}

       
       function scrollToBottom() {
  const container = document.querySelector('.chat-container');
  if (container) {
    requestAnimationFrame(() => {
      container.scrollTop = container.scrollHeight;
    });
  }
}


        // 页面加载完成时初始化事件监听
        document.addEventListener("DOMContentLoaded", () => {
          const sendButton = document.getElementById("sendButton");
          const messageInput = document.getElementById("messageInput");
          const uploadButton = document.getElementById("uploadButton");
          const fileInput = document.getElementById("fileInput");

          // 监听发送按钮点击事件
          sendButton.addEventListener("click", () => {
            const message = messageInput.value.trim();
            if (message) {
               location.reload();
              socket.send(message); // 将消息发送到服务器
              appendMessage(message); // 本地追加消息到聊天列表
              messageInput.value = ""; // 清空输入框
            }
          });

          // 文件上传按钮点击事件
          uploadButton.addEventListener("click", () => {
            fileInput.click(); // 打开文件选择对话框
          });

          // 文件选择事件
          fileInput.addEventListener("change", async (event) => {
            const file = event.target.files[0];
            if (file) {
              const formData = new FormData();
              formData.append('file', file);

              try {
                const response = await fetch('/upload', {
                  method: 'POST',
                  body: formData,
                });

                if (response.ok) {
                // alert('文件上传成功');
                  fileInput.value = ''; // 清空文件输入框
                } else {
                  alert('文件上传失败');
                }
              } catch (error) {
                console.error('文件上传错误:', error);
                
                alert(error);
              }
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
    if (message['type'] == 'file' && message['from'] == 'flutter') {
      html.writeln("""
        <div style="background:#ffffff; width:260px;height:70px"  class="bubble ${message['from'] == 'flutter' ? 'left' : 'right'}">
          <a style="color:#000000; text-decoration: none;"  href="/download/${message['content']}">${message['content']}</a>
        </div>
      """);
    } else if (message['type'] == 'file' && message['from'] == 'html') {
      html.writeln("""
       <div style="background:#ffffff; width:260px;;height:70px" class="bubble ${message['from'] == 'flutter' ? 'left' : 'right'}">
  <a style="color:#000000; text-decoration: none;" href="/download/${message['content']}">${message['fileName']}</a>
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
      
        <input id="fileInput" type="file" />
     
        <svg  id="uploadButton" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="22" height="22" viewBox="0 0 22 22" fill="none">
<path d="M2.44434 4.58279L2.44434 17.4161C2.44434 19.2724 3.94916 20.7772 5.80545 20.7772L16.1943 20.7772C18.0506 20.7772 19.5554 19.2724 19.5554 17.4161L19.5554 8.14435C19.5554 7.86077 19.5012 7.58807 19.3928 7.32625C19.2842 7.06424 19.1296 6.83284 18.9288 6.63205L14.1468 1.85001C13.9463 1.64841 13.7143 1.49314 13.451 1.3842C13.1891 1.27585 12.9164 1.22168 12.6328 1.22168L5.80545 1.22168C3.94916 1.22168 2.44434 2.7265 2.44434 4.58279ZM16.4259 6.7218L14.0554 4.35136L14.0554 6.41625C14.0554 6.585 14.1922 6.7218 14.361 6.7218L16.4259 6.7218ZM12.2221 3.05501L5.80545 3.05501C4.96167 3.05501 4.27767 3.73902 4.27767 4.58279L4.27767 17.4161C4.27767 18.2599 4.96167 18.9439 5.80545 18.9439L16.1943 18.9439C17.0382 18.9439 17.7221 18.2599 17.7221 17.4161L17.7221 8.55514L14.361 8.55514C13.1797 8.55514 12.2221 7.59752 12.2221 6.41625L12.2221 3.05501Z" fill-rule="evenodd"  fill="#000000" >
</path>
</svg>


<svg id="sendButton" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="26" height="26" viewBox="0 0 26 26" fill="none">
<path d="M2.23826 7.24025L5.35285 12.4348C5.5641 12.7815 5.55868 13.2094 5.35826 13.5561L2.23285 18.7507C0.575347 21.5132 3.50576 24.7415 6.41993 23.3602L22.0741 15.9286C24.5495 14.7532 24.5441 11.2269 22.0633 10.0515L6.41451 2.63608C3.51118 1.26025 0.586181 4.48316 2.23826 7.24025ZM7.67524 12.9889C7.67524 12.3931 8.16274 11.9056 8.75858 11.9056L15.2586 11.9056C15.8544 11.9056 16.3419 12.3931 16.3419 12.9889C16.3419 13.5847 15.8544 14.0722 15.2586 14.0722L8.75858 14.0722C8.16274 14.0722 7.67524 13.5847 7.67524 12.9889Z" fill-rule="evenodd"  fill="#007AFF" >
</path>
</svg>


      </div>
    </body>
    </html>
  """);

  return html.toString();
}