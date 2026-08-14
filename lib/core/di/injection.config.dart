// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:expense/features/expense/data/datasources/expense_local_data_source.dart'
    as _i3;
import 'package:expense/features/expense/data/repositories/expense_repository_impl.dart'
    as _i5;
import 'package:expense/features/expense/domain/repositories/expense_repository.dart'
    as _i4;
import 'package:expense/features/expense/domain/usecases/add_expense.dart'
    as _i8;
import 'package:expense/features/expense/domain/usecases/delete_expense.dart'
    as _i9;
import 'package:expense/features/expense/domain/usecases/get_expenses.dart'
    as _i6;
import 'package:expense/features/expense/domain/usecases/update_expense.dart'
    as _i7;
import 'package:expense/features/expense/presentation/bloc/expense_bloc.dart'
    as _i10;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;

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
    gh.lazySingleton<_i3.ExpenseLocalDataSource>(
        () => _i3.ExpenseLocalDataSourceImpl());
    gh.lazySingleton<_i4.ExpenseRepository>(
        () => _i5.ExpenseRepositoryImpl(gh<_i3.ExpenseLocalDataSource>()));
    gh.lazySingleton<_i6.GetExpenses>(
        () => _i6.GetExpenses(gh<_i4.ExpenseRepository>()));
    gh.lazySingleton<_i7.UpdateExpense>(
        () => _i7.UpdateExpense(gh<_i4.ExpenseRepository>()));
    gh.lazySingleton<_i8.AddExpense>(
        () => _i8.AddExpense(gh<_i4.ExpenseRepository>()));
    gh.lazySingleton<_i9.DeleteExpense>(
        () => _i9.DeleteExpense(gh<_i4.ExpenseRepository>()));
    gh.factory<_i10.ExpenseBloc>(() => _i10.ExpenseBloc(
          getExpenses: gh<_i6.GetExpenses>(),
          addExpense: gh<_i8.AddExpense>(),
          deleteExpense: gh<_i9.DeleteExpense>(),
          updateExpense: gh<_i7.UpdateExpense>(),
        ));
    return this;
  }
}
