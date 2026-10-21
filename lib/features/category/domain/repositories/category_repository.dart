import '../../data/models/category_model.dart';

abstract class CategoryRepository {
  Future<List<CategoryModel>> getCategories({String? type});
  Future<void> addCategory(CategoryModel category);
  Future<void> updateCategory(CategoryModel category);
  Future<void> deleteCategory(String id);
}
