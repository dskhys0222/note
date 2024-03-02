import 'package:note/core/repository_interface/i_item_repository.dart';

class Tag {
  IItemRepository _repository;

  int _id;
  int get id => _id;

  String _name;
  String get name => _name;

  Tag({
    required IItemRepository repository,
    required int id,
    required String name,
  })  : _repository = repository,
        _id = id,
        _name = name;

  Future<void> rename(String newName) async {
    _name = newName;
    await _repository.saveTag(this);
  }

  Future<void> delete() async {
    await _repository.deleteTag(_id);
  }
}
