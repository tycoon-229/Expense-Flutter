import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../../expense/domain/entities/expense.dart';
import '../../domain/entities/recurring_transaction.dart';

class RecurringLocalDataSource {
  static const String _storageKey = 'recurring_transactions_list';

  /// Lấy toàn bộ danh sách khoản thu chi cố định
  Future<List<RecurringTransaction>> getRecurringTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_storageKey) ?? [];
    return jsonList.map((item) => RecurringTransaction.fromJson(item)).toList();
  }

  /// Lưu danh sách khoản thu chi cố định
  Future<void> saveRecurringTransactions(List<RecurringTransaction> list) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = list.map((item) => item.toJson()).toList();
    await prefs.setStringList(_storageKey, jsonList);
  }

  /// Thêm khoản thu chi cố định mới
  Future<void> addRecurringTransaction(RecurringTransaction item) async {
    final list = await getRecurringTransactions();
    list.add(item);
    await saveRecurringTransactions(list);
  }

  /// Cập nhật khoản thu chi cố định
  Future<void> updateRecurringTransaction(RecurringTransaction item) async {
    final list = await getRecurringTransactions();
    final index = list.indexWhere((e) => e.id == item.id);
    if (index != -1) {
      list[index] = item;
      await saveRecurringTransactions(list);
    }
  }

  /// Xóa khoản thu chi cố định
  Future<void> deleteRecurringTransaction(String id) async {
    final list = await getRecurringTransactions();
    list.removeWhere((e) => e.id == id);
    await saveRecurringTransactions(list);
  }

  /// Kiểm tra và tự động sinh giao dịch Expense cho các khoản cố định đã đến hạn trong tháng
  Future<List<Expense>> checkAndGenerateDueExpenses() async {
    final list = await getRecurringTransactions();
    final now = DateTime.now();
    final currentMonthKey = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    final List<Expense> generatedExpenses = [];
    bool hasChanges = false;

    for (int i = 0; i < list.length; i++) {
      final item = list[i];
      if (!item.isActive) continue;

      // Nếu ngày hôm nay >= ngày cố định trong tháng và tháng này chưa được chạy
      if (now.day >= item.dayOfMonth && item.lastExecutedMonth != currentMonthKey) {
        // Tự động tạo Expense
        final newExpense = Expense(
          id: const Uuid().v4(),
          title: '${item.title} (Cố định)',
          amount: item.amount,
          date: DateTime(now.year, now.month, item.dayOfMonth),
          categoryId: item.categoryId,
          categoryName: item.categoryName,
          categoryColor: item.categoryColor,
          categoryIcon: item.categoryIcon,
          type: item.type,
        );

        generatedExpenses.add(newExpense);
        list[i] = item.copyWith(lastExecutedMonth: currentMonthKey);
        hasChanges = true;
      }
    }

    if (hasChanges) {
      await saveRecurringTransactions(list);
    }

    return generatedExpenses;
  }
}
