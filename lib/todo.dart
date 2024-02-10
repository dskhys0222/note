class Todo {
  final int? id;
  String name;
  List<String> tags;

  Todo({required this.id, required this.name, required this.tags});

  // Convert a Todo into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'tags': tags};
  }

  // Convert a Map into a Todo. The keys must correspond to the names of the
  // columns in the database.
  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'] as int,
      name: map['name'] as String,
      tags: map['tags'] as List<String>,
    );
  }
}
