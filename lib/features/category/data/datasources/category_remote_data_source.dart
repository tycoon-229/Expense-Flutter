import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/category_model.dart';

abstract class CategoryRemoteDataSource {
  Future<List<CategoryModel>> getCategories({String? type});
  Future<void> addCategory(CategoryModel category);
  Future<void> updateCategory(CategoryModel category);
  Future<void> deleteCategory(String id);
}

@LazySingleton(as: CategoryRemoteDataSource)
class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final SupabaseClient supabase;

  CategoryRemoteDataSourceImpl(this.supabase);

  @override
  Future<List<CategoryModel>> getCategories({String? type}) async {
    var query = supabase.from('categories').select();
    if (type != null && type.isNotEmpty) {
      query = query.eq('type', type);
    }
    final response = await query.order('created_at', ascending: true);

    return (response as List).map((json) => CategoryModel.fromJson(json)).toList();
  }

  @override
  Future<void> addCategory(CategoryModel category) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final data = category.toJson()..['user_id'] = userId;
    await supabase.from('categories').insert(data);
  }

  @override
  Future<void> updateCategory(CategoryModel category) async {
    await supabase
        .from('categories')
        .update(category.toJson())
        .eq('id', category.id);
  }

  @override
  Future<void> deleteCategory(String id) async {
    await supabase.from('categories').delete().eq('id', id);
  }
}