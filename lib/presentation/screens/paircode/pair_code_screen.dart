import 'dart:async';
import 'dart:io';

import 'package:flix/domain/paircode/pair_code_provider.dart';
import 'package:flix/presentation/basic/constrainted_sliver_width.dart';
import 'package:flix/presentation/screens/paircode/add_device_screen.dart';
import 'package:flix/presentation/style/flix_text_style.dart';
import 'package:flix/theme/theme_extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../network/multicast_client_provider.dart';
import '../../../utils/platform_utils.dart';

class PairCodeScreen extends StatefulWidget {
  const PairCodeScreen({super.key});

  @override
  State<StatefulWidget> createState() => PairCodeState();
}

class PairCodeState extends State<PairCodeScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => PairCodeProvider(),
      child: Material(
        color: Theme.of(context).flixColors.background.secondary,
        child: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar.medium(
              backgroundColor:
                  Theme.of(context).flixColors.background.secondary,
              surfaceTintColor:
                  Theme.of(context).flixColors.background.secondary,
              centerTitle: false,
              leading: IconButton(
                  icon: SvgPicture.asset("assets/images/ic_back.svg",
                      colorFilter: ColorFilter.mode(
                          Theme.of(context).flixColors.text.primary,
                          BlendMode.srcIn)),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
              title: const Text('添加设备'),
              toolbarTextStyle: context.header(),
              // titleTextStyle: context.h1(),
              actions: <Widget>[
                IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
              ],
            ),
            // Just some content big enough to have something to scroll.
            SliverToBoxAdapter(
              child: PairCodeContentComponent(context: context),
            )
          ],
        ),
      ),
    );
  }
}

class PairCodeContentComponent extends StatefulWidget {
  const PairCodeContentComponent({super.key, required this.context});

  final BuildContext context;

  @override
  State<StatefulWidget> createState() => PairCodeContentComponentState();
}

class PairCodeContentComponentState extends State with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    refreshPairCode();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {

    if (state == AppLifecycleState.resumed) {
      refreshPairCode();
    }
  }

  void refreshPairCode() {
    final pairCodeProvider =
    Provider.of<PairCodeProvider>(context, listen: false);
    pairCodeProvider.refreshPairCode();
  }

  IconData getPlatformIcon() {
    if (isMobile()) {
      return Icons.phone_android_outlined;
    } else if (isDesktop()) {
      return Icons.desktop_windows_outlined;
    } else {
      return Icons.device_unknown;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pairCodeProvider =
        Provider.of<PairCodeProvider>(context, listen: true);
    final deviceProvider = MultiCastClientProvider.of(context, listen: true);
    if (pairCodeProvider.pairCodeUri == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return ConstrainedSliverWidth(
        maxWidth: 400,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    getPlatformIcon(),
                    size: 40,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 10),
                  StreamBuilder<String>(
                      initialData: deviceProvider.deviceName,
                      stream: deviceProvider.deviceNameStream.stream,
                      builder: (context, snapshot) {
                        return Text(
                          snapshot.requireData,
                          style: TextStyle(
                              fontSize: 24,
                            color: Theme.of(context).flixColors.text.primary,
                          ),
                        );
                      }),
                  ]),
              const SizedBox(height: 20),
              QrImageView(
                  eyeStyle: QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Theme.of(this.context).flixColors.text.primary,
                  ),
                  dataModuleStyle: QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: Theme.of(this.context).flixColors.text.primary),
                  data: pairCodeProvider.pairCodeUri ?? "error://no_pair_code",
                  padding: const EdgeInsets.all(25.0)),
              const SizedBox(height: 10),
              const Text(
                'Flix 扫一扫，添加本设备',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('本机 IP'),
                      const SizedBox(height: 10),
                      Text(
                        pairCodeProvider.netInterfaces
                            .map((e) => e.address)
                            .fold(
                                "",
                                (previousValue, element) =>
                                    "$previousValue\n$element").trim(),
                        style: TextStyle(
                            color: Theme.of(this.context)
                                .flixColors
                                .text
                                .secondary),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('本机网络端口'),
                      const SizedBox(height: 10),
                      Text(
                        pairCodeProvider.port.toString(),
                        style: TextStyle(
                            color: Theme.of(this.context)
                                .flixColors
                                .text
                                .secondary),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              CupertinoButton(
                onPressed: () {
                  Navigator.of(context).push(CupertinoPageRoute(
                      builder: (context) => const AddDeviceScreen()));
                },
                child: const Text('手动输入添加'),
              ),
            ],
          ),
        ),
      );
    }
  }
}
