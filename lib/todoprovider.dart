import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todoapplication/data.dart';

final String columndate = "date";
final String columnTask = "task";
final String tableTodo = "todotable";

class Todoprovider {
  static final Todoprovider instance = Todoprovider._internal();

  factory Todoprovider() {
    return instance;
  }
  Todoprovider._internal();
  late Database db;

  Future open() async {
    db = await openDatabase(
      join(await getDatabasesPath(), "todo.db"),
      version: 2,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE $tableTodo ( 
            $columndate INTEGER NOT NULL, 
            $columnTask TEXT NOT NULL
          )
        ''');
      },
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        if (oldVersion < 2) {
          await db
              .execute('ALTER TABLE $tableTodo ADD COLUMN $columndate INTEGER');
        }
      },
    );
  }

  Future<data> insert(data todo) async {
    await db.insert(tableTodo, todo.toMap());
    return todo;
  }

  Future<List<data>> gettodo() async {
    List<Map<String, dynamic>> todoMaps = await db.query(tableTodo);
    if (todoMaps.isEmpty) {
      return [];
    } else {
      return todoMaps.map((element) => data.fromMap(element)).toList();
    }
  }

  Future<int> update(data todo) async {
    return await db.update(
      tableTodo,
      todo.toMap(),
      where: "$columndate = ?",
      whereArgs: [todo.date],
    );
  }
}
