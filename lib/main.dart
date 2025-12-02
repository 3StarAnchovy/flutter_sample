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
        appBar: AppBar(backgroundColor: Colors.black),
        body: Container(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(child: Image.asset('test.png', width: 150, height: 150)),
              Container(
                child: Column(
                  children: [
                    Text( 
                      '캐논 DSLR 100D (단렌즈 충전기 16기가 SD 포함)',
                      textAlign: TextAlign.left,
                    ),
                    Text('성동구 행당동 끌올 10분전', textAlign: TextAlign.left),
                    Text('210,000원'),
                    Container(
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.heart_broken),
                          ),
                          Text("4"),
                        ],
                      ),
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
