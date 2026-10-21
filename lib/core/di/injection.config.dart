// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:expense/core/di/register_module.dart' as _i16;
import 'package:expense/features/category/data/datasources/category_remote_data_source.dart'
    as _i4;
import 'package:expense/features/category/data/repositories/category_repository_impl.dart'
    as _i6;
import 'package:expense/features/category/domain/repositories/category_repository.dart'
    as _i5;
import 'package:expense/features/category/presentation/bloc/category_cubit.dart'
    as _i13;
import 'package:expense/features/expense/data/datasources/expense_remote_data_source.dart'
    as _i7;
import 'package:expense/features/expense/data/repositories/expense_repository_impl.dart'
    as _i9;
import 'package:expense/features/expense/domain/repositories/expense_repository.dart'
    as _i8;
import 'package:expense/features/expense/domain/usecases/add_expense.dart'
    as _i12;
import 'package:expense/features/expense/domain/usecases/delete_expense.dart'
    as _i14;
import 'package:expense/features/expense/domain/usecases/get_expenses.dart'
    as _i10;
import 'package:expense/features/expense/domain/usecases/update_expense.dart'
    as _i11;
import 'package:expense/features/expense/presentation/bloc/expense_bloc.dart'
    as _i15;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;
import 'package:supabase_flutter/supabase_flutter.dart' as _i3;

extension GetItInjectableX on _i1.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i1.GetIt init({
    String? environment,
    _i2.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i2.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final registerModule = _$RegisterModule();
    gh.lazySingleton<_i3.SupabaseClient>(() => registerModule.supabaseClient);
    gh.lazySingleton<_i4.CategoryRemoteDataSource>(
        () => _i4.CategoryRemoteDataSourceImpl(gh<_i3.SupabaseClient>()));
    gh.lazySingleton<_i5.CategoryRepository>(
        () => _i6.CategoryRepositoryImpl(gh<_i4.CategoryRemoteDataSource>()));
    gh.lazySingleton<_i7.ExpenseRemoteDataSource>(
        () => _i7.ExpenseRemoteDataSourceImpl(gh<_i3.SupabaseClient>()));
    gh.lazySingleton<_i8.ExpenseRepository>(
        () => _i9.ExpenseRepositoryImpl(gh<_i7.ExpenseRemoteDataSource>()));
    gh.lazySingleton<_i10.GetExpenses>(
        () => _i10.GetExpenses(gh<_i8.ExpenseRepository>()));
    gh.lazySingleton<_i11.UpdateExpense>(
        () => _i11.UpdateExpense(gh<_i8.ExpenseRepository>()));
    gh.lazySingleton<_i12.AddExpense>(
        () => _i12.AddExpense(gh<_i8.ExpenseRepository>()));
    gh.factory<_i13.CategoryCubit>(
        () => _i13.CategoryCubit(gh<_i5.CategoryRepository>()));
    gh.lazySingleton<_i14.DeleteExpense>(
        () => _i14.DeleteExpense(gh<_i8.ExpenseRepository>()));
    gh.factory<_i15.ExpenseBloc>(() => _i15.ExpenseBloc(
          getExpenses: gh<_i10.GetExpenses>(),
          addExpense: gh<_i12.AddExpense>(),
          deleteExpense: gh<_i14.DeleteExpense>(),
          updateExpense: gh<_i11.UpdateExpense>(),
        ));
    return this;
  }
}

class _$RegisterModule extends _i16.RegisterModule {}
