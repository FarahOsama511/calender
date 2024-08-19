import 'package:flutter/material.dart';
import 'package:todoapplication/checkedbox.dart';
import 'package:todoapplication/data.dart';
import 'package:todoapplication/todoprovider.dart';
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Todoprovider.instance.open();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppstate createState() => _MyAppstate();
}

class _MyAppstate extends State<MyApp> {
  void initState() {
    super.initState();
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    List<data> loadedTodos = await Todoprovider.instance.gettodo();
    setState(() {
      todo = loadedTodos;
    });
  }

  DateTime selectdate = DateTime.now();
  List<data> todo = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const Drawer(),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white, size: 30),
        backgroundColor: Colors.blue,
        title: const Text(
          "Tasker",
          style: TextStyle(
              color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<List<data>>(
        future: Todoprovider.instance.gettodo(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            todo = snapshot.data!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 150,
                  color: Colors.blue,
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      RichText(
                        text: TextSpan(
                          text: "${DateFormat('d').format(DateTime.now())}",
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 40,
                              fontWeight: FontWeight.bold),
                          children: [
                            TextSpan(
                              text:
                                  "${DateFormat('MMMM').format(DateTime.now())}${DateFormat('y').format(DateTime.now())}",
                              style: const TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        "${DateFormat('EEEE').format(DateTime.now())}",
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 500,
                  child: ListView.builder(
                    itemCount: todo.length,
                    itemBuilder: (context, index) {
                      data todos = todo[index];
                      String formatdate = DateFormat('yyyy-MM-dd').format(
                          DateTime.fromMillisecondsSinceEpoch(todos.date));
                      print(
                          "Task: ${todos.task}, Date: ${todos.date}, Formatted Date: $formatdate");
                      return Padding(
                          padding: const EdgeInsets.all(20),
                          child: Checkedbox(
                            title: "${todos.task}",
                            subtitle: formatdate,
                            ischecked: false,
                          ));
                    },
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: Text("No tasks available"));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        onPressed: () {
          _showModel(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  _showModel(BuildContext context) {
    TextEditingController taskController = TextEditingController();
    TextEditingController dateController = TextEditingController();
    dateController.text = DateFormat("yyyy-MM-dd").format(selectdate);

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
              left: 20, bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: taskController,
                decoration: const InputDecoration(hintText: "Task"),
              ),
              TextField(
                readOnly: true,
                controller: dateController,
                decoration: const InputDecoration(hintText: "No due day"),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  IconButton(
                    onPressed: () async {
                      DateTime? picker = await showDatePicker(
                        context: context,
                        initialDate: selectdate,
                        firstDate: DateTime(2010),
                        lastDate: DateTime(2100),
                      );
                      if (picker != null && picker != selectdate) {
                        setState(() {
                          selectdate = picker;
                          dateController.text =
                              DateFormat("yyyy-MM-dd").format(selectdate);
                        });
                      }
                    },
                    icon: const Icon(
                      Icons.calendar_today_outlined,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 150),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      if (taskController.text.isNotEmpty &&
                          dateController.text.isNotEmpty) {
                        await Todoprovider.instance.insert(data(
                          task: taskController.text,
                          date: selectdate.millisecondsSinceEpoch,
                        ));
                        await _loadTodos();
                      }
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Save",
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
