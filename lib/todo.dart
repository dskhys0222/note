class Todo {
  final int? id;
  String name;
  List<int> tagIds;

  Todo({required this.id, required this.name, required this.tagIds});

  // Convert a Todo into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'tags': tagIds.join(',')};
  }

  // Convert a Map into a Todo. The keys must correspond to the names of the
  // columns in the database.
  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'] as int,
      name: map['name'] as String,
      tagIds: map['tagIds'] != null
          ? (map['tagIds'] as String)
              .split(',')
              .map((x) => int.parse(x))
              .toList()
          : [],
    );
  }
}
