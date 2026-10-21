import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../data/models/category_model.dart';
import '../../domain/repositories/category_repository.dart';
import 'category_state.dart';

@injectable
class CategoryCubit extends Cubit<CategoryState> {
  final CategoryRepository repository;

  CategoryCubit(this.repository) : super(CategoryInitial());

  Future<void> loadCategories({String? type}) async {
    emit(CategoryLoading());
    try {
      final list = await repository.getCategories(type: type);
      emit(CategoryLoaded(list));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> addCategory(CategoryModel category) async {
    try {
      await repository.addCategory(category);
      await loadCategories();
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> updateCategory(CategoryModel category) async {
    try {
      await repository.updateCategory(category);
      await loadCategories();
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await repository.deleteCategory(id);
      await loadCategories();
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }
}
