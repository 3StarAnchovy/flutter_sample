import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(backgroundColor: Colors.blue),
        body: Container(
          height: 150,
          padding: EdgeInsets.all(10),
          child: Row(
            children: [
              Flexible(child: Image.asset('test.png'), flex: 3),
              Flexible(
                flex: 7,
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('캐논 어쩌고 단렌즈 포함 저쩌고'),
                        Text('캐논 어쩌고 단렌즈 포함 저쩌고'),
                        Text('캐논 어쩌고 단렌즈 포함 저쩌고'),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [Icon(Icons.heart_broken), Text('4')],
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
    );
  }
}

/*
레이아웃 짤 때 스텝

1. 예시디자인 준비
2. 예시화면에 네모 그리기
3. 바깥 네모부터 하나하나 위젯으로
*/
