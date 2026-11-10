import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'To-Do List',
      theme: ThemeData(useMaterial3: true, primarySwatch: Colors.indigo),
      home: const TodoPage(),
    );
  }
}

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});
  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  List<Map<String, dynamic>> tasks = [];
  TextEditingController taskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  Future<void> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString('tasks');
    if (data!= null) {
      setState(() {
        tasks = List<Map<String, dynamic>>.from(jsonDecode(data));
      });
    }
  }

  Future<void> saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('tasks', jsonEncode(tasks));
  }

  void addOrEditTask({int? index}) {
    if (index!= null) taskController.text = tasks[index]['title'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(index == null? 'Add Task' : 'Edit Task'),
        content: TextField(
          controller: taskController,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Enter task', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () { taskController.clear(); Navigator.pop(context); }, child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (taskController.text.trim().isEmpty) return;
              setState(() {
                if (index == null) {
                  tasks.add({'title': taskController.text.trim(), 'isDone': false});
                } else {
                  tasks[index]['title'] = taskController.text.trim();
                }
              });
              saveTasks();
              taskController.clear();
              Navigator.pop(context);
            },
            child: Text(index == null? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  void deleteTask(int index) {
    setState(() => tasks.removeAt(index));
    saveTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My To-Do List'), centerTitle: true, backgroundColor: Colors.indigo, foregroundColor: Colors.white),
      body: tasks.isEmpty
          ? const Center(child: Text('No tasks yet! Tap + to add'))
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              leading: Checkbox(
                value: tasks[index]['isDone'],
                onChanged: (val) { setState(() => tasks[index]['isDone'] = val); saveTasks(); },
              ),
              title: Text(tasks[index]['title'], style: TextStyle(decoration: tasks[index]['isDone']? TextDecoration.lineThrough : null)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => addOrEditTask(index: index)),
                  IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => deleteTask(index)),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(onPressed: () => addOrEditTask(), backgroundColor: Colors.indigo, child: const Icon(Icons.add, color: Colors.white)),
    );
  }
}