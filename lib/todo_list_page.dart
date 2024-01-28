import 'package:flutter/material.dart';
import 'package:note/db_helper.dart';
import 'package:note/edit_todo_dialog.dart';
import 'package:note/todo.dart';

import 'add_todo_dialog.dart';

class TodoListPage extends StatefulWidget {
  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  List<Todo> _todos = [];
  DBHelper _dbHelper = DBHelper();

  @override
  void initState() {
    super.initState();
    _dbHelper.readAll().then((value) {
      setState(() {
        _todos = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo List'),
      ),
      body: ListView.builder(
        itemCount: _todos.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_todos[index].name),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () async {
                await _removeTodo(index);
              },
            ),
            onTap: () async {
              String? newName = await showDialog(
                context: context,
                builder: (context) => EditTodoDialog(_todos[index]),
              );

              if (newName != null && newName.isNotEmpty) {
                await _editTodo(index, newName);
              }
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          String? newTodo = await showDialog(
            context: context,
            builder: (context) => AddTodoDialog(),
          );

          if (newTodo != null && newTodo.isNotEmpty) {
            await _addTodo(newTodo);
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Future<void> _addTodo(String name) async {
    var todo = await _dbHelper.insert(name);
    setState(() {
      _todos.add(todo);
    });
  }

  Future<void> _editTodo(int index, String newName) async {
    var todo = _todos[index];
    todo.name = newName;
    await _dbHelper.update(todo);
    setState(() {
      _todos[index] = todo;
    });
  }

  Future<void> _removeTodo(int index) async {
    var id = _todos[index].id;
    await _dbHelper.delete(id);
    setState(() {
      _todos.removeAt(index);
    });
  }
}
