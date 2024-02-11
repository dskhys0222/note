import 'package:flutter/material.dart';
import 'package:note/add_todo_dialog.dart';
import 'package:note/db_helper.dart';
import 'package:note/edit_todo_dialog.dart';
import 'package:note/tag.dart';
import 'package:note/todo.dart';

class TodoListPage extends StatefulWidget {
  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  List<Todo> _todos = [];
  List<Tag> _tags = [];
  DBHelper _dbHelper = DBHelper();
  List<String> _selectedTags = [];
  bool _showTagSelection = false;

  @override
  void initState() {
    super.initState();
    _dbHelper.readAllTodo().then((value) {
      setState(() {
        _todos = value;
      });
    });
    _dbHelper.readAllTag().then((value) {
      setState(() {
        _tags = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedTags.isEmpty
              ? 'All'
              : _selectedTags.map((x) => '#$x').join(', '),
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ReorderableListView(
        onReorder: (oldIndex, newIndex) async {
          await _reorderTodos(oldIndex, newIndex);
        },
        children: _todos
            .where((todo) =>
                _selectedTags.isEmpty ||
                todo.tags.any((tag) => _selectedTags.contains(tag)))
            .map((todo) => Dismissible(
                  key: Key(todo.id.toString()),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) async {
                    await _removeTodo(todo.id!);
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20.0),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                  ),
                  child: ListTile(
                    leading: Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Icon(Icons.circle, size: 10.0),
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(todo.name),
                        Text(
                          todo.tags.join(', '),
                          style: TextStyle(
                            fontSize: 12.0,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        )
                      ],
                    ),
                    onTap: () async {
                      Todo? data = await showDialog(
                        context: context,
                        builder: (context) => EditTodoDialog(todo),
                      );

                      if (data != null) {
                        await _editTodo(todo.id!, data);
                      }
                    },
                  ),
                ))
            .toList(),
      ),
      floatingActionButton: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            left: 30,
            bottom: 0,
            child: FloatingActionButton(
              onPressed: () {
                setState(() {
                  _showTagSelection = !_showTagSelection;
                });
              },
              child: Icon(Icons.tag),
            ),
          ),
          if (_showTagSelection)
            Positioned(
              width: MediaQuery.of(context).size.width - 30,
              left: 30,
              bottom: 70,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Wrap(
                    spacing: 5,
                    runSpacing: 5,
                    alignment: WrapAlignment.center,
                    children: _tags
                        .map((x) => x.name)
                        .map((tag) => FilterChip(
                              label: Text(tag),
                              selected: _selectedTags.contains(tag),
                              onSelected: (bool selected) {
                                setState(() {
                                  if (selected) {
                                    _selectedTags = [(tag)];
                                  } else {
                                    _selectedTags.remove(tag);
                                  }
                                });
                              },
                            ))
                        .toList(),
                  ),
                ),
              ),
            ),
          Positioned(
            right: 0,
            bottom: 0,
            child: FloatingActionButton(
              onPressed: () async {
                Todo? data = await showDialog(
                  context: context,
                  builder: (context) => AddTodoDialog(),
                );

                if (data != null) {
                  await _addTodo(data);
                }
              },
              child: Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addTodo(Todo data) async {
    var todoId = await _dbHelper.insertTodo(data.name);

    var tags = data.tags.toSet().toList();
    for (var tag in tags) {
      await _addTodoTag(todoId, tag);
    }

    setState(() {
      _todos.add(Todo(id: todoId, name: data.name, tags: tags));
    });
  }

  Future<void> _editTodo(int todoId, Todo data) async {
    var index = _todos.indexWhere((x) => x.id == todoId);
    var todo = _todos[index];
    if (data.name != todo.name) {
      todo.name = data.name;
      await _dbHelper.updateName(todo);
    }

    var oldTags = todo.tags.toSet();
    var newTags = data.tags.toSet();

    var removed = oldTags.difference(newTags);
    for (var tag in removed) {
      var tagId = _tags.firstWhere((x) => x.name == tag).id;
      await _dbHelper.deleteTodoTag(todoId, tagId);
    }

    var added = newTags.difference(oldTags);
    for (var tag in added) {
      await _addTodoTag(todoId, tag);
    }

    todo.tags = data.tags;

    setState(() {
      _todos[index] = todo;
    });
  }

  Future<void> _addTodoTag(int todoId, String tagName) async {
    var index = _tags.indexWhere((x) => x.name == tagName);
    int tagId;
    if (index > 0) {
      tagId = (_tags[index].id);
    } else {
      tagId = await _dbHelper.insertTag(tagName);
      setState(() {
        _tags.add(Tag(id: tagId, name: tagName));
      });
    }

    await _dbHelper.insertTodoTag(todoId, tagId);
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
      _dbHelper.updateOrder(_todos[i].id!, i);
    }
  }

  Future<void> _removeTodo(int id) async {
    var index = _todos.indexWhere((x) => x.id == id);
    await _dbHelper.deleteTodo(id);
    setState(() {
      _todos.removeAt(index);
    });
  }
}
