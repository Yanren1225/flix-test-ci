import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart'; 
import 'dart:io';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:flix/domain/database/database.dart';
import 'package:flix/domain/version/version_checker.dart';
import 'package:flix/presentation/screens/base_screen.dart';
import 'package:flix/presentation/screens/intro/intro_agreement.dart';
import 'package:flix/presentation/screens/intro/intro_privacy.dart';
import 'package:flix/presentation/style/colors/flix_color.dart';
import 'package:flix/presentation/widgets/helps/qa.dart';
import 'package:flix/presentation/widgets/segements/cupertino_navigation_scaffold.dart';
import 'package:flix/presentation/widgets/settings/clickable_item.dart';
import 'package:flix/theme/theme_extensions.dart';
import 'package:flix/utils/text/text_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flix/presentation/widgets/flix_bottom_sheet.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../l10n/l10n.dart';
import '../../widgets/helps/flix_share_bottom_sheet.dart';

class HelpScreen extends StatefulWidget {
  final VoidCallback goVersionScreen;
  final VoidCallback goDonateCallback;

  HelpScreen(
      {super.key,
      required this.goVersionScreen,
      required this.goDonateCallback, required Null Function() goQACallback});

  @override
  State<StatefulWidget> createState() => HelpScreenState();
}

class HelpScreenState extends BaseScreenState<HelpScreen>
    with SingleTickerProviderStateMixin {
  ValueNotifier<String> version = ValueNotifier('');
  TextEditingController _searchController = TextEditingController();
  String searchQuery = '';
  int _selectedIndex = 0;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((packageInfo) {
      version.value = packageInfo.version;
    });

    _tabController = TabController(length: 6, vsync: this);

    _searchController.addListener(() {
      setState(() {
        searchQuery = _searchController.text;
      });
    });

    _tabController.addListener(() {
      setState(() {
        _selectedIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentYear = DateTime.now().year;

    return CupertinoNavigationScaffold(
      title: '最近文件',
      isSliverChild: true,
      padding: 10,
      enableRefresh: false,
      child: SliverList.builder(
        itemCount: 1,
        itemBuilder: (context, index) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Theme.of(context).flixColors.background.primary, 
                  hoverColor: Colors.transparent, 
                  focusColor: Theme.of(context).flixColors.background.primary,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTabItem('全部', 0),
                  _buildTabItem('图片', 1),
                  _buildTabItem('视频', 2),
                  _buildTabItem('音频', 3),
                  _buildTabItem('安装包', 4),
                  _buildTabItem('压缩包', 5),
                ],
              ),
            ),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchFilesWithTimeFromDatabase(), 
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black), // 设置颜色为黑色
                  ),);
                }

                if (snapshot.hasError) {
                  return const Center(child: Text('加载失败'));
                }

                final files = snapshot.data ?? [];
                
                var filteredFiles = files.where((file) {
                  return file['name']
                      .toLowerCase()
                      .contains(searchQuery.toLowerCase());
                }).toList();

               
                filteredFiles = _filterFilesByTab(filteredFiles, _selectedIndex);

            
                filteredFiles.sort((a, b) => b['time'].compareTo(a['time']));

                if (filteredFiles.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      '暂无最近文件',
                      style: TextStyle(
                        color: Theme.of(context).flixColors.text.secondary,
                        fontSize: 14,
                      ),
                    ),
                  );
                }

         
                Map<String, List<Map<String, dynamic>>> groupedFiles = {};
                for (var file in filteredFiles) {
                  final dateKey = DateFormat('yyyy-MM-dd')
                      .format(DateTime.fromMillisecondsSinceEpoch(file['time']));
                  if (!groupedFiles.containsKey(dateKey)) {
                    groupedFiles[dateKey] = [];
                  }
                  groupedFiles[dateKey]!.add(file);
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: groupedFiles.length,
                  itemBuilder: (context, index) {
                    String date = groupedFiles.keys.elementAt(index);
                    List<Map<String, dynamic>> filesForDate =
                        groupedFiles[date]!;

                    final dateParts = date.split('-');
                    final year = int.parse(dateParts[0]);
                    final monthDay = '${dateParts[1]}.${dateParts[2]}';

                    String formattedDate;
                    if (year == currentYear) {
                      formattedDate = monthDay;
                    } else {
                      formattedDate = '$year.$monthDay';
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0,vertical: 8),
                          child: Row(
                            children: [
                              Text(
                                formattedDate, 
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Theme.of(context)
                                      .flixColors
                                      .text
                                      .secondary,
                                ),
                              ),
                              Text(
                                ' | ${filesForDate.length} 项', 
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Theme.of(context)
                                      .flixColors
                                      .text
                                      .secondary,
                                ),
                              ),
                            ],
                          ),
                     
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filesForDate.length,
                          itemBuilder: (context, index) {
                            final file = filesForDate[index];
                            final time = DateTime.fromMillisecondsSinceEpoch(
                                file['time']);
                            final formattedTime = DateFormat('HH:mm')
                                .format(time); 

                          
                            BorderRadius borderRadius;
                            if (filesForDate.length == 1) {
                              borderRadius = BorderRadius.circular(15);
                            } else if (index == 0) {
                              borderRadius = const BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15),
                              );
                            } else if (index == filesForDate.length - 1) {
                            
                              borderRadius = const BorderRadius.only(
                                bottomLeft: Radius.circular(15),
                                bottomRight: Radius.circular(15),
                              );
                            } else {
                             
                              borderRadius = BorderRadius.zero;
                            }

                           
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).flixColors.background.primary,
                                  borderRadius: borderRadius,
                                 
                                ),
                                child: ListTile(
                                  leading: SvgPicture.asset(
                                    'assets/images/unknow.svg',
                                    height: 40,
                                    width: 40,
                                  ),
                                  title: Text(
                                    file['name'],
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Theme.of(context)
                                            .flixColors
                                            .text
                                            .primary),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(file['size'] != null
                                          ? _formatFileSize(file['size'])
                                          : '',style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(context)
                                            .flixColors
                                            .text
                                            .secondary)),
                                   //   Text('$formattedTime'),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(String title, int index) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isSelected
                  ? Theme.of(context).flixColors.text.primary
                  : Theme.of(context).flixColors.text.secondary,
            ),
          ),
          if (isSelected)
            Container(
              margin: const EdgeInsets.only(top: 4),
              height: 2,
              width: 20,
              color: const Color.fromRGBO(0, 122, 255, 1),
            ),
        ],
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchFilesWithTimeFromDatabase() async {
    final query = await appDatabase.customSelect('''
      SELECT file_contents.id, file_contents.name, file_contents.size, bubble_entities.time 
      FROM file_contents 
      JOIN bubble_entities 
      ON file_contents.id = bubble_entities.id
    ''').get();
    return query.map((row) => {
          'id': row.data['id'],
          'name': row.data['name'],
          'size': row.data['size'],
          'time': row.data['time']
        }).toList();
  }

  List<Map<String, dynamic>> _filterFilesByTab(
      List<Map<String, dynamic>> files, int tabIndex) {
    switch (tabIndex) {
      case 1: 
        return files.where((file) => _isImage(file['name'])).toList();
      case 2: 
        return files.where((file) => _isVideo(file['name'])).toList();
      case 3:
        return files.where((file) => _isAudio(file['name'])).toList();
      case 4: 
        return files.where((file) => _isApk(file['name'])).toList();
      case 5: 
        return files.where((file) => _isCompressed(file['name'])).toList();
      default:
        return files; 
    }
  }

  bool _isImage(String fileName) {
    return fileName.toLowerCase().endsWith('.jpg') ||
        fileName.toLowerCase().endsWith('.jpeg') ||
        fileName.toLowerCase().endsWith('.png') ||
        fileName.toLowerCase().endsWith('.gif') ||
        fileName.toLowerCase().endsWith('.bmp') ||
        fileName.toLowerCase().endsWith('.heic') ||
        fileName.toLowerCase().endsWith('.webp');
  }

  bool _isVideo(String fileName) {
    return fileName.toLowerCase().endsWith('.mp4') ||
        fileName.toLowerCase().endsWith('.avi') ||
        fileName.toLowerCase().endsWith('.mov') ||
        fileName.toLowerCase().endsWith('.mkv') ||
        fileName.toLowerCase().endsWith('.flv') ||
        fileName.toLowerCase().endsWith('.wmv');
  }

  bool _isAudio(String fileName) {
    return fileName.toLowerCase().endsWith('.mp3') ||
        fileName.toLowerCase().endsWith('.wav') ||
        fileName.toLowerCase().endsWith('.aac') ||
        fileName.toLowerCase().endsWith('.ogg') ||
        fileName.toLowerCase().endsWith('.flac');
  }

  bool _isApk(String fileName) {
    return fileName.toLowerCase().endsWith('.apk');
  }

  bool _isCompressed(String fileName) {
    return fileName.toLowerCase().endsWith('.zip') ||
        fileName.toLowerCase().endsWith('.rar') ||
        fileName.toLowerCase().endsWith('.7z') ||
        fileName.toLowerCase().endsWith('.tar') ||
        fileName.toLowerCase().endsWith('.gz');
  }

  String _formatFileSize(int size) {
    if (size >= 1024 * 1024 * 1024) {
      return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    } else if (size >= 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else if (size >= 1024) {
      return '${(size / 1024).toStringAsFixed(2)} KB';
    } else {
      return '$size B';
    }
  }
}