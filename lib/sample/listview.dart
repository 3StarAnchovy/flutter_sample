import 'package:flutter/material.dart';

class CustomListView extends StatefulWidget {
  const CustomListView({
    super.key,
    required this.total,
    required this.nameList,
    required this.deleteOne,
  });

  final int total;
  final List nameList;
  final Function(int) deleteOne;

  @override
  State<CustomListView> createState() => _CustomListViewState();
}

class _CustomListViewState extends State<CustomListView> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      /*
      * itemCount : 반복횟수
      * itemBuilder (컨텍스트, 인덱스) { 내용, 반환할 위젯 }
      */
      itemCount: widget.total,
      itemBuilder: (c, i) {
        print(i);
        return ListTile(
          leading: Icon(Icons.man),
          title: Text(widget.nameList[i]),
          trailing: IconButton(
            onPressed: () {
              print('hi');
              widget.deleteOne(i);
              return;
            },
            icon: Icon(Icons.delete),
          ),
        );
      },
    );
  }
}
