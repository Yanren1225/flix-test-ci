
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PreviewErrorWidget extends StatelessWidget {
  const PreviewErrorWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(child: SvgPicture.asset('assets/images/ic_preview_file_failed.svg'));
  }
}