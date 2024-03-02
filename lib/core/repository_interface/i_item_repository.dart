import 'package:note/core/entity/item.dart';
import 'package:note/core/entity/tag.dart';

abstract class IItemRepository {
  Future<Item> readItem(int id);
  Future<List<Item>> readAllItems();
  Future<List<Tag>> readAllTags();
  Future<void> saveItem(Item item);
  Future<void> deleteItem(int id);
  Future<void> saveTag(Tag tag);
  Future<void> deleteTag(int id);
}
