import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String name;
  final Color color;
  final String type;
  final String icon;
  final double? monthlyBudget;

  CategoryModel({
    required this.id,
    required this.name,
    required this.color,
    required this.type,
    this.icon = 'category',
    this.monthlyBudget,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      color: _colorFromHex(json['color'] as String? ?? '#4CAF50'),
      type: json['type'] as String,
      icon: json['icon'] as String? ?? 'category',
      monthlyBudget: json['monthly_budget'] != null
          ? (json['monthly_budget'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': _colorToHex(color),
      'type': type,
      'icon': icon,
      'monthly_budget': monthlyBudget,
    };
  }

  // Chuyển Hex string (#FF0000) sang Flutter Color
  static Color _colorFromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  // Chuyển Flutter Color sang Hex string (#FF0000)
  static String _colorToHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }
}