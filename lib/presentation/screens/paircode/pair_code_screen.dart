import 'dart:async';
import 'dart:io';

import 'package:flix/domain/paircode/pair_code_provider.dart';
import 'package:flix/presentation/basic/constrainted_sliver_width.dart';
import 'package:flix/presentation/screens/paircode/add_device_screen.dart';
import 'package:flix/presentation/style/colors/flix_color.dart';
import 'package:flix/presentation/style/flix_text_style.dart';
import 'package:flix/theme/theme_extensions.dart';
import 'package:flix/utils/device/device_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../l10n/l10n.dart';
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
        child: Stack(
          children: [
            CustomScrollView(
              slivers: <Widget>[
                SliverAppBar.medium(
                  backgroundColor:
                      Theme.of(context).flixColors.background.secondary,
                  surfaceTintColor:
                      Theme.of(context).flixColors.background.secondary,
                  centerTitle: false,
                  leading: Navigator.canPop(context)
                      ? IconButton(
                          icon: SvgPicture.asset("assets/images/ic_back.svg",
                              colorFilter: ColorFilter.mode(
                                  Theme.of(context).flixColors.text.primary,
                                  BlendMode.srcIn)),
                          onPressed: () {
                            Navigator.pop(context);
                          })
                      : null,
                  title: Text(S.of(context).paircode_add_device),
                  toolbarTextStyle: context.header(),
              
                ),
                SliverToBoxAdapter(
                  child: PairCodeContentComponent(context: context),
                )
              ],
            ),
        
            Positioned(
              bottom: 30, 
              left: 16, 
              right: 16, 
              child: Visibility(
                visible: isMobile(),
                child: CupertinoButton(
                 
                  onPressed: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (context) => const AddDeviceScreen(),
                      ),
                    );
                  },
                  child: Text(
                    S.of(context).paircode_add_manually,
                    style: const TextStyle(
                      color: Color.fromRGBO(0, 122, 255, 1), 
                      fontSize: 16,
                    
                    ),
                  ),
                ),
              ),
            ),
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

class PairCodeContentComponentState extends State<PairCodeContentComponent> with WidgetsBindingObserver {
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
    final pairCodeProvider = Provider.of<PairCodeProvider>(context, listen: false);
    pairCodeProvider.refreshPairCode();
  }

  String getPlatformIcon() {
    if (isMobile()) {
      return 'phone.webp';
    } else if (isDesktop()) {
      return 'pc.webp';
    } else {
      return 'pc.webp';
    }
  }

  @override
  Widget build(BuildContext context) {
    final pairCodeProvider = Provider.of<PairCodeProvider>(context, listen: true);
    final deviceProvider = MultiCastClientProvider.of(context, listen: true);
    if (pairCodeProvider.pairCodeUri == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(15.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  offset: const Offset(0, 4),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image(
                          image: AssetImage('assets/images/${getPlatformIcon()}'),
                          width: 36,
                          height: 36,
                          fit: BoxFit.fill,
                        ),
                        const SizedBox(width: 10),
                        StreamBuilder<String>(
                          initialData: deviceProvider.deviceName,
                          stream: deviceProvider.deviceNameStream.stream,
                          builder: (context, snapshot) {
                            return Text(
                              snapshot.requireData,
                              style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context).flixColors.text.primary,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  //const SizedBox(height: 20),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 180),
                    child: QrImageView(
                      eyeStyle: QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: Theme.of(context).flixColors.text.primary,
                      ),
                      dataModuleStyle: QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: Theme.of(context).flixColors.text.primary,
                      ),
                      data: pairCodeProvider.pairCodeUri ?? "error://no_pair_code",
                      padding: const EdgeInsets.only(top: 30, left: 25, right: 25),
                    ),
                  ),
                  Text(
                    S.of(context).paircode_scan_to_add,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              S.of(context).paircode_local_IP,
                              style: TextStyle(
                                color: Theme.of(context).flixColors.text.secondary,
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              pairCodeProvider.netInterfaces
                                  .map((e) => e.address)
                                  .fold("", (previousValue, element) => "$previousValue\n$element")
                                  .trim(),
                              style: const TextStyle(
                                color: FlixColor.blue,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              S.of(context).paircode_local_port,
                              style: TextStyle(
                                color: Theme.of(context).flixColors.text.secondary,
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              pairCodeProvider.port.toString(),
                              style: const TextStyle(
                                color: FlixColor.blue,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }
}