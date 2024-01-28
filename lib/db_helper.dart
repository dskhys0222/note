import 'dart:io' as io;

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

  Future<List<Todo>> readAll() async {
    var dbClient = await database;
    var result = await dbClient.query('todo');
    return result
        .map((item) => Todo(
              id: item['id'] as int,
              name: item['name'] as String,
            ))
        .toList();
  }

  Future<Todo> insert(String name) async {
    var dbClient = await database;
    var id = await dbClient.insert('todo', {'name': name});
    return Todo(id: id, name: name);
  }

  Future<int> update(Todo todo) async {
    var dbClient = await database;
    return await dbClient.update(
      'todo',
      {'name': todo.name},
      where: 'id = ?',
      whereArgs: [todo.id],
    );
  }

  Future<int> delete(int id) async {
    var dbClient = await database;
    return await dbClient.delete(
      'todo',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('CREATE TABLE todo (id INTEGER PRIMARY KEY, name TEXT)');
  }
}
