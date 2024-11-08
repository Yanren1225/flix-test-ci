

import 'package:flix/theme/theme_extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:webdav_client/webdav_client.dart' as webdav;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:intl/intl.dart'; 
import 'package:shared_preferences/shared_preferences.dart'; 
import 'package:provider/provider.dart';


class WebDavFileManagerPage extends StatefulWidget {
  final Map<String, String> webDavInfo; 
  final String currentPath; 
  final webdav.Client client; 

  const WebDavFileManagerPage({
    super.key,
    required this.webDavInfo,
    required this.currentPath,
    required this.client, 
  });

  @override
  _WebDavFileManagerPageState createState() => _WebDavFileManagerPageState();
}

class _WebDavFileManagerPageState extends State<WebDavFileManagerPage> {
  late webdav.Client client;
  List<webdav.File> fileList = []; 
  bool isLoading = true; 
  String currentSortMethod = '时间排序倒序'; 
  late String currentPath; 

  final List<String> sortOptions = [
    'A - Z',
    'Z - A',
    '时间排序正序',
    '时间排序倒序',
    '文件从大到小',
    '文件从小到大',
  ];

  @override
  void initState() {
    super.initState();
    client = widget.client; 
    currentPath = widget.currentPath; 
    _loadSortMethod(); 
    _initWebDavClient(); 
  }


