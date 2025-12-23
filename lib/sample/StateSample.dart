import 'package:flutter/material.dart';

class StateSample extends StatefulWidget {
  /*
  클래스 파라미터 정의 부분임
  {} 중괄호 안헤 넣는건 가변 파라미터
  */
  /* 파이널로 하면 나중에 수정못함 */
  /* 부모가 보낸 state는 자식에선 read-only가 편함*/
  /*
  부모 -> 자식은 되는데 반대는 안돼.
  패륜 전송, 불륜전송 안됨
  최대한 state는 부모위젯에 만들자 !
  */
  const StateSample({super.key, required this.nameList, required this.addOne});

  final List nameList;
  final Function(String) addOne;

  @override
  State<StateSample> createState() => _StateSampleState();
}

class _StateSampleState extends State<StateSample> {
  var inputController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        child: Column(
          children: [
            TextField(controller: inputController),
            TextButton(
              onPressed: () {
                widget.addOne(inputController.text);
                Navigator.pop(context);
              },
              child: Text('완료'),
            ),
          ],
        ),
      ),
    );
  }
}
