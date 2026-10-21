import 'package:intl/intl.dart';
import '../../../category/data/models/category_model.dart';
import '../entities/expense.dart';

class DailyExpensePoint {
  final DateTime date;
  final String dayLabel; // Ví dụ: T2, T3, hoặc 15/10
  final String fullDateLabel; // 15/10/2026
  final double expenseAmount;
  final double incomeAmount;

  DailyExpensePoint({
    required this.date,
    required this.dayLabel,
    required this.fullDateLabel,
    required this.expenseAmount,
    this.incomeAmount = 0.0,
  });
}

class CategorySpending {
  final String categoryName;
  final double totalAmount;
  final double percentage;
  final String? colorHex;
  final String? iconKey;

  CategorySpending({
    required this.categoryName,
    required this.totalAmount,
    required this.percentage,
    this.colorHex,
    this.iconKey,
  });
}

class ExpenseCalculations {
  /// Tính tổng thu nhập
  static double totalIncome(List<Expense> expenses) {
    return expenses
        .where((e) => e.type == TransactionType.income)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  /// Tính tổng chi tiêu
  static double totalExpense(List<Expense> expenses) {
    return expenses
        .where((e) => e.type == TransactionType.expense)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  /// Tính số dư
  static double balance(List<Expense> expenses) {
    return totalIncome(expenses) - totalExpense(expenses);
  }

  /// Lọc danh sách giao dịch theo điều kiện tìm kiếm, danh mục, loại và tháng
  static List<Expense> filterExpenses({
    required List<Expense> expenses,
    String searchQuery = '',
    String? selectedCategory,
    TransactionType? filterType,
    DateTime? selectedMonth,
  }) {
    final query = searchQuery.trim().toLowerCase();
    return expenses.where((e) {
      final matchesTitle = query.isEmpty || e.title.toLowerCase().contains(query);
      final matchesCategory = selectedCategory == null ||
          (e.categoryName ?? 'Chưa phân loại') == selectedCategory;
      final matchesType = filterType == null || e.type == filterType;
      final matchesMonth = selectedMonth == null ||
          (e.date.year == selectedMonth.year && e.date.month == selectedMonth.month);

      return matchesTitle && matchesCategory && matchesType && matchesMonth;
    }).toList();
  }

  /// Tính toán chi tiêu chi tiết 7 ngày gần nhất (từ 6 ngày trước đến hôm nay)
  static List<DailyExpensePoint> calculateLast7Days(List<Expense> expenses) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final List<DailyExpensePoint> points = [];

    final vietnameseWeekdays = {
      1: 'T2',
      2: 'T3',
      3: 'T4',
      4: 'T5',
      5: 'T6',
      6: 'T7',
      7: 'CN',
    };

    for (int i = 6; i >= 0; i--) {
      final targetDate = today.subtract(Duration(days: i));
      final nextDate = targetDate.add(const Duration(days: 1));

      // Lọc giao dịch của ngày targetDate
      final dayExpenses = expenses.where((e) {
        return e.date.isAfter(targetDate.subtract(const Duration(seconds: 1))) &&
            e.date.isBefore(nextDate);
      }).toList();

      final dayExpenseTotal = dayExpenses
          .where((e) => e.type == TransactionType.expense)
          .fold(0.0, (sum, item) => sum + item.amount);

      final dayIncomeTotal = dayExpenses
          .where((e) => e.type == TransactionType.income)
          .fold(0.0, (sum, item) => sum + item.amount);

      final dayName = vietnameseWeekdays[targetDate.weekday] ?? 'T${targetDate.weekday}';
      final isToday = i == 0;

      points.add(DailyExpensePoint(
        date: targetDate,
        dayLabel: isToday ? 'Hôm nay' : dayName,
        fullDateLabel: DateFormat('dd/MM').format(targetDate),
        expenseAmount: dayExpenseTotal,
        incomeAmount: dayIncomeTotal,
      ));
    }

    return points;
  }

  /// Gom nhóm phân bổ chi tiêu theo danh mục
  static List<CategorySpending> calculateCategorySpending(List<Expense> expenses) {
    final expenseOnly = expenses.where((e) => e.type == TransactionType.expense).toList();
    final total = expenseOnly.fold(0.0, (sum, e) => sum + e.amount);

    if (total == 0) return [];

    final Map<String, List<Expense>> grouped = {};
    for (final e in expenseOnly) {
      final catName = e.categoryName ?? 'Chưa phân loại';
      grouped.putIfAbsent(catName, () => []).add(e);
    }

    final List<CategorySpending> result = [];
    for (final entry in grouped.entries) {
      final catAmount = entry.value.fold(0.0, (sum, e) => sum + e.amount);
      final first = entry.value.first;
      result.add(CategorySpending(
        categoryName: entry.key,
        totalAmount: catAmount,
        percentage: (catAmount / total) * 100,
        colorHex: first.categoryColor,
        iconKey: first.categoryIcon,
      ));
    }

    result.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
    return result;
  }

  /// Tính toán hạn mức chi tiêu cho từng danh mục trong tháng
  static List<CategoryBudgetProgress> calculateCategoryBudgets({
    required List<Expense> expenses,
    required List<CategoryModel> categories,
    DateTime? month,
  }) {
    final targetMonth = month ?? DateTime.now();
    final monthExpenses = expenses.where((e) {
      return e.type == TransactionType.expense &&
          e.date.year == targetMonth.year &&
          e.date.month == targetMonth.month;
    }).toList();

    final List<CategoryBudgetProgress> list = [];
    for (final cat in categories) {
      if (cat.type != 'expense' || cat.monthlyBudget == null || cat.monthlyBudget! <= 0) {
        continue;
      }
      final spent = monthExpenses
          .where((e) => e.categoryId == cat.id || (e.categoryName == cat.name))
          .fold(0.0, (sum, e) => sum + e.amount);

      final budget = cat.monthlyBudget!;
      final percentage = (spent / budget) * 100;

      list.add(CategoryBudgetProgress(
        category: cat,
        currentSpent: spent,
        budget: budget,
        percentage: percentage,
        isOverBudget: spent > budget,
        remaining: budget - spent,
      ));
    }

    list.sort((a, b) => b.percentage.compareTo(a.percentage));
    return list;
  }
}

class CategoryBudgetProgress {
  final CategoryModel category;
  final double currentSpent;
  final double budget;
  final double percentage;
  final bool isOverBudget;
  final double remaining;

  CategoryBudgetProgress({
    required this.category,
    required this.currentSpent,
    required this.budget,
    required this.percentage,
    required this.isOverBudget,
    required this.remaining,
  });
}