  Future<void> _loadSortMethod() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      currentSortMethod = prefs.getString('sort_method') ?? '时间排序倒序'; 
    });
  }

 
  Future<void> _saveSortMethod(String method) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('sort_method', method); 
  }

  // 初始化 WebDAV 客户端并检测连接
  void _initWebDavClient() async {
    try {
      await client.ping(); 
      if (!mounted) return;
      _fetchFiles(currentPath); 
    } catch (e) {
      if (!mounted) return;
      _showConnectionErrorDialog();
    }
  }

  void _showConnectionErrorDialog() {
    if (!mounted) return;
    showDialog<void>(
      context: context,
      barrierDismissible: false, 
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('连接失败'),
          content: const Text('无法连接到 WebDAV 服务器。请检查您的网络或服务器信息。'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); 
                Navigator.of(context).pop();
              },
              child: const Text('确认'),
            ),
          ],
        );
      },
    );
  }

  // 获取 WebDAV 文件
  Future<void> _fetchFiles(String path) async {
    setState(() {
      isLoading = true;
    });
    try {
      var files = await client.readDir(path);
      if (!mounted) return;
      setState(() {
        fileList = _sortFiles(files);
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching files: $e');
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  // 文件排序方法
  List<webdav.File> _sortFiles(List<webdav.File> files) {
    List<webdav.File> folders = files.where((file) => file.isDir == true).toList();
    List<webdav.File> normalFiles = files.where((file) => file.isDir != true).toList();

    switch (currentSortMethod) {
      case 'A - Z':
        folders.sort((a, b) => a.name!.compareTo(b.name!));
        normalFiles.sort((a, b) => a.name!.compareTo(b.name!));
        break;
      case 'Z - A':
        folders.sort((a, b) => b.name!.compareTo(a.name!));
        normalFiles.sort((a, b) => b.name!.compareTo(a.name!));
        break;
      case '时间排序正序':
        folders.sort((a, b) => a.mTime!.compareTo(b.mTime!));
        normalFiles.sort((a, b) => a.mTime!.compareTo(b.mTime!));
        break;
      case '时间排序倒序':
        folders.sort((a, b) => b.mTime!.compareTo(a.mTime!));
        normalFiles.sort((a, b) => b.mTime!.compareTo(a.mTime!));
        break;
      case '文件从大到小':
        normalFiles.sort((a, b) => (b.size ?? 0).compareTo(a.size ?? 0));
        break;
      case '文件从小到大':
        normalFiles.sort((a, b) => (a.size ?? 0).compareTo(b.size ?? 0));
        break;
    }

    return [...folders, ...normalFiles]; 
  }

  // 格式化文件大小
  String formatFileSize(int? sizeInBytes) {
    if (sizeInBytes == null) return '未知大小';
    if (sizeInBytes < 1024) {
      return '$sizeInBytes B';
    } else if (sizeInBytes < 1024 * 1024) {
      return '${(sizeInBytes / 1024).toStringAsFixed(2)} KB';
    } else if (sizeInBytes < 1024 * 1024 * 1024) {
      return '${(sizeInBytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else {
      return '${(sizeInBytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
  }

  // 格式化日期
  String formatDate(DateTime? date) {
    if (date == null) return '未知时间';
    return DateFormat('yyyy/MM/dd HH:mm').format(date);
  }

  // 获取最后一个目录名称
  String _getAppBarTitle(String path) {
    String trimmedPath = path.endsWith('/') ? path.substring(0, path.length - 1) : path;
    List<String> parts = trimmedPath.split('/');
    return parts.isNotEmpty ? parts.last : path;
  }

  void _showFileDetails(webdav.File file) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return SafeArea(
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Material(
            type: MaterialType.transparency,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: SvgPicture.asset('assets/images/ic_handler.svg'),
                    ),
                  ),
                  Flexible(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Theme.of(context).flixColors.gradient.first,
                            Theme.of(context).flixColors.gradient.second,
                            Theme.of(context).flixColors.gradient.third,
                          ],
                          stops: const [0, 0.2043, 1],
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (file.name != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 20, top: 28, right: 20),
                            child: Text(
                              file.name!,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).flixColors.text.primary,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                            if (file.isDir != true)
                            Padding(
                              padding: const EdgeInsets.only(left: 20, right: 20),
                              child: Text(
                                '${formatDate(file.mTime)} · ${formatFileSize(file.size)}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Theme.of(context).flixColors.text.secondary,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ),
                             if (file.isDir == true)
                            Padding(
                              padding: const EdgeInsets.only(left: 20, right: 20),
                              child: Text(
                                formatDate(file.mTime),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Theme.of(context).flixColors.text.secondary,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ),
                         
                          if (!file.isDir!)
                            Padding(
                              padding: const EdgeInsets.only(top:15,left: 20, right: 20, bottom: 20),
                              child: SizedBox(
                                width: double.infinity,
                                child: CupertinoButton(
                                  onPressed: () async {
                                    await _downloadFile(file, context);
                                    Navigator.of(context).pop();
                                  },
                                 
                                  borderRadius: BorderRadius.circular(14),
                               
                                  child:  Text(
                                    '下载',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context).flixColors.text.primary,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

  // 下载文件
  Future<void> _downloadFile(webdav.File file, BuildContext context) async {
    
  
  }

 
  // 显示排序选择对话框
  Future<void> _showSortDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('选择排序方式'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: sortOptions.map((option) {
              return RadioListTile<String>(
                title: Text(option),
                value: option,
                groupValue: currentSortMethod,
                onChanged: (value) {
                  setState(() {
                    currentSortMethod = value!;
                    _saveSortMethod(value); 
                    fileList = _sortFiles(fileList); 
                    Navigator.of(context).pop(); 
                  });
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
  String _getFileIconPath(String fileName) {
  String extension = fileName.split('.').last.toLowerCase();

  if (['jpg', 'jpeg', 'png', 'gif', 'bmp', 'tiff', 'svg', 'webp', 'ico', 'heic', 'heif'].contains(extension)) {
    return 'assets/images/picture_ic.svg'; 
  } else if (['mp3', 'wav', 'flac', 'aac', 'ogg', 'wma', 'm4a', 'aiff', 'alac'].contains(extension)) {
    return 'assets/images/music_ic.svg'; 
  } else if (['mp4', 'avi', 'mkv', 'mov', 'wmv', 'flv', 'webm', 'vob', 'm4v', '3gp', 'mpeg'].contains(extension)) {
    return 'assets/images/video_ic.svg'; 
  } else if (['zip', 'rar', '7z', 'tar', 'gz', 'bz2', 'xz', 'iso'].contains(extension)) {
    return 'assets/images/zip_ic.svg'; 
  } else if (['apk', 'apkx', 'apks', 'apt', 'abb'].contains(extension)) {
    return 'assets/images/apk_ic.svg'; 
  } else {
    return 'assets/images/unknow.svg'; 
  }
}

  
  

 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white, 
        foregroundColor: Colors.black, 
        title: Text(
          currentPath == '/'
              ? '${widget.webDavInfo['name']}' 
              : _getAppBarTitle(currentPath), 
          style: const TextStyle(
            fontSize: 20,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortDialog, 
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(), 
            )
          : fileList.isEmpty
              ? const Center(
                  child: Text(
                    '该文件夹下没有文件',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  itemCount: fileList.length,
                  itemBuilder: (context, index) {
                    final file = fileList[index];
                  

                    String subtitleText = file.isDir == true
                        ? formatDate(file.mTime)
                        : '${formatDate(file.mTime)}  •  ${formatFileSize(file.size)}';

                    return ListTile(
                       
                     leading: file.isDir == true
                    ? SvgPicture.asset(
                        'assets/images/folder_ic.svg',
                        width: 40,
                        height: 40,
                      )
                    : SvgPicture.asset(
                        _getFileIconPath(file.name ?? '未知名称'),
                        width: 40,
                        height: 40,
                      ),

                      title: Text(file.name ?? '未知名称',
              style: TextStyle(
                fontSize: 15,
                color: Theme.of(context).flixColors.text.primary,
              ),),
                      subtitle: Text(subtitleText,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).flixColors.text.secondary,
              ),),
                  //    trailing: PopupMenuButton<int>(
                    //    icon: const Icon(Icons.more_vert),
                      //  onSelected: (value) {
                        //  if (value == 1) {
                    //        // TODO: 实现分享功能
                    //      } else if (value == 2) {
                    //        _downloadFile(file, context);
                   //       } else if (value == 3) {
                   //        _showFileDetails(file);
                    //      }
                    //    },
                    //      if (file.isDir != null && !file.isDir!)
                    //        const PopupMenuItem<int>(
                   //           value: 2,
                   ///             leading: Icon(Icons.download),
                   //             title: Text('下载'),
                   ///           ),
                    //        ),
                     //     PopupMenuItem<int>(
                     //       value: 3,
                     //       child: ListTile(
                     //         leading: const Icon(Icons.info_outline),
                     //         title: Text(file.isDir == true
                    //             ? '文件夹详情'
                    //             : '文件详情'),
                    //       ),
                    //      ),
                     //   ],
                    //  ),
                      onTap: file.isDir == true
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => WebDavFileManagerPage(
                                    webDavInfo: widget.webDavInfo,
                                    currentPath: file.path!,
                                    client: widget.client,
                                  ),
                                ),
                              );
                            }
                          : 
                              () {
                               _showFileDetails(file);
                            },
                    );
                  },
                ),
    );
  }
}