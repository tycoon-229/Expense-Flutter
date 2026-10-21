import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/utils/category_icon_helper.dart';
import '../../domain/entities/expense.dart';

class ExpenseItemCard extends StatelessWidget {
  final Expense expense;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const ExpenseItemCard({
    super.key,
    required this.expense,
    required this.index,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = expense.type == TransactionType.income;
    final categoryName = expense.categoryName ?? 'Chưa phân loại';
    final categoryColor = _parseColor(expense.categoryColor);
    final categoryIcon = CategoryIconHelper.getIcon(
      expense.categoryIcon,
      fallback: _getLegacyFallbackIcon(categoryName),
    );

    final currencyFormat = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    );

    return FadeInUp(
      duration: const Duration(milliseconds: 350),
      delay: Duration(milliseconds: (index * 40).clamp(0, 400)),
      child: Dismissible(
        key: Key(expense.id),
        direction: DismissDirection.endToStart,
        confirmDismiss: (direction) async {
          return await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Xác nhận xóa'),
              content: Text('Bạn có chắc chắn muốn xóa giao dịch "${expense.title}" không?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('HỦY'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('XÓA'),
                ),
              ],
            ),
          );
        },
        onDismissed: (_) => onDelete(),
        background: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.red.shade400,
            borderRadius: BorderRadius.circular(18),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.delete_outline, color: Colors.white, size: 26),
              SizedBox(width: 8),
              Text(
                'Xóa',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Row(
                  children: [
                    // Avatar Icon có huy hiệu thu/chi
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: categoryColor.withValues(alpha: 0.15),
                          child: Icon(
                            categoryIcon,
                            color: categoryColor,
                            size: 24,
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: isIncome ? Colors.green : Colors.red,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: Icon(
                              isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                              color: Colors.white,
                              size: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 14),

                    // Tiêu đề & Danh mục + Ngày
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            expense.title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: categoryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  categoryName,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: categoryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '•  ${DateFormat('dd/MM/yyyy').format(expense.date)}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Số tiền
                    Text(
                      '${isIncome ? '+' : '-'} ${currencyFormat.format(expense.amount)}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isIncome ? Colors.green.shade700 : Colors.red.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _parseColor(String? hexString) {
    if (hexString == null || hexString.isEmpty) return Colors.blueGrey;
    try {
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return Colors.blueGrey;
    }
  }

  IconData _getLegacyFallbackIcon(String category) {
    switch (category.toLowerCase()) {
      case 'đồ ăn':
        return Icons.restaurant;
      case 'đi lại':
        return Icons.directions_bus;
      case 'mua sắm':
        return Icons.shopping_bag;
      case 'hóa đơn':
        return Icons.receipt_long;
      case 'lương':
        return Icons.payments;
      case 'quà tặng':
        return Icons.card_giftcard;
      default:
        return Icons.category;
    }
  }
}
