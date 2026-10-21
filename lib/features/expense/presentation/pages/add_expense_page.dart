import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/utils/category_icon_helper.dart';
import '../../../category/domain/repositories/category_repository.dart';
import '../../../category/data/models/category_model.dart';
import '../../domain/entities/expense.dart';

class AddExpensePage extends StatefulWidget {
  final Expense? expense;
  final TransactionType? initialType;

  const AddExpensePage({super.key, this.expense, this.initialType});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final _categoryRepository = getIt<CategoryRepository>();
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late DateTime _selectedDate;

  late TransactionType _selectedType;
  String? _selectedCategoryId;
  List<CategoryModel> _categories = [];
  bool _isLoadingCategories = true;

  final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.expense?.title ?? '');
    _amountController = TextEditingController(
      text: widget.expense?.amount != null ? widget.expense!.amount.toInt().toString() : '',
    );
    _selectedType = widget.expense?.type ?? widget.initialType ?? TransactionType.expense;
    _selectedCategoryId = widget.expense?.categoryId;
    _selectedDate = widget.expense?.date ?? DateTime.now();

    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    setState(() => _isLoadingCategories = true);
    try {
      final typeString = _selectedType == TransactionType.income ? 'income' : 'expense';
      final fetchedCategories = await _categoryRepository.getCategories(type: typeString);

      setState(() {
        _categories = fetchedCategories;
        if (_selectedCategoryId != null &&
            !_categories.any((c) => c.id == _selectedCategoryId)) {
          _selectedCategoryId = _categories.isNotEmpty ? _categories.first.id : null;
        } else if (_selectedCategoryId == null && _categories.isNotEmpty) {
          _selectedCategoryId = _categories.first.id;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải danh mục: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingCategories = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _onTypeChanged(TransactionType type) {
    if (_selectedType != type) {
      setState(() {
        _selectedType = type;
        _selectedCategoryId = null;
      });
      _fetchCategories();
    }
  }

  void _addQuickAmount(double amountToAdd) {
    final current = double.tryParse(_amountController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    final updated = current + amountToAdd;
    setState(() {
      _amountController.text = updated.toInt().toString();
    });
  }

  Color get _themeColor => _selectedType == TransactionType.expense
      ? const Color(0xFFFF5252)
      : const Color(0xFF00C853);

  @override
  Widget build(BuildContext context) {
    final isExpense = _selectedType == TransactionType.expense;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: Text(
          widget.expense == null
              ? (isExpense ? 'Thêm khoản chi' : 'Thêm khoản thu')
              : 'Chỉnh sửa giao dịch',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Segmented Switcher [Khoản chi vs Khoản thu]
            FadeInDown(
              duration: const Duration(milliseconds: 350),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _onTypeChanged(TransactionType.expense),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isExpense ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: isExpense
                                ? [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, 2))]
                                : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.arrow_upward, size: 18, color: isExpense ? Colors.red : Colors.grey),
                              const SizedBox(width: 8),
                              Text(
                                'Khoản chi tiêu',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isExpense ? Colors.red.shade700 : Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _onTypeChanged(TransactionType.income),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: !isExpense ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: !isExpense
                                ? [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, 2))]
                                : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.arrow_downward, size: 18, color: !isExpense ? Colors.green : Colors.grey),
                              const SizedBox(width: 8),
                              Text(
                                'Khoản thu nhập',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: !isExpense ? Colors.green.shade700 : Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 2. Khối nhập số tiền to, ấn tượng kiểu Fintech
            FadeInDown(
              duration: const Duration(milliseconds: 400),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isExpense
                        ? [const Color(0xFFFFF0F0), const Color(0xFFFFECEC)]
                        : [const Color(0xFFF0FFF4), const Color(0xFFE8FDF0)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isExpense ? Colors.red.shade100 : Colors.green.shade100,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'SỐ TIỀN GIAO DỊCH (VNĐ)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isExpense ? Colors.red.shade400 : Colors.green.shade600,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: isExpense ? Colors.red.shade800 : Colors.green.shade800,
                      ),
                      decoration: InputDecoration(
                        hintText: '0',
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        border: InputBorder.none,
                        suffixText: '₫',
                        suffixStyle: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isExpense ? Colors.red.shade800 : Colors.green.shade800,
                        ),
                      ),
                      onChanged: (val) => setState(() {}),
                    ),

                    // Quick Chips
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        _buildQuickChip('+50k', 50000),
                        _buildQuickChip('+100k', 100000),
                        _buildQuickChip('+200k', 200000),
                        _buildQuickChip('+500k', 500000),
                        _buildQuickChip('+1Tr', 1000000),
                        _buildQuickChip('+5Tr', 5000000),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 3. Form chi tiết: Tên, Danh mục, Ngày
            FadeInUp(
              duration: const Duration(milliseconds: 450),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tên giao dịch
                    const Text('Tên giao dịch:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: isExpense ? 'Ví dụ: Ăn trưa, Tiền chợ, Xăng xe...' : 'Ví dụ: Lương cứng, Tiền thưởng, Bán hàng...',
                        prefixIcon: const Icon(Icons.edit_note, color: Colors.deepPurple),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Chọn danh mục
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Danh mục:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        if (_isLoadingCategories)
                          const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
                      ],
                    ),
                    const SizedBox(height: 10),

                    if (_categories.isEmpty && !_isLoadingCategories)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.amber.shade200),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline, color: Colors.amber),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Chưa có danh mục nào cho ${isExpense ? 'Chi tiêu' : 'Thu nhập'}.',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _categories.map((c) {
                            final isSelected = c.id == _selectedCategoryId;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedCategoryId = c.id),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.only(right: 10),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected ? c.color.withValues(alpha: 0.15) : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected ? c.color : Colors.grey.shade200,
                                    width: isSelected ? 2 : 1,
                                  ),
                                  boxShadow: isSelected
                                      ? [BoxShadow(color: c.color.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 2))]
                                      : [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4)],
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 12,
                                      backgroundColor: c.color,
                                      child: Icon(
                                        CategoryIconHelper.getIcon(c.icon),
                                        size: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      c.name,
                                      style: TextStyle(
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                        color: isSelected ? Colors.black87 : Colors.grey.shade700,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                    const SizedBox(height: 20),

                    // Ngày giao dịch
                    const Text('Ngày giao dịch:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 8),
                    InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          setState(() => _selectedDate = picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 18, color: Colors.deepPurple),
                                const SizedBox(width: 12),
                                Text(
                                  DateFormat('EEEE, dd/MM/yyyy', 'vi_VN').format(_selectedDate),
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                ),
                              ],
                            ),
                            const Icon(Icons.arrow_drop_down, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 36),

                    // Nút Lưu giao dịch
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _themeColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          elevation: 4,
                        ),
                        onPressed: () {
                          final title = _titleController.text.trim();
                          final amount = double.tryParse(_amountController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0;

                          if (title.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Vui lòng nhập tên giao dịch')),
                            );
                            return;
                          }
                          if (amount <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Vui lòng nhập số tiền hợp lệ')),
                            );
                            return;
                          }
                          if (_selectedCategoryId == null || _categories.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Vui lòng chọn hoặc tạo danh mục')),
                            );
                            return;
                          }

                          final selectedCat = _categories.firstWhere((c) => c.id == _selectedCategoryId);

                          final expense = Expense(
                            id: widget.expense?.id ?? const Uuid().v4(),
                            title: title,
                            amount: amount,
                            date: _selectedDate,
                            categoryId: _selectedCategoryId,
                            categoryName: selectedCat.name,
                            categoryColor: '#${selectedCat.color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}',
                            categoryIcon: selectedCat.icon,
                            type: _selectedType,
                          );

                          Navigator.pop(context, expense);
                        },
                        child: Text(
                          widget.expense == null
                              ? (isExpense ? 'LƯU KHOẢN CHI' : 'LƯU KHOẢN THU')
                              : 'CẬP NHẬT GIAO DỊCH',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickChip(String label, double amount) {
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      backgroundColor: Colors.white,
      side: BorderSide(color: Colors.grey.shade300),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onPressed: () => _addQuickAmount(amount),
    );
  }
}