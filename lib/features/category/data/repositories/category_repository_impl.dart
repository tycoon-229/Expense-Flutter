import 'package:injectable/injectable.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_remote_data_source.dart';
import '../models/category_model.dart';

@LazySingleton(as: CategoryRepository)
class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDataSource remoteDataSource;

  CategoryRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<CategoryModel>> getCategories({String? type}) {
    return remoteDataSource.getCategories(type: type);
  }

  @override
  Future<void> addCategory(CategoryModel category) {
    return remoteDataSource.addCategory(category);
  }

  @override
  Future<void> updateCategory(CategoryModel category) {
    return remoteDataSource.updateCategory(category);
  }

  @override
  Future<void> deleteCategory(String id) {
    return remoteDataSource.deleteCategory(id);
  }
}
