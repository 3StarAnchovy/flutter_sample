import 'package:flutter/material.dart';
import 'package:flutter_sample/sample/CustomDialog.dart';
import 'package:flutter_sample/sample/CustomStateful.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var a = 1;
  var name = ['해윙', '안녕', '흐잉'];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(backgroundColor: Colors.blue),
        body: Customdialog(),
        bottomNavigationBar: BottomCustomBar(),
      ),
    );
  }
}

class BottomCustomBar extends StatelessWidget {
  const BottomCustomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [Icon(Icons.phone), Icon(Icons.phone), Icon(Icons.phone)],
      ),
    );
  }
}

/*
성능상 이슈 있을수있음
변하지 않는 UI들은 변수 함수로 축약해도 상관없음
*/
var a = SizedBox(child: Text('해윙해윙'));

class ShopItem extends StatelessWidget {
  const ShopItem({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(child: Text('해윙'));
  }
}

/*
레이아웃 짤 때 스텝

1. 예시디자인 준비
2. 예시화면에 네모 그리기
3. 바깥 네모부터 하나하나 위젯으로
*/
