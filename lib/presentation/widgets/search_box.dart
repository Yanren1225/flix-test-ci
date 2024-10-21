import 'package:flix/theme/theme_extensions.dart';
import 'package:flix/utils/text/text_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../l10n/l10n.dart';

class SearchBox extends StatefulWidget {
  OnSearch onSearch;

  SearchBox({super.key, required this.onSearch});

  @override
  State<StatefulWidget> createState() => SearchBoxState();
}

class SearchBoxState extends State<SearchBox> {
  OnSearch get onSearch => widget.onSearch;

  @override
  Widget build(BuildContext context) {
    int marginLeft = 16;
    double screenWidth = MediaQuery.of(context).size.width - marginLeft * 2;
    return Row(
      children: [
        Container(
          width: screenWidth,
          height: 46,
          margin: EdgeInsets.only(
              left: marginLeft.toDouble(),
              right: marginLeft.toDouble(),
              top: 10,
              bottom: 10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Theme.of(context).flixColors.background.primary),
          child: TextField(
            cursorColor: Theme.of(context).flixColors.text.primary,
            decoration: InputDecoration(
                border: InputBorder.none,
                hintText: S.of(context).search,
                hintStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context)
                            .flixColors
                            .text
                            .secondary
                            .withAlpha(77))
                    .fix(),
                contentPadding: const EdgeInsets.only(
                    left: 0, top: 12, right: 12, bottom: 12),
                prefixIcon: Container(
                  padding: const EdgeInsets.only(
                    left: 16,
                    top: 16,
                    bottom: 16,
                    right: 7,
                  ),
                  child: SvgPicture.asset('assets/images/ic_search.svg',
                      width: 14,
                      height: 14,
                      colorFilter: ColorFilter.mode(
                          Theme.of(context)
                              .flixColors
                              .text
                              .secondary
                              .withAlpha(77),
                          BlendMode.srcIn)),
                )),
            maxLines: 1,
            autocorrect: false,
            keyboardType: TextInputType.text,
            onChanged: (text) {
              onSearch(text);
            },
            onSubmitted: onSearch,
            style: const TextStyle().fix(),
          ),
        )
      ],
    );
  }
}

typedef OnSearch = void Function(String value);
