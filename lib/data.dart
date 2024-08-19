import 'package:todoapplication/todoprovider.dart';

class data {
  late int date;
  late String task;

  data({required this.task, required this.date});

  data.fromMap(Map<String, dynamic> map) {
    date = map[columndate];
    task = map[columnTask];
  }

  Map<String, dynamic> toMap() {
    return {
      columndate: date,
      columnTask: task,
    };
  }
}
