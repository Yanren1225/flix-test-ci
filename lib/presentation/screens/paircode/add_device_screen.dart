import 'package:flix/domain/paircode/pair_router_handler.dart';
import 'package:flix/presentation/widgets/flix_toast.dart';
import 'package:flix/utils/net/net_utils.dart';
import 'package:flutter/material.dart';

class AddDeviceScreen extends StatefulWidget {

  const AddDeviceScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return AddDeviceScreenState();
  }

}

class AddDeviceScreenState extends State<AddDeviceScreen> {
  final _ipController = TextEditingController();
  final _portController = TextEditingController();
  var isAddButtonEnabled = false;

  @override
  void initState() {
    super.initState();
  }

  void checkInput() {
    final isValid = isValidIp(_ipController.text) && isValidPort(_portController.text);
    if (isValid && !isAddButtonEnabled) {
      setState(() {
        isAddButtonEnabled = true;
      });
    } else if (!isValid && isAddButtonEnabled) {
      setState(() {
        isAddButtonEnabled = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                // 返回操作
                Navigator.pop(context);
              },
            ),
            pinned: true,
            expandedHeight: 100.0,
            flexibleSpace: FlexibleSpaceBar(
              title: Text('手动输入添加', style: TextStyle(fontWeight: FontWeight.bold)),
              centerTitle: true,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'IP',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    controller: _ipController,
                    onChanged: (value) {
                        checkInput();
                      },
                  ),
                  SizedBox(height: 16.0),
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: '网络端口',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    controller: _portController,
                    onChanged: (value) {
                        checkInput();
                      },
                  ),
                  SizedBox(height: 32.0),
                  ElevatedButton(
                    onPressed: isAddButtonEnabled ? () async {
                      final result = await PairRouterHandler.addDevice(PairInfo([_ipController.text],  int.parse(_portController.text)));
                      if (result) {
                        flixToast.info("添加成功");
                      } else {
                        flixToast.info("添加失败");
                      }
                    } : null,
                    child: Text('添加设备'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 16.0),
                      textStyle: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}