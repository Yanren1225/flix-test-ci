import 'package:flutter/material.dart';

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
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
          child: TextField(
            cursorColor: Colors.black,
            decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: '搜索',
                hintStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color.fromRGBO(102, 102, 102, 1)),
                contentPadding:
                    EdgeInsets.only(left: 48, top: 14, right: 12, bottom: 14),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  size: 20,
                ),
                prefixIconColor: Colors.black),
            maxLines: 1,
            autocorrect: false,
            keyboardType: TextInputType.text,
            onSubmitted: onSearch,
          ),
        )
      ],
    );
  }
}

typedef OnSearch = void Function(String value);
