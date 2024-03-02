import 'package:note/core/entity/tag.dart';
import 'package:note/core/repository_interface/i_item_repository.dart';

class Item {
  IItemRepository _repository;

  int _id;
  int get id => _id;

  String _name;
  String get name => _name;

  String _description;
  String get description => _description;

  List<Tag> _tags;
  List<Tag> get tags => [..._tags];

  Item({
    required IItemRepository repository,
    required int id,
    required String name,
    String description = "",
    List<Tag> tags = const [],
  })  : _repository = repository,
        _tags = tags,
        _description = description,
        _name = name,
        _id = id;

  Future<void> rename(String newName) async {
    _name = newName;
    await _repository.saveItem(this);
  }

  Future<void> updateDescription(String newDescription) async {
    _description = newDescription;
    await _repository.saveItem(this);
  }

  Future<void> addTag(Tag tag) async {
    _tags.add(tag);
    await _repository.saveItem(this);
  }

  Future<void> removeTag(Tag tag) async {
    _tags.removeWhere((x) => x.id == tag.id);
    await _repository.saveItem(this);
  }

  Future<void> delete() async {
    await _repository.deleteItem(_id);
  }
}
