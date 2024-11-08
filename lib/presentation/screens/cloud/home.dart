import 'package:flix/theme/theme_extensions.dart';
import 'package:flix/utils/text/text_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webdav_client/webdav_client.dart' as webdav;
import 'webdav_file_manager.dart'; 

class CloudScreenPage extends StatefulWidget {
  const CloudScreenPage({super.key});

  @override
  _CloudScreenPageState createState() => _CloudScreenPageState();
}

class _CloudScreenPageState extends State<CloudScreenPage> {
  List<Map<String, String>> webDavList = []; 
  List<String> connectionStatuses = []; 

  @override
  void initState() {
    super.initState();
    _loadWebDavList(); 
  }


// 加载保存的 WebDAV 列表
Future<void> _loadWebDavList() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  setState(() {
    webDavList = (prefs.getStringList('webdav_list') ?? []).map((item) {
      return Map<String, String>.from(Uri.splitQueryString(item));
    }).toList();

    if (webDavList.isEmpty) {
      webDavList = [
        {
          'name': 'Webdav',
          'url': '',
          'user': '',
          'password': '',
        },
        {
          'name': '坚果云',
          'url': '',
          'user': '',
          'password': '',
        },
        {
          'name': '阿里云',
          'url': '',
          'user': '',
          'password': '',
        },
      ];
    }

 
    connectionStatuses = List.generate(webDavList.length, (_) => '正在连接');
  });


  _checkAllConnections();
}




  Future<void> _checkAllConnections() async {
    for (int i = 0; i < webDavList.length; i++) {
      _checkConnection(i);
    }
  }


  Future<void> _checkConnection(int index) async {
    final webDav = webDavList[index];
    String url = webDav['url']!;
    String user = webDav['user']!;
    String password = webDav['password']!;

    // 创建 WebDAV 客户端实例
    final client = webdav.newClient(
      url,
      user: user,
      password: password,
      debug: true,
    );

    try {
      await client.ping(); // 尝试连接服务器
      setState(() {
        connectionStatuses[index] = '已连接'; 
      });
    } catch (e) {
      setState(() {
        connectionStatuses[index] = '连接失败'; 
      });
    }
  }

  // 保存 WebDAV 列表
  Future<void> _saveWebDavList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> list = webDavList.map((item) => Uri(queryParameters: item).query).toList();
    await prefs.setStringList('webdav_list', list);
  }

  // 添加 WebDAV
  Future<void> _addWebDav() async {
    _showWebDavDialog(); 
  }

  // 删除 WebDAV 连接
  void _deleteWebDav(int index) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('确认删除'),
          content: const Text('您确定要删除该 WebDAV 连接吗？'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); 
                
              },
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  webDavList.removeAt(index);
                  connectionStatuses.removeAt(index); // 同时移除状态
                });
                _saveWebDavList(); // 保存更新后的列表
            
                Navigator.of(context).pop(); 
                
              },
              child: const Text('确认'),
              
            ),
          ],
        );
      },
    );
  }


