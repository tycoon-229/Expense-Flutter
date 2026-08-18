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
  late TransactionType _selectedType;
  final List<String> _categories = ['Đồ ăn', 'Đi lại', 'Mua sắm', 'Hóa đơn', 'Lương', 'Quà tặng', 'Khác'];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.expense?.title);
    _amountController = TextEditingController(text: widget.expense?.amount.toString());
    _selectedCategory = widget.expense?.category ?? 'Đồ ăn';
    _selectedType = widget.expense?.type ?? TransactionType.expense;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Color get _primaryColor => _selectedType == TransactionType.expense ? Colors.red : Colors.green;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(widget.expense == null 
          ? (_selectedType == TransactionType.expense ? 'Thêm chi tiêu' : 'Thêm thu nhập')
          : 'Chỉnh sửa'),
        centerTitle: true,
        backgroundColor: _primaryColor,
        elevation: 0,
        titleTextStyle: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: _primaryColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              padding: const EdgeInsets.only(bottom: 30, left: 16, right: 16),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildTypeButton(TransactionType.expense, 'Khoản chi', Icons.arrow_downward),
                        _buildTypeButton(TransactionType.income, 'Khoản thu', Icons.arrow_upward),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  _buildTextField(
                    controller: _titleController,
                    label: 'Tên giao dịch',
                    icon: Icons.title,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _amountController,
                    label: 'Số tiền',
                    icon: Icons.attach_money,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (val) => setState(() => _selectedCategory = val!),
                    decoration: InputDecoration(
                      labelText: 'Danh mục',
                      prefixIcon: Icon(Icons.category, color: _primaryColor),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: _primaryColor, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 5,
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
                            type: _selectedType,
                          );
                          Navigator.pop(context, expense);
                        }
                      },
                      child: Text(
                        widget.expense == null ? 'THÊM MỚI' : 'CẬP NHẬT',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeButton(TransactionType type, String label, IconData icon) {
    bool isSelected = _selectedType == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? _primaryColor : Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? _primaryColor : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: _primaryColor),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: _primaryColor, width: 2),
        ),
      ),
    );
  }
}
