import 'package:flix/utils/text/text_extension.dart';
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
    int marginLeft = 16;
    double screenWidth = MediaQuery.of(context).size.width-marginLeft*2;
    return Row(
      children: [
        Container(
          width: screenWidth,
          height: 54,
          margin: EdgeInsets.only(left: marginLeft.toDouble(),right: marginLeft.toDouble(),top: 10,bottom: 10),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8),color: Colors.white),
          child: TextField(
            cursorColor: Colors.black,
            decoration: InputDecoration(
                border: InputBorder.none,
                hintText: '搜索',
                hintStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color.fromRGBO(102, 102, 102, 1)).fix(),
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
            onChanged: (text){
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
