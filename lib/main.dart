import 'package:flutter/material.dart';
import 'package:flutter_sample/sample/CustomDialog.dart';
import 'package:flutter_sample/sample/CustomStateful.dart';
import 'package:flutter_sample/sample/StateSample.dart';
import 'package:flutter_sample/sample/listview.dart';

void main() {
  runApp(MaterialApp(home: MyApp()));
}

/*
MatefialApp을 밖으로 빼니까 동작하노..? 왜 ..?

컨텍스트 : 부모 위젯의 정보를 담고있는 변수
1. 스캐폴드의 부모위젯을 마테리얼 앱으로 만들어줌
-> showDialog(context) 입력이 강제되는데
-> 마테리얼이 부모로 들어있어야 동작되게끔 설계되어있음
*/

class MyApp extends StatefulWidget {
  MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  //인원 리스트
  List<String> nameList = [];

  //인원 총합
  var total = 0;

  //추가
  void addOne(String newVal) {
    setState(() {
      if (newVal.isEmpty) {
        return;
      }

      nameList.add(newVal);
      total = nameList.length;
    });
  }

  //삭제
  void deleteOne(int idx) {
    setState(() {
      nameList.removeAt(idx);
      total = nameList.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(total.toString()),
        backgroundColor: Colors.blue,
      ),
      body: CustomListView(
        total: total,
        nameList: nameList,
        deleteOne: deleteOne,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return StateSample(nameList: nameList, addOne: addOne);
            },
          );
        },
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

/*
state 전송
1. 보내고
2. 등록하고
3. 쓰면 됨
*/
