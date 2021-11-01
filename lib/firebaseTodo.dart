import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseTodo {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static CollectionReference todoColection = _firestore.collection('todos');
  static String todoStringKey = "todo";
  static String todoCompletionKey = "isDone";

  static Future addTodo(String todoStringval, bool isCompleted) async {
    todoColection.add({
      todoStringKey: todoStringval,
      todoCompletionKey: isCompleted
    }).then((value) {
      print(value);
    });
  }

  static Future<QuerySnapshot> readTodo() async {
    QuerySnapshot todoList = await todoColection.get();
    return todoList;
  }

  static Future updateTodo(
      String todoId, String todoUpdateString, bool isCompleted) async {
    try {
      await todoColection.doc(todoId).update({
        todoStringKey: todoUpdateString,
        todoCompletionKey: isCompleted,
      });
    } catch (e) {
      print(e);
    }
  }

  static Future deleteTodo(String todoId) async {
    try {
      await todoColection.doc(todoId).delete();
    } catch (e) {
      print(e);
    }
  }
}
