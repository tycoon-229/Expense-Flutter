import 'package:flutter/material.dart';

class CategoryIconHelper {
  // Bộ sưu tập các icon phân loại theo ngữ cảnh chi tiêu và thu nhập
  static const Map<String, IconData> icons = {
    // 🍔 Ăn uống
    'restaurant': Icons.restaurant,
    'fastfood': Icons.fastfood,
    'local_cafe': Icons.local_cafe,
    'local_bar': Icons.local_bar,

    // 🛍️ Mua sắm
    'shopping_bag': Icons.shopping_bag,
    'shopping_cart': Icons.shopping_cart,
    'checkroom': Icons.checkroom,

    // 🚗 Đi lại
    'two_wheeler': Icons.two_wheeler,
    'directions_car': Icons.directions_car,
    'directions_bus': Icons.directions_bus,
    'local_gas_station': Icons.local_gas_station,
    'flight': Icons.flight,

    // 🏠 Nhà cửa & Hóa đơn
    'home': Icons.home,
    'receipt_long': Icons.receipt_long,
    'electric_bolt': Icons.electric_bolt,
    'water_drop': Icons.water_drop,
    'wifi': Icons.wifi,

    // 💊 Sức khỏe & Thể thao
    'medical_services': Icons.medical_services,
    'local_pharmacy': Icons.local_pharmacy,
    'fitness_center': Icons.fitness_center,
    'sports_soccer': Icons.sports_soccer,

    // 🎓 Giáo dục & Giải trí
    'school': Icons.school,
    'book': Icons.book,
    'movie': Icons.movie,
    'videogame_asset': Icons.videogame_asset,
    'pets': Icons.pets,
    'card_giftcard': Icons.card_giftcard,

    // 💰 Thu nhập & Tài chính
    'payments': Icons.payments,
    'savings': Icons.savings,
    'work': Icons.work,
    'account_balance': Icons.account_balance,
    'trending_up': Icons.trending_up,
    'monetization_on': Icons.monetization_on,

    // 🏷️ Khác
    'category': Icons.category,
  };

  /// Lấy IconData từ iconKey. Nếu không tìm thấy, trả về fallback icon.
  static IconData getIcon(String? iconKey, {IconData fallback = Icons.category}) {
    if (iconKey == null || iconKey.isEmpty) {
      return fallback;
    }
    return icons[iconKey] ?? fallback;
  }
}
