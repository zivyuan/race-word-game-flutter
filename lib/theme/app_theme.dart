import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF7C3AED);
  static const Color secondaryColor = Color(0xFF2563EB);
  static const Color accentColor = Color(0xFFF59E0B);
  static const Color successColor = Color(0xFF10B981);
  static const Color dangerColor = Color(0xFFEF4444);
  static const Color backgroundColor = Color(0xFFFFFBFE);

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: primaryColor,
      brightness: Brightness.light,
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Color(0xFF1E1B4B),
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: Color(0xFF1E1B4B)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        hintStyle: TextStyle(color: Colors.grey[400]),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),
    );
  }

  // 卡片集颜色列表
  static const List<Color> cardSetColors = [
    Color(0xFF7C3AED), // 紫色
    Color(0xFF2563EB), // 蓝色
    Color(0xFF10B981), // 绿色
    Color(0xFFF59E0B), // 橙色
    Color(0xFFEF4444), // 红色
    Color(0xFFEC4899), // 粉色
    Color(0xFF06B6D4), // 青色
    Color(0xFF8B5CF6), // 靛紫
  ];

  // 掌握等级对应颜色
  static Color masteryColor(String level) {
    switch (level) {
      case 'mastered':
        return successColor;
      case 'learning':
        return accentColor;
      default:
        return Colors.grey;
    }
  }

  static String masteryLabel(String level) {
    switch (level) {
      case 'mastered':
        return '已掌握 ⭐';
      case 'learning':
        return '学习中 📖';
      default:
        return '未学习 🆕';
    }
  }
}
