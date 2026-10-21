import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../expense/domain/entities/expense.dart';
import '../../domain/entities/recurring_transaction.dart';

class RecurringLocalDataSource {
  static const String _storageKey = 'recurring_transactions_list';
  final SupabaseClient _supabase = Supabase.instance.client;

  String? get _currentUserId => _supabase.auth.currentUser?.id;

  /// Lấy toàn bộ danh sách khoản thu chi cố định (ưu tiên Supabase, fallback SharedPreferences)
  Future<List<RecurringTransaction>> getRecurringTransactions() async {
    final userId = _currentUserId;
    if (userId != null) {
      try {
        final response = await _supabase
            .from('recurring_transactions')
            .select()
            .eq('user_id', userId)
            .order('created_at', ascending: false);

        final list = (response as List)
            .map((e) => RecurringTransaction.fromSupabaseMap(e as Map<String, dynamic>))
            .toList();

        // Lưu cache cục bộ
        await _saveToLocalCache(list);
        return list;
      } catch (e) {
        debugPrint('Lỗi lấy recurring từ Supabase: $e, sử dụng cache cục bộ.');
      }
    }

    return _getFromLocalCache();
  }

  /// Thêm khoản thu chi cố định mới
  Future<void> addRecurringTransaction(RecurringTransaction item) async {
    final userId = _currentUserId;
    if (userId != null) {
      try {
        final data = item.toSupabaseMap(userId);
        await _supabase.from('recurring_transactions').insert(data);
      } catch (e) {
        debugPrint('Lỗi thêm recurring lên Supabase: $e');
      }
    }

    final localList = await _getFromLocalCache();
    localList.insert(0, item);
    await _saveToLocalCache(localList);
  }

  /// Cập nhật khoản thu chi cố định
  Future<void> updateRecurringTransaction(RecurringTransaction item) async {
    final userId = _currentUserId;
    if (userId != null) {
      try {
        final data = item.toSupabaseMap(userId);
        await _supabase
            .from('recurring_transactions')
            .update(data)
            .eq('id', item.id)
            .eq('user_id', userId);
      } catch (e) {
        debugPrint('Lỗi cập nhật recurring lên Supabase: $e');
      }
    }

    final localList = await _getFromLocalCache();
    final index = localList.indexWhere((e) => e.id == item.id);
    if (index != -1) {
      localList[index] = item;
      await _saveToLocalCache(localList);
    }
  }

  /// Xóa khoản thu chi cố định
  Future<void> deleteRecurringTransaction(String id) async {
    final userId = _currentUserId;
    if (userId != null) {
      try {
        await _supabase
            .from('recurring_transactions')
            .delete()
            .eq('id', id)
            .eq('user_id', userId);
      } catch (e) {
        debugPrint('Lỗi xóa recurring trên Supabase: $e');
      }
    }

    final localList = await _getFromLocalCache();
    localList.removeWhere((e) => e.id == id);
    await _saveToLocalCache(localList);
  }

  /// Kiểm tra và tự động sinh giao dịch Expense cho các khoản cố định đã đến hạn
  Future<List<Expense>> checkAndGenerateDueExpenses() async {
    final list = await getRecurringTransactions();
    final now = DateTime.now();
    final List<Expense> generatedExpenses = [];
    bool hasChanges = false;

    for (int i = 0; i < list.length; i++) {
      final item = list[i];
      if (!item.isActive) continue;

      bool isDue = false;
      DateTime targetDate = now;
      String currentExecutionKey = '';

      switch (item.frequency) {
        case RecurringFrequency.daily:
          currentExecutionKey =
              '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
          if (item.lastExecutedKey != currentExecutionKey) {
            isDue = true;
            targetDate = DateTime(now.year, now.month, now.day);
          }
          break;

        case RecurringFrequency.weekly:
          final diff = now.weekday - item.dayOfWeek;
          if (diff >= 0) {
            final occurrence = now.subtract(Duration(days: diff));
            currentExecutionKey =
                '${occurrence.year}-${occurrence.month.toString().padLeft(2, '0')}-${occurrence.day.toString().padLeft(2, '0')}';
            if (item.lastExecutedKey != currentExecutionKey) {
              isDue = true;
              targetDate = DateTime(occurrence.year, occurrence.month, occurrence.day);
            }
          }
          break;

        case RecurringFrequency.monthly:
          final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
          final validDay = item.dayOfMonth.clamp(1, daysInMonth);
          if (now.day >= validDay) {
            currentExecutionKey =
                '${now.year}-${now.month.toString().padLeft(2, '0')}';
            if (item.lastExecutedKey != currentExecutionKey) {
              isDue = true;
              targetDate = DateTime(now.year, now.month, validDay);
            }
          }
          break;

        case RecurringFrequency.yearly:
          final isPastOrSameMonth = now.month > item.monthOfYear;
          final isSameMonthDay = now.month == item.monthOfYear && now.day >= item.dayOfMonth;
          if (isPastOrSameMonth || isSameMonthDay) {
            currentExecutionKey =
                '${now.year}-${item.monthOfYear.toString().padLeft(2, '0')}';
            if (item.lastExecutedKey != currentExecutionKey) {
              isDue = true;
              targetDate = DateTime(now.year, item.monthOfYear, item.dayOfMonth);
            }
          }
          break;
      }

      if (isDue) {
        final titleWithNote = item.note != null && item.note!.isNotEmpty
            ? '${item.title} (${item.frequency.displayName} - ${item.note})'
            : '${item.title} (${item.frequency.displayName})';

        final newExpense = Expense(
          id: const Uuid().v4(),
          title: titleWithNote,
          amount: item.amount,
          date: targetDate,
          categoryId: item.categoryId,
          categoryName: item.categoryName,
          categoryColor: item.categoryColor,
          categoryIcon: item.categoryIcon,
          type: item.type,
        );

        generatedExpenses.add(newExpense);
        final updatedItem = item.copyWith(lastExecutedKey: currentExecutionKey);
        list[i] = updatedItem;
        hasChanges = true;

        // Cập nhật lại key đã chạy lên Supabase
        await updateRecurringTransaction(updatedItem);
      }
    }

    if (hasChanges) {
      await _saveToLocalCache(list);
    }

    return generatedExpenses;
  }

  // Helper SharedPreferences
  Future<List<RecurringTransaction>> _getFromLocalCache() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_storageKey) ?? [];
    return jsonList.map((item) => RecurringTransaction.fromJson(item)).toList();
  }

  Future<void> _saveToLocalCache(List<RecurringTransaction> list) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = list.map((item) => item.toJson()).toList();
    await prefs.setStringList(_storageKey, jsonList);
  }
}
