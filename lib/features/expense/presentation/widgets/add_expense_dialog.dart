import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/expense.dart';

class AddExpenseDialog extends StatefulWidget {
  final Expense? expense;
  const AddExpenseDialog({super.key, this.expense});

  @override
  State<AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends State<AddExpenseDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late String _selectedCategory;
  final List<String> _categories = ['Đồ ăn', 'Đi lại', 'Mua sắm', 'Hóa đơn', 'Khác'];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.expense?.title);
    _amountController = TextEditingController(text: widget.expense?.amount.toString());
    _selectedCategory = widget.expense?.category ?? 'Đồ ăn';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.expense == null ? 'Thêm chi tiêu' : 'Chỉnh sửa chi tiêu'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Tên chi tiêu'),
          ),
          TextField(
            controller: _amountController,
            decoration: const InputDecoration(labelText: 'Số tiền'),
            keyboardType: TextInputType.number,
          ),
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (val) => setState(() => _selectedCategory = val!),
            decoration: const InputDecoration(labelText: 'Loại'),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Bỏ')),
        ElevatedButton(
          onPressed: () {
            final title = _titleController.text;
            final amount = double.tryParse(_amountController.text) ?? 0.0;
            if (title.isNotEmpty && amount > 0) {
              final expense = Expense(
                id: widget.expense?.id ?? const Uuid().v4(),
                title: title,
                amount: amount,
                date: widget.expense?.date ?? DateTime.now(),
                category: _selectedCategory,
              );
              Navigator.pop(context, expense);
            }
          },
          child: Text(widget.expense == null ? 'Thêm' : 'Lưu'),
        ),
      ],
    );
  }
}
