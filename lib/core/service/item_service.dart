import 'package:note/core/entity/item.dart';
import 'package:note/core/entity/tag.dart';
import 'package:note/core/repository_interface/i_item_repository.dart';

class ItemService {
  IItemRepository _repository;

  ItemService({required IItemRepository repository}) : _repository = repository;

  Future<Item> readItem(int id) async {
    return await _repository.readItem(id);
  }

  Future<List<Item>> readAllItems() async {
    return await _repository.readAllItems();
  }

  Future<List<Tag>> readAllTags() async {
    return await _repository.readAllTags();
  }
}
