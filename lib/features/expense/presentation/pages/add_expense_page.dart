import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/expense.dart';

class AddExpensePage extends StatefulWidget {
  final Expense? expense;
  const AddExpensePage({super.key, this.expense});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
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
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: Text(widget.expense == null ? 'Thêm chi tiêu' : 'Chỉnh sửa chi tiêu'),
        centerTitle: true,
        backgroundColor: Colors.red,
        titleTextStyle: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.red, Colors.black],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter
            )
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                style: TextStyle(
                  color: Colors.white
                ),
                decoration: const InputDecoration(
                  labelText: 'Tên chi tiêu',
                  labelStyle: TextStyle(
                    color: Colors.white,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white,
                      width: 3.0,
                    )
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.white,
                        width: 4.0,
                      )
                  )
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _amountController,
                style: TextStyle(
                    color: Colors.white
                ),
                decoration: const InputDecoration(
                  labelText: 'Số tiền',
                  labelStyle: TextStyle(
                    color: Colors.white,
                  ),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.white,
                        width: 3.0,
                      )
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.white,
                        width: 4.0,
                      )
                  )
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) => setState(() => _selectedCategory = val!),
                dropdownColor: Colors.red,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold
                ),
                decoration: const InputDecoration(
                  labelText: 'Loại',
                  floatingLabelStyle: TextStyle(
                    color: Colors.white
                  ),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.white,
                        width: 3.0,
                      )
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.white,
                        width: 4.0,
                      )
                  )
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
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
                  child: Text(
                    widget.expense == null ? 'Thêm' : 'Lưu',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
