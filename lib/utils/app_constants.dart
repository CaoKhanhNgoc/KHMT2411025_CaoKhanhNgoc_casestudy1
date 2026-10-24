import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color primaryBlueLight = Color(0xFFEFF6FF);
  static const Color darkText = Color(0xFF1E293B);
  static const Color grayText = Color(0xFF64748B);
  static const Color lightGray = Color(0xFFF1F5F9);
  static const Color borderColor = Color(0xFFE2E8F0);
  
  static const Color expenseRed = Color(0xFFEF4444);
  static const Color expenseLightRed = Color(0xFFFDEBED);
  
  static const Color incomeGreen = Color(0xFF22C55E);
  static const Color incomeLightGreen = Color(0xFFEAF8ED);

  // Category Colors
  static const Color catFood = Color(0xFFFF5252);
  static const Color catShopping = Color(0xFF38BDF8);
  static const Color catSalary = Color(0xFF22C55E);
  static const Color catTransport = Color(0xFF8B5CF6);
  static const Color catEducation = Color(0xFF9333EA);
  static const Color catOther = Color(0xFFA855F7);
}

class CategoryHelper {
  static IconData getIcon(String category) {
    switch (category) {
      case 'Ăn uống':
        return Icons.restaurant;
      case 'Mua sắm':
        return Icons.shopping_cart;
      case 'Lương':
        return Icons.business_center;
      case 'Đi lại':
        return Icons.directions_car;
      case 'Học tập':
        return Icons.menu_book;
      default:
        return Icons.category;
    }
  }

  static Color getColor(String category) {
    switch (category) {
      case 'Ăn uống':
        return AppColors.catFood;
      case 'Mua sắm':
        return AppColors.catShopping;
      case 'Lương':
        return AppColors.catSalary;
      case 'Đi lại':
        return AppColors.catTransport;
      case 'Học tập':
        return AppColors.catEducation;
      default:
        return AppColors.catOther;
    }
  }

  static String formatCurrency(double amount) {
    final String formatted = amount.abs().toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return '$formatted đ';
  }
}
