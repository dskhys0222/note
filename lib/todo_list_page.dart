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
      body: ReorderableListView(
        onReorder: (oldIndex, newIndex) async {
          await _reorderTodos(oldIndex, newIndex);
        },
        children: _todos
            .map((todo) => ListTile(
                  key: Key(todo.id.toString()),
                  leading: Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Icon(Icons.circle, size: 10.0),
                  ),
                  title: Text(todo.name),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () async {
                      await _removeTodo(todo.id);
                    },
                  ),
                  onTap: () async {
                    String? newName = await showDialog(
                      context: context,
                      builder: (context) => EditTodoDialog(todo),
                    );

                    if (newName != null && newName.isNotEmpty) {
                      await _editTodo(todo.id, newName);
                    }
                  },
                ))
            .toList(),
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

  Future<void> _editTodo(int id, String newName) async {
    var index = _todos.indexWhere((element) => element.id == id);
    var todo = _todos[index];
    todo.name = newName;
    await _dbHelper.updateName(todo);
    setState(() {
      _todos[index] = todo;
    });
  }

  Future<void> _reorderTodos(int oldIndex, int newIndex) async {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final Todo item = _todos.removeAt(oldIndex);
      _todos.insert(newIndex, item);
    });

    for (int i = 0; i < _todos.length; i++) {
      _dbHelper.updateOrder(_todos[i].id, i);
    }
  }

  Future<void> _removeTodo(int id) async {
    var index = _todos.indexWhere((element) => element.id == id);
    await _dbHelper.delete(id);
    setState(() {
      _todos.removeAt(index);
    });
  }
}
