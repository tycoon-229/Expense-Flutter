import 'package:flutter_test/flutter_test.dart';
import 'package:expense/features/expense/domain/entities/expense.dart';
import 'package:expense/features/expense/domain/utils/expense_calculations.dart';

void main() {
  group('ExpenseCalculations Tests', () {
    final now = DateTime.now();
    final sampleExpenses = [
      Expense(
        id: '1',
        title: 'Lương tháng',
        amount: 20000000,
        date: now,
        type: TransactionType.income,
        categoryName: 'Lương',
        categoryColor: '#4CAF50',
      ),
      Expense(
        id: '2',
        title: 'Ăn tối nhà hàng',
        amount: 500000,
        date: now,
        type: TransactionType.expense,
        categoryName: 'Ăn uống',
        categoryColor: '#FF5722',
      ),
      Expense(
        id: '3',
        title: 'Đổ xăng',
        amount: 100000,
        date: now.subtract(const Duration(days: 2)),
        type: TransactionType.expense,
        categoryName: 'Đi lại',
        categoryColor: '#2196F3',
      ),
    ];

    test('Tính đúng tổng thu nhập', () {
      final income = ExpenseCalculations.totalIncome(sampleExpenses);
      expect(income, 20000000);
    });

    test('Tính đúng tổng chi tiêu', () {
      final expense = ExpenseCalculations.totalExpense(sampleExpenses);
      expect(expense, 600000);
    });

    test('Tính đúng số dư', () {
      final balance = ExpenseCalculations.balance(sampleExpenses);
      expect(balance, 19400000);
    });

    test('Tính đúng 7 ngày gần nhất', () {
      final points = ExpenseCalculations.calculateLast7Days(sampleExpenses);
      expect(points.length, 7);
      // Ngày hôm nay (cuối mảng) phải có chi tiêu 500.000 và thu nhập 20.000.000
      final todayPoint = points.last;
      expect(todayPoint.expenseAmount, 500000);
      expect(todayPoint.incomeAmount, 20000000);
    });

    test('Lọc theo loại giao dịch chi tiêu', () {
      final filtered = ExpenseCalculations.filterExpenses(
        expenses: sampleExpenses,
        filterType: TransactionType.expense,
      );
      expect(filtered.length, 2);
    });

    test('Gom nhóm phân bổ danh mục chi tiêu', () {
      final breakdown = ExpenseCalculations.calculateCategorySpending(sampleExpenses);
      expect(breakdown.length, 2);
      expect(breakdown.first.categoryName, 'Ăn uống');
      expect(breakdown.first.totalAmount, 500000);
    });
  });
}
