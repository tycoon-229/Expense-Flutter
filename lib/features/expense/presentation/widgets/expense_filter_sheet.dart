import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/expense.dart';

class ExpenseFilterSheet extends StatefulWidget {
  final TransactionType? initialFilterType;
  final DateTime? initialSelectedMonth;
  final String? initialSelectedCategory;
  final List<String> availableCategories;
  final Function({
    TransactionType? filterType,
    DateTime? selectedMonth,
    String? selectedCategory,
  }) onApplyFilters;

  const ExpenseFilterSheet({
    super.key,
    required this.initialFilterType,
    required this.initialSelectedMonth,
    required this.initialSelectedCategory,
    required this.availableCategories,
    required this.onApplyFilters,
  });

  @override
  State<ExpenseFilterSheet> createState() => _ExpenseFilterSheetState();
}

class _ExpenseFilterSheetState extends State<ExpenseFilterSheet> {
  late TransactionType? _filterType;
  late DateTime? _selectedMonth;
  late String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _filterType = widget.initialFilterType;
    _selectedMonth = widget.initialSelectedMonth;
    _selectedCategory = widget.initialSelectedCategory;
  }

  void _reset() {
    setState(() {
      _filterType = null;
      _selectedMonth = null;
      _selectedCategory = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Bộ lọc giao dịch',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: _reset,
                child: const Text('Đặt lại', style: TextStyle(color: Colors.deepPurple)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Loại giao dịch
          const Text('Loại giao dịch:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 8),
          Row(
            children: [
              ChoiceChip(
                label: const Text('Tất cả'),
                selected: _filterType == null,
                onSelected: (_) => setState(() => _filterType = null),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Thu nhập'),
                selected: _filterType == TransactionType.income,
                onSelected: (_) => setState(() => _filterType = TransactionType.income),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Chi tiêu'),
                selected: _filterType == TransactionType.expense,
                onSelected: (_) => setState(() => _filterType = TransactionType.expense),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Thời gian
          const Text('Thời gian:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.calendar_month, size: 18),
                  label: Text(
                    _selectedMonth == null
                        ? 'Tất cả các tháng'
                        : 'Tháng ${DateFormat('MM/yyyy').format(_selectedMonth!)}',
                  ),
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedMonth ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                      helpText: 'Chọn tháng/năm',
                    );
                    if (date != null) {
                      setState(() => _selectedMonth = date);
                    }
                  },
                ),
              ),
              if (_selectedMonth != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: () => setState(() => _selectedMonth = null),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),

          // Danh mục
          if (widget.availableCategories.isNotEmpty) ...[
            const Text('Danh mục:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ChoiceChip(
                    label: const Text('Tất cả'),
                    selected: _selectedCategory == null,
                    onSelected: (_) => setState(() => _selectedCategory = null),
                  ),
                  const SizedBox(width: 8),
                  ...widget.availableCategories.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(cat),
                        selected: isSelected,
                        onSelected: (_) => setState(() {
                          _selectedCategory = isSelected ? null : cat;
                        }),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () {
                widget.onApplyFilters(
                  filterType: _filterType,
                  selectedMonth: _selectedMonth,
                  selectedCategory: _selectedCategory,
                );
                Navigator.pop(context);
              },
              child: const Text('ÁP DỤNG BỘ LỌC', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