void _navigateToFileManager(Map<String, String> webDavInfo) {
  final client = webdav.newClient(
    webDavInfo['url']!,
    user: webDavInfo['user']!,
    password: webDavInfo['password']!,
    debug: true,
  );

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => WebDavFileManagerPage(
        webDavInfo: webDavInfo,
        currentPath: '/', 
        client: client,   
      ),
    ),
  );
}



  // 下拉刷新
  Future<void> _refreshWebDavList() async {
    await _loadWebDavList(); 
    
  }

  @override
  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Theme.of(context).flixColors.background.secondary,
    appBar: AppBar(
     backgroundColor: Theme.of(context).flixColors.background.secondary,
      actions: [
        IconButton(
          icon: const Icon(Icons.add), 
          onPressed: _addWebDav, 
        ),
      ],
    ),
    body: RefreshIndicator(
      backgroundColor: Theme.of(context).flixColors.background.secondary,
      onRefresh: _refreshWebDavList, 
      child: Column(
        children: [
          const SizedBox(height: 8.0),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                  SvgPicture.asset(
              'assets/images/ic_cross_device.svg',
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                  Theme.of(context).flixColors.text.primary, BlendMode.srcIn),
            ),
            const SizedBox(height: 30),
            Text(
              '云备份',
              style: const TextStyle(fontSize: 30).fix(),
            ),
            const SizedBox(height: 2),
            Text(
              '请选择一个备份服务',
              style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).flixColors.text.secondary)
                  .fix(),
            ),
                const SizedBox(height: 16.0),
                
              ],
            ),
          ),
       Expanded(
  child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0), 
    child: ListView.builder(
      itemCount: webDavList.length,
      itemBuilder: (context, index) {
        final webDav = webDavList[index];

        return Center( 
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400), 
            child: Card(
              margin: const EdgeInsets.symmetric(vertical: 4.0), 
              elevation: 0, 
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0), 
              ),
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0), 
                ),
             
                title: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 16.0), 
                  child: Text(
                    webDav['name'] ?? '未知名称',
                    style: const TextStyle(
                      fontSize: 16, 
                    
                    ),
                  ),
                ),
                onTap: () {
                  if (webDav['url'] == null || webDav['url']!.isEmpty) {
                    _editWebDav(index); 
                  } else {
                    _navigateToFileManager(webDav); 
                  }
                },
                trailing: PopupMenuButton<String>(
                  onSelected: (String result) {
                    if (result == 'edit') {
                      _editWebDav(index); 
                    } else if (result == 'delete') {
                      _deleteWebDav(index); 
                    }
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'edit',
                      child: ListTile(
                        leading: Icon(Icons.edit), 
                        title: Text('编辑'),
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Icons.delete), 
                        title: Text('删除'),
                      ),
                    ),
                  ],
                  icon: const Icon(Icons.more_vert), 
                ),
              ),
            ),
          ),
        );
      },
    ),
  ),
),


        ],
      ),
    ),
  );
}


  // 显示添加/编辑 WebDAV 弹窗
  Future<void> _showWebDavDialog({
    int? index, 
    String initialName = '',
    String initialAddress = 'http://',
    String initialUser = '',
    String initialPassword = '',
  }) async {
    TextEditingController nameController = TextEditingController(text: initialName);
    TextEditingController addressController = TextEditingController(text: initialAddress);
    TextEditingController userController = TextEditingController(text: initialUser);
    TextEditingController passwordController = TextEditingController(text: initialPassword);
    bool obscurePassword = true; 
    bool showNameError = false;
    bool showAddressError = false;
    bool showUserError = false;
    bool showPasswordError = false;
    bool showInvalidAddressError = false; 

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(index == null ? '添加 WebDAV 连接' : '编辑 WebDAV 连接'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    TextField(
                      controller: addressController,
                      decoration: InputDecoration(
                        labelText: '地址',
                        hintText: '以 http:// 或 https:// 开头',
                        errorText: showAddressError
                            ? '地址不能为空'
                            : (showInvalidAddressError ? '地址格式不正确' : null), 
                      ),
                    ),
                    TextField(
                      controller: userController,
                      decoration: InputDecoration(
                        labelText: '用户名',
                        errorText: showUserError ? '用户名不能为空' : null,
                      ),
                    ),
                    TextField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        labelText: '密码',
                        errorText: showPasswordError ? '密码不能为空' : null,
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () {
                            setStateDialog(() {
                              obscurePassword = !obscurePassword; 
                            });
                          },
                        ),
                      ),
                      obscureText: obscurePassword,
                    ),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: '备注',
                        errorText: showNameError ? '备注不能为空' : null,
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('取消'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('保存'),
                  onPressed: () {
                    // 验证字段是否为空
                    setStateDialog(() {
                      showNameError = nameController.text.isEmpty;
                      showAddressError = addressController.text.isEmpty;
                      showUserError = userController.text.isEmpty;
                      showPasswordError = passwordController.text.isEmpty;
                      // 验证地址格式
                      showInvalidAddressError = !_isValidUrl(addressController.text);
                    });

                    // 保存数据
                    if (!showNameError &&
                        !showAddressError &&
                        !showUserError &&
                        !showPasswordError &&
                        !showInvalidAddressError) {
                      setState(() {
                        if (index == null) {
                   
                          webDavList.add({
                            'name': nameController.text,
                            'url': addressController.text,
                            'user': userController.text,
                            'password': passwordController.text,
                          });
                          connectionStatuses.add('正在连接'); 
                          _checkConnection(webDavList.length - 1); 
                        } else {
                    
                          webDavList[index] = {
                            'name': nameController.text,
                            'url': addressController.text,
                            'user': userController.text,
                            'password': passwordController.text,
                          };
                          connectionStatuses[index] = '正在连接'; 
                          _checkConnection(index); 
                        }
                      });

                      _saveWebDavList();
                     Navigator.of(context).pop(); 
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

// 检查地址是否以 http:// 或 https:// 开头，并且后面有内容
bool _isValidUrl(String url) {
  if (url.startsWith('http://') || url.startsWith('https://')) {
    String withoutScheme = url.replaceFirst(RegExp(r'^https?://'), '');
    return withoutScheme.isNotEmpty;
  }
  return false;
}

  // 编辑 WebDAV
  Future<void> _editWebDav(int index) async {
    final webDav = webDavList[index];
    _showWebDavDialog(
      index: index, 
      initialName: webDav['name']!,
      initialAddress: webDav['url']!,
      initialUser: webDav['user']!,
      initialPassword: webDav['password']!,
    );
  }
}