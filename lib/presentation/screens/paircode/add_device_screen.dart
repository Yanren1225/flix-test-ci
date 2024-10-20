import 'package:flix/design_widget/design_blue_round_button.dart';
import 'package:flix/design_widget/design_text_field.dart';
import 'package:flix/domain/paircode/pair_router_handler.dart';
import 'package:flix/presentation/screens/paircode/pair_code_screen.dart';
import 'package:flix/presentation/style/flix_text_style.dart';
import 'package:flix/presentation/widgets/flix_toast.dart';
import 'package:flix/presentation/widgets/segements/navigation_scaffold.dart';
import 'package:flix/presentation/widgets/toolbar.dart';
import 'package:flix/theme/theme_extensions.dart';
import 'package:flix/utils/net/net_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:simple_loading_dialog/simple_loading_dialog.dart';

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

  bool checkInput() {
    final isValid =
        isValidIp(_ipController.text) && isValidPort(_portController.text);
    return isValid;
  }

  @override
  Widget build(BuildContext context) {
    //TODO: 统一header
    return NavigationScaffold(
      title: "手动输入添加",
      showBackButton: Navigator.canPop(context),
      builder: (EdgeInsets padding) {
        return Container(
          width: double.infinity,
          child: Column(
            children: [
              const SizedBox(height: 20),
              buildPadding(context),
              const SizedBox(height: 32.0),
              Expanded(
                  child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 130),
                  height: 54,
                  width: 160,
                  child: buildDesignBlueRoundButton(context),
                ),
              )),
            ],
          ),
        );
      },
    );
  }

  Padding buildPadding(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("IP",
              style:
                  TextStyle(fontSize: 14, color: Theme.of(context).hintColor)),
          const SizedBox(height: 4),
          DesignTextField(
            controller: _ipController,
            onChanged: (value) {
              checkInput();
            },
          ),
          const SizedBox(height: 20.0),
          Text("网络端口",
              style:
                  TextStyle(fontSize: 14, color: Theme.of(context).hintColor)),
          const SizedBox(height: 4),
          DesignTextField(
            keyboardType: TextInputType.number,
            controller: _portController,
            onChanged: (value) {
              checkInput();
            },
          ),
        ],
      ),
    );
  }

  Widget buildDesignBlueRoundButton(BuildContext context) {
    return DesignBlueRoundButton(
        text: '添加设备',
        onPressed: () async {
          if (!checkInput()) {
            FlixToast.instance.info('IP或者端口不正确');
            return;
          }
          Future<void> addDevice() async {
            final result = await PairRouterHandler.addDevice(PairInfo(
                [_ipController.text], int.parse(_portController.text)));
            if (result) {
              flixToast.info("添加成功");
            } else {
              flixToast.info("添加失败");
            }
          }

          await showSimpleLoadingDialog<void>(
            context: context,
            future: addDevice,
          );
        });
  }
}
