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

  final List<String> _weekdays = [
    'Thứ 2',
    'Thứ 3',
    'Thứ 4',
    'Thứ 5',
    'Thứ 6',
    'Thứ 7',
    'Chủ nhật',
  ];

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

  String _formatScheduleText(RecurringTransaction item) {
    switch (item.frequency) {
      case RecurringFrequency.daily:
        return 'Mỗi ngày';
      case RecurringFrequency.weekly:
        final weekdayIndex = (item.dayOfWeek - 1).clamp(0, 6);
        return '${_weekdays[weekdayIndex]} hàng tuần';
      case RecurringFrequency.monthly:
        return 'Ngày ${item.dayOfMonth} hàng tháng';
      case RecurringFrequency.yearly:
        return 'Ngày ${item.dayOfMonth}/${item.monthOfYear} hàng năm';
    }
  }

  void _showAddEditDialog({RecurringTransaction? item}) {
    final titleController = TextEditingController(text: item?.title ?? '');
    final amountController = TextEditingController(
      text: item?.amount != null ? item!.amount.toInt().toString() : '',
    );
    final noteController = TextEditingController(text: item?.note ?? '');

    TransactionType selectedType = item?.type ?? TransactionType.expense;
    RecurringFrequency selectedFrequency = item?.frequency ?? RecurringFrequency.monthly;
    int selectedDayOfMonth = item?.dayOfMonth ?? 1;
    int selectedDayOfWeek = item?.dayOfWeek ?? 1; // 1 = T2 ... 7 = CN
    int selectedMonthOfYear = item?.monthOfYear ?? 1; // 1 -> 12
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
                          item == null ? 'Thêm khoản thu chi cố định' : 'Chỉnh sửa khoản cố định',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Loại thu / chi
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text('Chi tiêu')),
                            selected: selectedType == TransactionType.expense,
                            selectedColor: Colors.deepPurple.shade100,
                            onSelected: (_) => setDialogState(() {
                              selectedType = TransactionType.expense;
                              selectedCategoryId = null;
                            }),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text('Thu nhập')),
                            selected: selectedType == TransactionType.income,
                            selectedColor: Colors.deepPurple.shade100,
                            onSelected: (_) => setDialogState(() {
                              selectedType = TransactionType.income;
                              selectedCategoryId = null;
                            }),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Tên khoản
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Tên khoản cố định *',
                        hintText: 'Ví dụ: Tiền trọ, Tiền điện thoại, Lương...',
                        prefixIcon: const Icon(Icons.title),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Số tiền
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Số tiền *',
                        suffixText: '₫',
                        prefixIcon: const Icon(Icons.attach_money),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Chu kỳ lặp lại
                    const Text('Chu kỳ lặp lại:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: RecurringFrequency.values.map((freq) {
                          final isSelected = selectedFrequency == freq;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ChoiceChip(
                              label: Text(freq.displayName),
                              selected: isSelected,
                              selectedColor: Colors.deepPurple.shade100,
                              onSelected: (_) => setDialogState(() => selectedFrequency = freq),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Tùy chọn chi tiết theo chu kỳ
                    if (selectedFrequency == RecurringFrequency.weekly) ...[
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Colors.deepPurple, size: 20),
                          const SizedBox(width: 8),
                          const Text('Vào ngày:', style: TextStyle(fontWeight: FontWeight.bold)),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.deepPurple.shade50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.deepPurple.shade200),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                value: selectedDayOfWeek,
                                items: List.generate(7, (i) {
                                  return DropdownMenuItem(value: i + 1, child: Text(_weekdays[i]));
                                }),
                                onChanged: (val) {
                                  if (val != null) setDialogState(() => selectedDayOfWeek = val);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                    ] else if (selectedFrequency == RecurringFrequency.monthly) ...[
                      Row(
                        children: [
                          const Icon(Icons.calendar_month, color: Colors.deepPurple, size: 20),
                          const SizedBox(width: 8),
                          const Text('Ngày trong tháng:', style: TextStyle(fontWeight: FontWeight.bold)),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.deepPurple.shade50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.deepPurple.shade200),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                value: selectedDayOfMonth,
                                items: List.generate(31, (index) => index + 1).map((d) {
                                  return DropdownMenuItem(value: d, child: Text('Ngày $d'));
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) setDialogState(() => selectedDayOfMonth = val);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                    ] else if (selectedFrequency == RecurringFrequency.yearly) ...[
                      Row(
                        children: [
                          const Icon(Icons.event, color: Colors.deepPurple, size: 20),
                          const SizedBox(width: 8),
                          const Text('Thời điểm:', style: TextStyle(fontWeight: FontWeight.bold)),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.deepPurple.shade50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.deepPurple.shade200),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                value: selectedMonthOfYear,
                                items: List.generate(12, (i) => i + 1).map((m) {
                                  return DropdownMenuItem(value: m, child: Text('Tháng $m'));
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) setDialogState(() => selectedMonthOfYear = val);
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.deepPurple.shade50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.deepPurple.shade200),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                value: selectedDayOfMonth,
                                items: List.generate(31, (i) => i + 1).map((d) {
                                  return DropdownMenuItem(value: d, child: Text('Ngày $d'));
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) setDialogState(() => selectedDayOfMonth = val);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue, size: 20),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Tự động kiểm tra và ghi nhận mỗi ngày khi bạn mở ứng dụng.',
                                style: TextStyle(color: Colors.blue, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

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
                    const SizedBox(height: 14),

                    // Ghi chú (tùy chọn)
                    TextField(
                      controller: noteController,
                      decoration: InputDecoration(
                        labelText: 'Ghi chú (tùy chọn)',
                        hintText: 'Thêm ghi chú nếu cần...',
                        prefixIcon: const Icon(Icons.note_alt_outlined),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Nút Lưu
                    SizedBox(
                      width: double.infinity,
                      height: 52,
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
                            userId: item?.userId,
                            title: title,
                            amount: amount,
                            type: selectedType,
                            categoryId: cat?.id,
                            categoryName: cat?.name,
                            categoryColor: cat != null
                                ? '#${cat.color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}'
                                : null,
                            categoryIcon: cat?.icon,
                            frequency: selectedFrequency,
                            dayOfMonth: selectedDayOfMonth,
                            dayOfWeek: selectedDayOfWeek,
                            monthOfYear: selectedMonthOfYear,
                            note: noteController.text.trim().isEmpty ? null : noteController.text.trim(),
                            isActive: item?.isActive ?? true,
                            lastExecutedKey: item?.lastExecutedKey,
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
                          item == null ? 'LƯU KHOẢN CỐ ĐỊNH' : 'CẬP NHẬT THÔNG TIN',
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
                    child: Row(
                      children: [
                        const Icon(Icons.sync_rounded, color: Colors.deepPurple, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Tự động đồng bộ & ghi nhận',
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 14),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Các khoản cố định sẽ tự động lưu lên tài khoản Supabase và tự động tạo giao dịch khi tới hạn.',
                                style: TextStyle(color: Colors.grey.shade700, fontSize: 12, height: 1.3),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Danh sách
                Expanded(
                  child: _recurringList.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.repeat_rounded, size: 64, color: Colors.grey.shade300),
                              const SizedBox(height: 12),
                              Text(
                                'Chưa có khoản thu chi cố định nào',
                                style: TextStyle(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Bấm nút (+) bên dưới để tạo khoản cố định',
                                style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(18),
                                  onTap: () => _showAddEditDialog(item: item),
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
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      item.title,
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 15,
                                                        color: item.isActive ? Colors.black87 : Colors.grey,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Wrap(
                                                spacing: 6,
                                                runSpacing: 4,
                                                crossAxisAlignment: WrapCrossAlignment.center,
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: Colors.deepPurple.shade50,
                                                      borderRadius: BorderRadius.circular(6),
                                                    ),
                                                    child: Text(
                                                      _formatScheduleText(item),
                                                      style: const TextStyle(
                                                        fontSize: 11,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.deepPurple,
                                                      ),
                                                    ),
                                                  ),
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
                                              if (item.note != null && item.note!.isNotEmpty) ...[
                                                const SizedBox(height: 4),
                                                Text(
                                                  item.note!,
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.grey.shade600,
                                                    fontStyle: FontStyle.italic,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          tooltip: 'Sửa thông tin',
                                          icon: const Icon(Icons.edit_outlined, color: Colors.deepPurple, size: 20),
                                          onPressed: () => _showAddEditDialog(item: item),
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
                                          tooltip: 'Xóa',
                                          icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                          onPressed: () async {
                                            final confirm = await showDialog<bool>(
                                              context: context,
                                              builder: (ctx) => AlertDialog(
                                                title: const Text('Xác nhận xóa'),
                                                content: Text('Bạn có chắc chắn muốn xóa khoản "${item.title}" không?'),
                                                actions: [
                                                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('HỦY')),
                                                  ElevatedButton(
                                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                                                    onPressed: () => Navigator.pop(ctx, true),
                                                    child: const Text('XÓA'),
                                                  ),
                                                ],
                                              ),
                                            );
                                            if (confirm == true) {
                                              await _dataSource.deleteRecurringTransaction(item.id);
                                              _loadData();
                                            }
                                          },
                                        ),
                                      ],
                                    ),
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
