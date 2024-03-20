import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class TodoListApp extends StatefulWidget {
  const TodoListApp({super.key});

  @override
  _TodoListAppState createState() => _TodoListAppState();
}

class _TodoListAppState extends State<TodoListApp> {
  final DatabaseReference _todoListRef =
      FirebaseDatabase.instance.ref().child('todoList');
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do List'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Enter task title',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                hintText: 'Enter task description',
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              String title = _titleController.text.trim();
              String description = _descriptionController.text.trim();
              if (title.isNotEmpty && description.isNotEmpty) {
                _addTodoItem(title, description);
                _titleController.clear();
                _descriptionController.clear();
              }
            },
            child: const Text('Add Task'),
          ),
          Expanded(
            child: StreamBuilder<DatabaseEvent>(
              stream: _todoListRef.onValue,
              builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  Map<dynamic, dynamic>? values =
                      snapshot.data?.snapshot.value as Map<dynamic, dynamic>?;
                  if (values != null) {
                    return ListView.builder(
                      itemCount: values.length,
                      itemBuilder: (context, index) {
                        dynamic key = values.keys.elementAt(index);
                        dynamic value = values[key];
                        return Dismissible(
                          key: Key(key),
                          background: Container(
                            color: Colors.red,
                            child: const Icon(Icons.delete),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 16.0),
                          ),
                          onDismissed: (direction) {
                            _deleteTodoItem(key);
                          },
                          child: ListTile(
                            title: Text(value['title']),
                            subtitle: Text(value['description']),
                            trailing: Checkbox(
                              value: value['completed'],
                              onChanged: (bool? newValue) {
                                _updateTodoItem(key, {
                                  'completed': newValue,
                                });
                              },
                            ),
                          ),
                        );
                      },
                    );
                  }
                }
                return const Center(child: Text('To-Do-List'));
              },
            ),
          )
        ],
      ),
    );
  }

  void _addTodoItem(String title, String description) {
    _todoListRef.push().set({
      'title': title,
      'description': description,
      'completed': false,
    });
  }

  void _updateTodoItem(String key, Map<String, dynamic> data) {
    _todoListRef.child(key).update(data);
  }

  void _deleteTodoItem(String key) {
    _todoListRef.child(key).remove();
  }
}
