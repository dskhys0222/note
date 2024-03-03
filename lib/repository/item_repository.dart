import 'package:note/core/entity/item.dart';
import 'package:note/core/entity/tag.dart';
import 'package:note/core/repository_interface/i_item_repository.dart';

class ItemRepository extends IItemRepository {
  @override
  Future<void> deleteItem(int id) {
    // TODO: implement deleteItem
    throw UnimplementedError();
  }

  @override
  Future<void> deleteTag(int id) {
    // TODO: implement deleteTag
    throw UnimplementedError();
  }

  @override
  Future<List<Item>> readAllItems() {
    // TODO: implement readAllItems
    throw UnimplementedError();
  }

  @override
  Future<List<Tag>> readAllTags() {
    // TODO: implement readAllTags
    throw UnimplementedError();
  }

  @override
  Future<Item> readItem(int id) {
    // TODO: implement readItem
    throw UnimplementedError();
  }

  @override
  Future<void> saveItem(Item item) {
    // TODO: implement saveItem
    throw UnimplementedError();
  }

  @override
  Future<void> saveTag(Tag tag) {
    // TODO: implement saveTag
    throw UnimplementedError();
  }
}
