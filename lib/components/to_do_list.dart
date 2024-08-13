import 'package:cookr2/components/to_do_item.dart';
import 'package:flutter/material.dart';

class TodoList extends StatefulWidget {
  const TodoList({super.key});

  @override
  _TodoListState createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  final List<Map<String, dynamic>> _todos = [
    {'title': 'Buy groceries', 'isCompleted': false},
    {'title': 'Walk the dog', 'isCompleted': false},
    {'title': 'Complete Flutter project', 'isCompleted': false},
  ];

  void _toggleTodoStatus(int index) {
    setState(() {
      _todos[index]['isCompleted'] = !_todos[index]['isCompleted'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(0), // Remove default padding
      itemCount: _todos.length,
      itemBuilder: (context, index) {
        final todo = _todos[index];
        return TodoItem(
          title: todo['title'],
          isCompleted: todo['isCompleted'],
          onToggle: () => _toggleTodoStatus(index),
        );
      },
    );
  }
}
