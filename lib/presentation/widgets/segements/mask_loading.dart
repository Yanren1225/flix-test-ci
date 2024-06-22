import 'package:flix/presentation/basic/corner/flix_decoration.dart';
import 'package:flix/utils/text/text_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:modals/modals.dart';

class MaskLoading extends StatefulWidget {
  final BuildContext superContext;
  final bool showLoading;
  final String? label;


  const MaskLoading({super.key, required this.superContext, this.showLoading = false, this.label});


  @override
  State<StatefulWidget> createState() => MaskLoadingState();

}

class MaskLoadingState extends State<MaskLoading> with RouteAware {
  BuildContext get superContext => widget.superContext;
  bool get showLoading => widget.showLoading;
  String? get label => widget.label;


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    modalsRouteObserver.subscribe(this, ModalRoute.of(superContext) as PageRoute);
  }

  @override
  void didPop() {
    dismissMaskLoading();
    super.didPop();
  }

  @override
  void dispose() {
    modalsRouteObserver.unsubscribe(this);
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: FlixDecoration(color: const Color.fromRGBO(0, 0, 0, 0.45)),
      child: Visibility(
        visible: showLoading,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.transparent,
                    color: Colors.white,
                    strokeWidth: 2.0,
                  )),
              Visibility(
                visible: label != null,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    label ?? '',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.normal).fix(),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

OverlayEntry? maskLoading;

void showMaskLoading(BuildContext context, {bool showLoading = true, String? label}) {
  maskLoading?.remove();
  final overlayState = Overlay.of(context, rootOverlay: true);
  maskLoading = OverlayEntry(builder: (BuildContext ctx) => MaskLoading(superContext: context, label: label));

  overlayState.insert(maskLoading!);
}

void dismissMaskLoading() {
  maskLoading?.remove();
  maskLoading = null;
}
