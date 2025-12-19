import 'package:flutter/material.dart';

class Customdialog extends StatefulWidget {
  const Customdialog({super.key});

  @override
  State<Customdialog> createState() => _CustomdialogState();
}

class _CustomdialogState extends State<Customdialog> {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('data'),
              content: TextField(),
              actions: [
                OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'),
                ),
                OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
