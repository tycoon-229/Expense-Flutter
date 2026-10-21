import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class ExpenseEmptyView extends StatelessWidget {
  final bool isFiltered;
  final VoidCallback? onResetFilters;
  final VoidCallback? onAddExpense;

  const ExpenseEmptyView({
    super.key,
    this.isFiltered = false,
    this.onResetFilters,
    this.onAddExpense,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FadeIn(
        duration: const Duration(milliseconds: 400),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isFiltered ? Icons.filter_alt_off : Icons.receipt_long,
                  size: 64,
                  color: Colors.deepPurple.shade300,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                isFiltered
                    ? 'Không tìm thấy giao dịch nào'
                    : 'Chưa có giao dịch nào',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                isFiltered
                    ? 'Hãy thử điều chỉnh lại bộ lọc hoặc từ khóa tìm kiếm'
                    : 'Bắt đầu ghi chép các khoản thu chi đầu tiên của bạn',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              if (isFiltered && onResetFilters != null)
                OutlinedButton.icon(
                  onPressed: onResetFilters,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Đặt lại bộ lọc'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.deepPurple,
                    side: const BorderSide(color: Colors.deepPurple),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                )
              else if (onAddExpense != null)
                ElevatedButton.icon(
                  onPressed: onAddExpense,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Thêm giao dịch ngay'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
