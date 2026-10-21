import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/utils/category_icon_helper.dart';
import '../../../expense/domain/entities/expense.dart';
import '../../../expense/presentation/bloc/expense_bloc.dart';
import '../../../expense/presentation/bloc/expense_state.dart';
import '../../data/models/category_model.dart';
import '../bloc/category_cubit.dart';
import '../bloc/category_state.dart';

class CategoryManagementPage extends StatelessWidget {
  const CategoryManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<CategoryCubit>()..loadCategories(),
      child: const CategoryManagementView(),
    );
  }
}

class CategoryManagementView extends StatefulWidget {
  const CategoryManagementView({super.key});

  @override
  State<CategoryManagementView> createState() => _CategoryManagementViewState();
}

class _CategoryManagementViewState extends State<CategoryManagementView> {
  final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

  // Danh sách các màu gợi ý đẹp mắt cho Fintech
  static const List<Color> _curatedColors = [
    Color(0xFFFF5722), // Deep Orange
    Color(0xFFE91E63), // Pink
    Color(0xFF9C27B0), // Purple
    Color(0xFF673AB7), // Deep Purple
    Color(0xFF3F51B5), // Indigo
    Color(0xFF2196F3), // Blue
    Color(0xFF00BCD4), // Cyan
    Color(0xFF009688), // Teal
    Color(0xFF4CAF50), // Green
    Color(0xFF8BC34A), // Light Green
    Color(0xFFFFC107), // Amber
    Color(0xFF795548), // Brown
  ];

