import 'package:flutter/material.dart';

class Checkedbox extends StatefulWidget {
  late String title;
  String? subtitle;
  bool ischecked = false;
  Checkedbox({required this.title, this.subtitle, required this.ischecked});
  @override
  _Checkedboxstate createState() => _Checkedboxstate();
}

class _Checkedboxstate extends State<Checkedbox> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListTile(
        leading: Transform.scale(
          scale: 1.5,
          child: Checkbox(
              activeColor: Colors.blue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              value: widget.ischecked,
              onChanged: (value) {
                setState(() {
                  widget.ischecked = value!;
                });
              }),
        ),
        title: Text(
          widget.title,
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
      ),
    );
  }
}
