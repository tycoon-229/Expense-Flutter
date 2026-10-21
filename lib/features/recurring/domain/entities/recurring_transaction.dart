import 'dart:convert';
import '../../../expense/domain/entities/expense.dart';

enum RecurringFrequency {
  daily,
  weekly,
  monthly,
  yearly;

  String get displayName {
    switch (this) {
      case RecurringFrequency.daily:
        return 'Hàng ngày';
      case RecurringFrequency.weekly:
        return 'Hàng tuần';
      case RecurringFrequency.monthly:
        return 'Hàng tháng';
      case RecurringFrequency.yearly:
        return 'Hàng năm';
    }
  }

  static RecurringFrequency fromString(String? val) {
    switch (val) {
      case 'daily':
        return RecurringFrequency.daily;
      case 'weekly':
        return RecurringFrequency.weekly;
      case 'yearly':
        return RecurringFrequency.yearly;
      case 'monthly':
      default:
        return RecurringFrequency.monthly;
    }
  }

  String toDbString() => name;
}

class RecurringTransaction {
  final String id;
  final String? userId;
  final String title;
  final double amount;
  final TransactionType type;
  final String? categoryId;
  final String? categoryName;
  final String? categoryColor;
  final String? categoryIcon;
  final RecurringFrequency frequency;
  final int dayOfMonth; // 1 - 31 (Dùng cho monthly & yearly)
  final int dayOfWeek; // 1 (Thứ 2) -> 7 (Chủ nhật) (Dùng cho weekly)
  final int monthOfYear; // 1 - 12 (Dùng cho yearly)
  final String? note;
  final bool isActive;
  final String? lastExecutedKey; // Khóa đánh dấu lần chạy gần nhất (VD: '2026-10-21', '2026-10')

  RecurringTransaction({
    required this.id,
    this.userId,
    required this.title,
    required this.amount,
    required this.type,
    this.categoryId,
    this.categoryName,
    this.categoryColor,
    this.categoryIcon,
    this.frequency = RecurringFrequency.monthly,
    this.dayOfMonth = 1,
    this.dayOfWeek = 1,
    this.monthOfYear = 1,
    this.note,
    this.isActive = true,
    this.lastExecutedKey,
  });

  /// Getter hỗ trợ tương thích ngược với code cũ
  String? get lastExecutedMonth => lastExecutedKey;

  RecurringTransaction copyWith({
    String? id,
    String? userId,
    String? title,
    double? amount,
    TransactionType? type,
    String? categoryId,
    String? categoryName,
    String? categoryColor,
    String? categoryIcon,
    RecurringFrequency? frequency,
    int? dayOfMonth,
    int? dayOfWeek,
    int? monthOfYear,
    String? note,
    bool? isActive,
    String? lastExecutedKey,
  }) {
    return RecurringTransaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      categoryColor: categoryColor ?? this.categoryColor,
      categoryIcon: categoryIcon ?? this.categoryIcon,
      frequency: frequency ?? this.frequency,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      monthOfYear: monthOfYear ?? this.monthOfYear,
      note: note ?? this.note,
      isActive: isActive ?? this.isActive,
      lastExecutedKey: lastExecutedKey ?? this.lastExecutedKey,
    );
  }

  /// Map dữ liệu với cơ sở dữ liệu Supabase
  Map<String, dynamic> toSupabaseMap(String currentUserId) {
    return {
      'id': id,
      'user_id': currentUserId,
      'title': title,
      'amount': amount,
      'type': type == TransactionType.income ? 'income' : 'expense',
      'category_id': categoryId,
      'category_name': categoryName,
      'category_color': categoryColor,
      'category_icon': categoryIcon,
      'frequency': frequency.toDbString(),
      'day_of_month': dayOfMonth,
      'day_of_week': dayOfWeek,
      'month_of_year': monthOfYear,
      'note': note,
      'is_active': isActive,
      'last_executed_key': lastExecutedKey,
    };
  }

  factory RecurringTransaction.fromSupabaseMap(Map<String, dynamic> map) {
    return RecurringTransaction(
      id: map['id'] as String,
      userId: map['user_id'] as String?,
      title: map['title'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      type: map['type'] == 'income' ? TransactionType.income : TransactionType.expense,
      categoryId: map['category_id'] as String?,
      categoryName: map['category_name'] as String?,
      categoryColor: map['category_color'] as String?,
      categoryIcon: map['category_icon'] as String?,
      frequency: RecurringFrequency.fromString(map['frequency'] as String?),
      dayOfMonth: map['day_of_month'] as int? ?? 1,
      dayOfWeek: map['day_of_week'] as int? ?? 1,
      monthOfYear: map['month_of_year'] as int? ?? 1,
      note: map['note'] as String?,
      isActive: map['is_active'] as bool? ?? true,
      lastExecutedKey: (map['last_executed_key'] ?? map['last_executed_month']) as String?,
    );
  }

  /// Map dữ liệu tương thích SharedPreferences lưu cục bộ
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'amount': amount,
      'type': type == TransactionType.income ? 'income' : 'expense',
      'categoryId': categoryId,
      'categoryName': categoryName,
      'categoryColor': categoryColor,
      'categoryIcon': categoryIcon,
      'frequency': frequency.toDbString(),
      'dayOfMonth': dayOfMonth,
      'dayOfWeek': dayOfWeek,
      'monthOfYear': monthOfYear,
      'note': note,
      'isActive': isActive,
      'lastExecutedKey': lastExecutedKey,
    };
  }

  factory RecurringTransaction.fromMap(Map<String, dynamic> map) {
    return RecurringTransaction(
      id: map['id'] as String,
      userId: map['user_id'] as String?,
      title: map['title'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      type: map['type'] == 'income' ? TransactionType.income : TransactionType.expense,
      categoryId: (map['categoryId'] ?? map['category_id']) as String?,
      categoryName: (map['categoryName'] ?? map['category_name']) as String?,
      categoryColor: (map['categoryColor'] ?? map['category_color']) as String?,
      categoryIcon: (map['categoryIcon'] ?? map['category_icon']) as String?,
      frequency: RecurringFrequency.fromString(map['frequency'] as String?),
      dayOfMonth: (map['dayOfMonth'] ?? map['day_of_month']) as int? ?? 1,
      dayOfWeek: (map['dayOfWeek'] ?? map['day_of_week']) as int? ?? 1,
      monthOfYear: (map['monthOfYear'] ?? map['month_of_year']) as int? ?? 1,
      note: map['note'] as String?,
      isActive: (map['isActive'] ?? map['is_active']) as bool? ?? true,
      lastExecutedKey: (map['lastExecutedKey'] ?? map['lastExecutedMonth'] ?? map['last_executed_key']) as String?,
    );
  }

  String toJson() => json.encode(toMap());

  factory RecurringTransaction.fromJson(String source) =>
      RecurringTransaction.fromMap(json.decode(source) as Map<String, dynamic>);
}