  void _showCategoryDialog({CategoryModel? category}) {
    final nameController = TextEditingController(text: category?.name ?? '');
    final budgetController = TextEditingController(
      text: category?.monthlyBudget != null && category!.monthlyBudget! > 0
          ? category.monthlyBudget!.toInt().toString()
          : '',
    );
    Color selectedColor = category?.color ?? const Color(0xFF673AB7);
    String selectedType = category?.type ?? 'expense';
    String selectedIcon = category?.icon ?? (selectedType == 'income' ? 'payments' : 'restaurant');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            void showIconPicker() {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                  title: const Text('Chọn biểu tượng', style: TextStyle(fontWeight: FontWeight.bold)),
                  content: SizedBox(
                    width: double.maxFinite,
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        alignment: WrapAlignment.center,
                        children: CategoryIconHelper.icons.entries.map((entry) {
                          final isSelected = entry.key == selectedIcon;
                          return InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () {
                              setDialogState(() => selectedIcon = entry.key);
                              Navigator.pop(ctx);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? selectedColor.withValues(alpha: 0.2)
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected ? selectedColor : Colors.grey.shade300,
                                  width: isSelected ? 2.5 : 1,
                                ),
                              ),
                              child: Icon(
                                entry.value,
                                color: isSelected ? selectedColor : Colors.grey.shade700,
                                size: 26,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('ĐÓNG'),
                    ),
                  ],
                ),
              );
            }

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
                    // Thanh kéo nhỏ
                    Center(
                      child: Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Tiêu đề
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          category == null ? 'Thêm Danh mục mới' : 'Chỉnh sửa Danh mục',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(bottomSheetContext),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Preview Icon & Color to nổi bật
                    Center(
                      child: GestureDetector(
                        onTap: showIconPicker,
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              width: 76,
                              height: 76,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: selectedColor,
                                boxShadow: [
                                  BoxShadow(
                                    color: selectedColor.withValues(alpha: 0.45),
                                    blurRadius: 18,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Icon(
                                CategoryIconHelper.getIcon(selectedIcon),
                                color: Colors.white,
                                size: 38,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                              ),
                              child: const Icon(Icons.edit, size: 14, color: Colors.deepPurple),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Center(
                      child: TextButton.icon(
                        onPressed: showIconPicker,
                        icon: const Icon(Icons.grid_view_rounded, size: 16),
                        label: const Text('Bấm để đổi Icon', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Tên danh mục
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Tên danh mục',
                        hintText: 'Ví dụ: Cà phê, Mua sắm, Tiền trọ...',
                        prefixIcon: const Icon(Icons.label_outline),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Loại giao dịch
                    const Text('Phân loại danh mục:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () => setDialogState(() {
                              selectedType = 'expense';
                              if (category == null && selectedIcon == 'payments') {
                                selectedIcon = 'restaurant';
                              }
                            }),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: selectedType == 'expense'
                                    ? Colors.red.shade50
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: selectedType == 'expense' ? Colors.red : Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.arrow_upward,
                                    size: 18,
                                    color: selectedType == 'expense' ? Colors.red : Colors.grey,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Khoản chi',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: selectedType == 'expense' ? Colors.red : Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () => setDialogState(() {
                              selectedType = 'income';
                              if (category == null && selectedIcon == 'restaurant') {
                                selectedIcon = 'payments';
                              }
                            }),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: selectedType == 'income'
                                    ? Colors.green.shade50
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: selectedType == 'income' ? Colors.green : Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.arrow_downward,
                                    size: 18,
                                    color: selectedType == 'income' ? Colors.green : Colors.grey,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Khoản thu',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: selectedType == 'income' ? Colors.green : Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Hạn mức chi tiêu tháng (Chỉ áp dụng cho Chi tiêu)
                    if (selectedType == 'expense') ...[
                      const Row(
                        children: [
                          Icon(Icons.track_changes, size: 18, color: Colors.deepPurple),
                          SizedBox(width: 6),
                          Text(
                            'Hạn mức chi tiêu trong tháng (Tùy chọn):',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: budgetController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Ví dụ: 3000000 (3.000.000 ₫)',
                          suffixText: '₫/tháng',
                          filled: true,
                          fillColor: Colors.deepPurple.shade50.withValues(alpha: 0.3),
                          prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Bảng màu sắc nhanh
                    const Text('Màu sắc hiển thị:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ..._curatedColors.map((c) {
                            final isPicked = selectedColor.toARGB32() == c.toARGB32();
                            return GestureDetector(
                              onTap: () => setDialogState(() => selectedColor = c),
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: c,
                                  shape: BoxShape.circle,
                                  border: isPicked ? Border.all(color: Colors.white, width: 3) : null,
                                  boxShadow: isPicked
                                      ? [BoxShadow(color: c.withValues(alpha: 0.6), blurRadius: 8, spreadRadius: 1)]
                                      : null,
                                ),
                                child: isPicked
                                    ? const Icon(Icons.check, color: Colors.white, size: 18)
                                    : null,
                              ),
                            );
                          }),
                          IconButton(
                            icon: const Icon(Icons.colorize, color: Colors.deepPurple),
                            tooltip: 'Chọn màu tùy chỉnh',
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  title: const Text('Bảng màu đầy đủ'),
                                  content: BlockPicker(
                                    pickerColor: selectedColor,
                                    onColorChanged: (c) {
                                      setDialogState(() => selectedColor = c);
                                      Navigator.pop(ctx);
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
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
                          elevation: 3,
                        ),
                        onPressed: () {
                          final name = nameController.text.trim();
                          if (name.isEmpty) return;

                          final budgetAmount = double.tryParse(budgetController.text.replaceAll(RegExp(r'[^0-9]'), ''));

                          final model = CategoryModel(
                            id: category?.id ?? const Uuid().v4(),
                            name: name,
                            color: selectedColor,
                            type: selectedType,
                            icon: selectedIcon,
                            monthlyBudget: selectedType == 'expense' ? budgetAmount : null,
                          );

                          final cubit = this.context.read<CategoryCubit>();
                          if (category == null) {
                            cubit.addCategory(model);
                          } else {
                            cubit.updateCategory(model);
                          }

                          Navigator.pop(bottomSheetContext);
                        },
                        child: Text(
                          category == null ? 'TẠO DANH MỤC' : 'LƯU THAY ĐỔI',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 0.5),
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
        title: const Text(
          'Quản lý Danh mục & Hạn mức',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        centerTitle: false,
      ),
      body: BlocConsumer<CategoryCubit, CategoryState>(
        listener: (context, state) {
          if (state is CategoryError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Lỗi: ${state.message}'), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, catState) {
          if (catState is CategoryLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (catState is CategoryLoaded) {
            final categories = catState.categories;
            if (categories.isEmpty) {
              return Center(
                child: FadeIn(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.category_outlined, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'Chưa có danh mục nào',
                        style: TextStyle(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      const Text('Bấm nút + bên dưới để tạo danh mục và hạn mức', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              );
            }

            return BlocBuilder<ExpenseBloc, ExpenseState>(
              builder: (context, expenseState) {
                final expenses = expenseState is ExpenseLoaded ? expenseState.expenses : [];
                final now = DateTime.now();

                // Lọc chi tiêu tháng này
                final currentMonthExpenses = expenses.where((e) {
                  return e.type == TransactionType.expense &&
                      e.date.year == now.year &&
                      e.date.month == now.month;
                }).toList();

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final item = categories[index];
                    final isExpense = item.type == 'expense';
                    final budget = item.monthlyBudget;

                    // Tính số tiền đã chi tháng này cho danh mục này
                    final spentThisMonth = currentMonthExpenses
                        .where((e) => e.categoryId == item.id || e.categoryName == item.name)
                        .fold(0.0, (sum, e) => sum + e.amount);

                    final hasBudget = isExpense && budget != null && budget > 0;
                    final progress = hasBudget ? (spentThisMonth / budget).clamp(0.0, 1.0) : 0.0;
                    final isOverBudget = hasBudget && spentThisMonth > budget;
                    final percentage = hasBudget ? (spentThisMonth / budget * 100).toInt() : 0;

                    Color progressColor = Colors.green;
                    if (progress >= 0.9) {
                      progressColor = Colors.red;
                    } else if (progress >= 0.7) {
                      progressColor = Colors.amber.shade700;
                    }

                    return FadeInUp(
                      duration: const Duration(milliseconds: 300),
                      delay: Duration(milliseconds: (index * 30).clamp(0, 300)),
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
                          padding: const EdgeInsets.all(14.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 22,
                                    backgroundColor: item.color,
                                    child: Icon(
                                      CategoryIconHelper.getIcon(item.icon),
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.name,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          isExpense ? 'Khoản chi' : 'Khoản thu',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: isExpense ? Colors.deepOrange : Colors.green,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 20),
                                    onPressed: () => _showCategoryDialog(category: item),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                          title: const Text('Xác nhận xóa'),
                                          content: Text('Bạn có chắc chắn muốn xóa danh mục "${item.name}"?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(ctx, false),
                                              child: const Text('HỦY'),
                                            ),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                                              onPressed: () => Navigator.pop(ctx, true),
                                              child: const Text('XÓA'),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirm == true && context.mounted) {
                                        context.read<CategoryCubit>().deleteCategory(item.id);
                                      }
                                    },
                                  ),
                                ],
                              ),

                              // Phần hiển thị Hạn mức chi tiêu và Thanh tiến trình theo dõi
                              if (isExpense) ...[
                                const SizedBox(height: 10),
                                if (hasBudget) ...[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Đã chi: ${currencyFormat.format(spentThisMonth)} / ${currencyFormat.format(budget)}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: isOverBudget ? Colors.red : Colors.grey.shade700,
                                        ),
                                      ),
                                      Text(
                                        isOverBudget ? 'Vượt $percentage%' : '$percentage%',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: progressColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: LinearProgressIndicator(
                                      value: progress,
                                      minHeight: 8,
                                      backgroundColor: Colors.grey.shade100,
                                      valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                                    ),
                                  ),
                                  if (isOverBudget) ...[
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.warning_amber_rounded, size: 14, color: Colors.red),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Đã vượt quá hạn mức ${currencyFormat.format(spentThisMonth - budget)}',
                                          style: const TextStyle(fontSize: 11, color: Colors.red, fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                  ],
                                ] else ...[
                                  InkWell(
                                    onTap: () => _showCategoryDialog(category: item),
                                    child: Row(
                                      children: [
                                        Icon(Icons.add_circle_outline, size: 14, color: Colors.deepPurple.shade300),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Thiết lập hạn mức chi tiêu tháng',
                                          style: TextStyle(fontSize: 11, color: Colors.deepPurple.shade400, fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategoryDialog(),
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}