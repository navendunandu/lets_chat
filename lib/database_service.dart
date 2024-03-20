import 'package:firebase_database/firebase_database.dart';

class DatabaseService {
  final DatabaseReference _todoListRef =
      FirebaseDatabase.instance.reference().child('todoList');

  // Add a new to-do item
  Future<void> addTodoItem(String title, String description) async {
    await _todoListRef.push().set({
      'title': title,
      'description': description,
      'completed': false,
    });
  }

  // Update an existing to-do item
  Future<void> updateTodoItem(String key, Map<String, dynamic> data) async {
    await _todoListRef.child(key).update(data);
  }

  // Delete a to-do item
  Future<void> deleteTodoItem(String key) async {
    await _todoListRef.child(key).remove();
  }

  // Get a stream of all to-do items
  Stream<DatabaseEvent> get todoItemStream {
  return _todoListRef.onValue;
}
}