import 'dart:io' as io;

import 'package:note/tag.dart';
import 'package:note/todo.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await initDatabase();
    return _db!;
  }

  Future<Database> initDatabase() async {
    io.Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, 'todo.db');
    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  Future<List<Tag>> readAllTag() async {
    var dbClient = await database;
    var result = await dbClient.query('tag', orderBy: 'name');
    return result.map((item) => Tag.fromMap(item)).toList();
  }

  Future<List<Todo>> readAllTodo() async {
    var dbClient = await database;
    var result = await dbClient.rawQuery(
      '''
      SELECT
        todo.id AS id
        , todo.name AS name
        , GROUP_CONCAT(todo_tag.tag_id, ',') AS tagIds
      FROM
        todo
        LEFT JOIN todo_tag ON todo.id = todo_tag.todo_id
      GROUP BY
        todo.id
      ORDER BY
        todo."order"
      ''',
    );
    return result.map((item) => Todo.fromMap(item)).toList();
  }

  Future<int> insertTodo(String name) async {
    var dbClient = await database;
    var todos = await readAllTodo();
    var order = todos.length;
    var id = await dbClient.insert('todo', {'name': name, 'order': order});
    return id;
  }

  Future<int> insertTag(String name) async {
    var dbClient = await database;
    var id = await dbClient.insert('tag', {'name': name});
    return id;
  }

  Future<int> insertTodoTag(int todoId, int tagId) async {
    var dbClient = await database;
    var id =
        await dbClient.insert('todo_tag', {'todo_id': todoId, 'tag_id': tagId});
    return id;
  }

  Future<int> updateName(Todo todo) async {
    var dbClient = await database;
    return await dbClient.update(
      'todo',
      {'name': todo.name},
      where: 'id = ?',
      whereArgs: [todo.id],
    );
  }

  Future<int> updateOrder(int id, int order) async {
    var dbClient = await database;
    return await dbClient.update(
      'todo',
      {'order': order},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteTodo(int id) async {
    var dbClient = await database;
    return await dbClient.delete(
      'todo',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteTodoTag(int todoId, int tagId) async {
    var dbClient = await database;
    return await dbClient.delete(
      'todo_tag',
      where: 'todo_id = ? AND tag_id = ?',
      whereArgs: [todoId, tagId],
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(
      '''
      CREATE TABLE todo (
        id INTEGER PRIMARY KEY AUTOINCREMENT
        , name TEXT
        , "order" INTEGER
      )
      ''',
    );
    await db.execute(
      '''
      CREATE TABLE tag (
        id INTEGER PRIMARY KEY AUTOINCREMENT
        , name TEXT
      )
      ''',
    );
    await db.execute(
      '''
      CREATE TABLE todo_tag (
        todo_id INTEGER
        , tag_id INTEGER
        , FOREIGN KEY (todo_id) REFERENCES todo (id)
        , FOREIGN KEY (tag_id) REFERENCES tag (id)
        , PRIMARY KEY (todo_id, tag_id)
      )
      ''',
    );
  }
}
