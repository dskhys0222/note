import 'package:flutter/material.dart';
import 'package:note/add_todo_dialog.dart';
import 'package:note/db_helper.dart';
import 'package:note/edit_todo_dialog.dart';
import 'package:note/tag.dart';
import 'package:note/todo.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TodoListPage extends StatefulWidget {
  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  List<Todo> _todos = [];
  List<Tag> _tags = [];
  DBHelper _dbHelper = DBHelper();
  int? _selectedTagId;
  bool _showTagSelection = false;

  @override
  void initState() {
    super.initState();
    _dbHelper.readAllTodo().then((value) {
      setState(() {
        _todos = value;
      });
    });
    _dbHelper
        .readAllTag()
        .then((value) {
          setState(() {
            _tags = value;
          });
        })
        .then((_) => _loadSelectedTagId())
        .then((value) {
          setState(() {
            _selectedTagId = value;
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedTagId == null
              ? 'All'
              : _tags.firstWhere((x) => x.id == _selectedTagId).name,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        scrolledUnderElevation: 0,
      ),
      body: ReorderableListView(
        padding: EdgeInsets.only(bottom: 80),
        onReorder: (oldIndex, newIndex) async {
          await _reorderTodos(oldIndex, newIndex);
        },
        children: _todos
            .where((todo) =>
                _selectedTagId == null || todo.tagIds.contains(_selectedTagId))
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
                        Flexible(
                          fit: FlexFit.tight,
                          flex: 3,
                          child: Text(
                            todo.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Flexible(
                          fit: FlexFit.loose,
                          flex: 1,
                          child: Text(
                            todo.tagIds
                                .map((x) =>
                                    _tags.firstWhere((tag) => tag.id == x))
                                .map((x) => x.name)
                                .join(', '),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 12.0,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        )
                      ],
                    ),
                    onTap: () async {
                      List<String>? data = await showDialog(
                          context: context,
                          builder: (context) => EditTodoDialog(
                                todo.name,
                                todo.tagIds
                                    .map((x) => _tags
                                        .firstWhere((tag) => tag.id == x)
                                        .name)
                                    .join(' '),
                              ));

                      if (data != null) {
                        await _editTodo(todo.id!, data[0], data.sublist(1));
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
            right: 75,
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
            Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _showTagSelection = false;
                    });
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 70,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: 200,
                      maxWidth: 300,
                    ),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .outlineVariant
                            .withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: SingleChildScrollView(
                          child: Wrap(
                            spacing: 5,
                            runSpacing: 5,
                            alignment: WrapAlignment.center,
                            children: _tags
                                .map((tag) => FilterChip(
                                      label: Text(tag.name),
                                      showCheckmark: false,
                                      selected: tag.id == _selectedTagId,
                                      onSelected: (bool selected) {
                                        setState(() {
                                          _selectedTagId =
                                              selected ? tag.id : null;
                                          _showTagSelection = false;
                                        });
                                        _saveSelectedTagId(
                                            selected ? tag.id : null);
                                      },
                                    ))
                                .toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          Positioned(
            right: 0,
            bottom: 0,
            child: FloatingActionButton(
              onPressed: () async {
                List<String>? data = await showDialog(
                  context: context,
                  builder: (context) => AddTodoDialog(
                    initialTag: _selectedTagId == null
                        ? null
                        : _tags.firstWhere((x) => x.id == _selectedTagId).name,
                  ),
                );

                if (data != null) {
                  await _addTodo(data[0], data.sublist(1));
                }
              },
              child: Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addTodo(String name, List<String> tags) async {
    var todoId = await _dbHelper.insertTodo(name);

    var uniqueTags = tags.toSet().toList();
    for (var tag in uniqueTags) {
      await _addTodoTag(todoId, tag);
    }

    setState(() {
      _todos.add(Todo(
        id: todoId,
        name: name,
        tagIds: uniqueTags
            .map((x) => _tags.firstWhere((tag) => tag.name == x).id)
            .toList(),
      ));
    });
  }

  Future<void> _editTodo(int todoId, String name, List<String> tags) async {
    var index = _todos.indexWhere((x) => x.id == todoId);
    var todo = _todos[index];
    if (name != todo.name) {
      todo.name = name;
      await _dbHelper.updateName(todo);
    }

    var oldTags = todo.tagIds
        .map((x) => _tags.firstWhere((tag) => tag.id == x).name)
        .toSet();
    var newTags = tags.toSet();

    var removed = oldTags.difference(newTags);
    for (var tag in removed) {
      var tagId = _tags.firstWhere((x) => x.name == tag).id;
      await _dbHelper.deleteTodoTag(todoId, tagId);
    }

    var added = newTags.difference(oldTags);
    for (var tag in added) {
      await _addTodoTag(todoId, tag);
    }

    todo.tagIds =
        tags.map((x) => _tags.firstWhere((tag) => tag.name == x).id).toList();

    setState(() {
      _todos[index] = todo;
    });
  }

  Future<void> _addTodoTag(int todoId, String tagName) async {
    var index = _tags.indexWhere((x) => x.name == tagName);
    int tagId;
    if (index >= 0) {
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

  Future<void> _saveSelectedTagId(int? tagId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (tagId == null) {
      await prefs.remove('_selectedTagId');
    } else {
      await prefs.setInt('_selectedTagId', tagId);
    }
  }

  Future<int?> _loadSelectedTagId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('_selectedTagId');
  }
}
