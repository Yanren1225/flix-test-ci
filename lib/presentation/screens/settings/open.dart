import 'package:flix/presentation/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flix/presentation/widgets/segements/navigation_scaffold.dart';
import 'package:provider/provider.dart';

class OpensourceScreen extends StatefulWidget {
  final bool showBack;

  const OpensourceScreen({super.key, this.showBack = true});

  @override
  State<StatefulWidget> createState() => OpensourceScreenState();
}

class OpensourceScreenState extends State<OpensourceScreen> {
  late Future<List<Map<String, String>>> _licenses;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      _loadLicenses();
    });
  }

  void _loadLicenses() {
    _licenses = _parseLicenses();
    _licenses.then((_) {
      setState(() {
        _isLoading = false;
      });
    }).catchError((error) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  Future<List<Map<String, String>>> _parseLicenses() async {
 
    final text = await rootBundle.loadString('assets/images/NOTICES.txt');
   
    final sections = text.split('--------------------------------------------------------------------------------');

    return sections.map((section) {
      final lines = section.trim().split('\n');
      final name = lines.isNotEmpty ? lines.first : 'Unknown License';
      final content = lines.length > 1 ? lines.sublist(1).join('\n') : '';
      return {'name': name, 'content': content};
    }).toList();
  }
   void clearThirdWidget() {
    Provider.of<BackProvider>(context, listen: false).backMethod();
  }
  @override
  Widget build(BuildContext context) {
    return NavigationScaffold(
      showBackButton: widget.showBack,
      title: '开源许可声明',
       onClearThirdWidget: clearThirdWidget,
      builder: (EdgeInsets padding) {
        return Stack(
          children: [
           
            if (!_isLoading)
              FutureBuilder<List<Map<String, String>>>(
                future: _licenses,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(); 
                  } else if (snapshot.hasError) {
                    return Center(child: Text('加载失败: ${snapshot.error}'));
                  } else {
                    final licenses = snapshot.data!;
                    return SingleChildScrollView(
                      child: Container(
                        margin: const EdgeInsets.only(top: 10, right: 16, left: 16, bottom: 0),
                        child: _buildOpenSourceLicenses(licenses),
                      ),
                    );
                  }
                },
              ),

          
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
          ],
        );
      },
    );
  }

  Widget _buildOpenSourceLicenses(List<Map<String, String>> licenses) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '以下内容为本应用所使用的开源组件及其许可声明：',
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 10),
            ..._buildLicenseSections(licenses),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildLicenseSections(List<Map<String, String>> licenses) {
    return licenses.map((license) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              license["name"]!,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              license["content"]!,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      );
    }).toList();
  }
}