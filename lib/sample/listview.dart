import 'package:flutter/material.dart';

class CustomListView extends StatelessWidget {
  const CustomListView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      /*
      * itemCount : 반복횟수
      * itemBuilder (컨텍스트, 인덱스) { 내용, 반환할 위젯 }
      */
      itemCount: 3,
      itemBuilder: (c, i) {
        print(i);
        return Text(i.toString());
      },
    );
  }
}
