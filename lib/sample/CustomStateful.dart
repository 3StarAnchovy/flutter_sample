import 'package:flutter/material.dart';

class CustomStfWg extends StatefulWidget {
  const CustomStfWg({super.key});

  @override
  State<CustomStfWg> createState() => _CustomStfWgState();
}

class _CustomStfWgState extends State<CustomStfWg> {
  //state
  var likeCnt = List.filled(3, 0);
  var name = ['안녕', '해윙', '사요나라'];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 3,
      itemBuilder: (c, i) {
        return ListTile(
          leading: Text(likeCnt[i].toString()),
          title: Text(name[i].toString()),
          trailing: ElevatedButton(
            onPressed: () {
              setState(() {
                likeCnt[i]++;
              });
            },
            child: Text('좋아용'),
          ),
        );
      },
    );
  }
}

/*
        버튼 눌러도 값 안바뀜 -> 재렌더링 안되서
        재렌더링 되게하려면 ? state 쓰면 됨
        state는 변하면 state 사용하는 위젯이 자동 재렌더링됨
        */
//state 만드는 두가지 방법
// 1. state 위젯을 만든다
// 2. stateful 위젯으로 바꾼다
