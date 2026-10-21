import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/utils/category_icon_helper.dart';
import '../../../category/domain/repositories/category_repository.dart';
import '../../../category/data/models/category_model.dart';
import '../../../expense/domain/entities/expense.dart';
import '../../data/datasources/recurring_local_data_source.dart';
import '../../domain/entities/recurring_transaction.dart';

class RecurringTransactionsPage extends StatefulWidget {
  const RecurringTransactionsPage({super.key});

  @override
  State<RecurringTransactionsPage> createState() => _RecurringTransactionsPageState();
}

class _RecurringTransactionsPageState extends State<RecurringTransactionsPage> {
  final RecurringLocalDataSource _dataSource = RecurringLocalDataSource();
  final CategoryRepository _categoryRepository = getIt<CategoryRepository>();

  List<RecurringTransaction> _recurringList = [];
  List<CategoryModel> _categories = [];
  bool _isLoading = true;

  final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final list = await _dataSource.getRecurringTransactions();
    final categories = await _categoryRepository.getCategories();
    if (mounted) {
      setState(() {
        _recurringList = list;
        _categories = categories;
        _isLoading = false;
      });
    }
  }

  void _showAddEditDialog({RecurringTransaction? item}) {
    final titleController = TextEditingController(text: item?.title ?? '');
    final amountController = TextEditingController(
      text: item?.amount != null ? item!.amount.toInt().toString() : '',
    );
    TransactionType selectedType = item?.type ?? TransactionType.expense;
    int selectedDay = item?.dayOfMonth ?? 5;
    String? selectedCategoryId = item?.categoryId ?? (_categories.isNotEmpty ? _categories.first.id : null);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final filteredCategories = _categories.where((c) {
              return c.type == (selectedType == TransactionType.income ? 'income' : 'expense');
            }).toList();

            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item == null ? 'Thêm khoản thu chi cố định' : 'Sửa khoản cố định',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Loại thu / chi
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text('Chi tiêu cố định')),
                            selected: selectedType == TransactionType.expense,
                            onSelected: (_) => setDialogState(() {
                              selectedType = TransactionType.expense;
                              selectedCategoryId = null;
                            }),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text('Thu nhập cố định')),
                            selected: selectedType == TransactionType.income,
                            onSelected: (_) => setDialogState(() {
                              selectedType = TransactionType.income;
                              selectedCategoryId = null;
                            }),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Tên khoản
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Tên khoản cố định',
                        hintText: 'Ví dụ: Tiền trọ, Tiền mạng, Tiền ăn cố định...',
                        prefixIcon: const Icon(Icons.title),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Số tiền
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Số tiền cố định',
                        suffixText: '₫',
                        prefixIcon: const Icon(Icons.attach_money),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Ngày ghi nhận trong tháng (1 - 31)
                    Row(
                      children: [
                        const Icon(Icons.calendar_month, color: Colors.deepPurple, size: 20),
                        const SizedBox(width: 8),
                        const Text('Ngày tự động ghi nhận:', style: TextStyle(fontWeight: FontWeight.bold)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.deepPurple.shade200),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: selectedDay,
                              items: List.generate(31, (index) => index + 1).map((d) {
                                return DropdownMenuItem(value: d, child: Text('Ngày $d'));
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) setDialogState(() => selectedDay = val);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Danh mục
                    const Text('Danh mục:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 8),
                    if (filteredCategories.isNotEmpty)
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: filteredCategories.map((c) {
                            final isSelected = c.id == selectedCategoryId;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ChoiceChip(
                                avatar: CircleAvatar(
                                  backgroundColor: c.color,
                                  radius: 10,
                                  child: Icon(CategoryIconHelper.getIcon(c.icon), size: 10, color: Colors.white),
                                ),
                                label: Text(c.name),
                                selected: isSelected,
                                onSelected: (_) => setDialogState(() => selectedCategoryId = c.id),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    const SizedBox(height: 24),

                    // Nút Lưu
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () async {
                          final title = titleController.text.trim();
                          final amount = double.tryParse(amountController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

                          if (title.isEmpty || amount <= 0) return;

                          CategoryModel? cat;
                          if (selectedCategoryId != null && filteredCategories.any((c) => c.id == selectedCategoryId)) {
                            cat = filteredCategories.firstWhere((c) => c.id == selectedCategoryId);
                          }

                          final newItem = RecurringTransaction(
                            id: item?.id ?? const Uuid().v4(),
                            title: title,
                            amount: amount,
                            type: selectedType,
                            categoryId: cat?.id,
                            categoryName: cat?.name,
                            categoryColor: cat != null ? '#${cat.color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}' : null,
                            categoryIcon: cat?.icon,
                            dayOfMonth: selectedDay,
                            isActive: item?.isActive ?? true,
                            lastExecutedMonth: item?.lastExecutedMonth,
                          );

                          if (item == null) {
                            await _dataSource.addRecurringTransaction(newItem);
                          } else {
                            await _dataSource.updateRecurringTransaction(newItem);
                          }

                          if (ctx.mounted) {
                            Navigator.pop(ctx);
                          }
                          _loadData();
                        },
                        child: Text(
                          item == null ? 'LƯU KHOẢN CỐ ĐỊNH' : 'CẬP NHẬT',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text('Khoản thu chi cố định', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Banner giải thích
                FadeInDown(
                  duration: const Duration(milliseconds: 400),
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.deepPurple.shade100),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.auto_awesome, color: Colors.deepPurple, size: 24),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Hệ thống sẽ tự động ghi nhận các khoản thu/chi này vào sổ giao dịch đúng vào ngày bạn cài đặt hàng tháng.',
                            style: TextStyle(fontSize: 12, color: Colors.deepPurple, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Danh sách các khoản cố định
                Expanded(
                  child: _recurringList.isEmpty
                      ? Center(
                          child: FadeIn(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.repeat_rounded, size: 64, color: Colors.grey.shade400),
                                const SizedBox(height: 16),
                                Text(
                                  'Chưa có khoản thu chi cố định nào',
                                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Ví dụ: Tiền phòng trọ, Lương cứng, Tiền mạng...',
                                  style: TextStyle(color: Colors.grey, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _recurringList.length,
                          itemBuilder: (context, index) {
                            final item = _recurringList[index];
                            final isExpense = item.type == TransactionType.expense;

                            return FadeInUp(
                              duration: const Duration(milliseconds: 300),
                              delay: Duration(milliseconds: (index * 40).clamp(0, 300)),
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.03),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 22,
                                        backgroundColor: isExpense ? Colors.red.shade50 : Colors.green.shade50,
                                        child: Icon(
                                          CategoryIconHelper.getIcon(item.categoryIcon),
                                          color: isExpense ? Colors.red : Colors.green,
                                          size: 22,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.title,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                                color: item.isActive ? Colors.black87 : Colors.grey,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: Colors.deepPurple.shade50,
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: Text(
                                                    'Ngày ${item.dayOfMonth} hàng tháng',
                                                    style: const TextStyle(
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.deepPurple,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  currencyFormat.format(item.amount),
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13,
                                                    color: isExpense ? Colors.red.shade700 : Colors.green.shade700,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Switch(
                                        value: item.isActive,
                                        activeThumbColor: Colors.deepPurple,
                                        onChanged: (val) async {
                                          final updated = item.copyWith(isActive: val);
                                          await _dataSource.updateRecurringTransaction(updated);
                                          _loadData();
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                        onPressed: () async {
                                          await _dataSource.deleteRecurringTransaction(item.id);
                                          _loadData();
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
