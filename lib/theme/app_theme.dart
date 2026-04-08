import 'package:flutter/material.dart';

class AppTheme {
  // === 主色调 - 更活泼、更适合儿童 ===
  static const Color primaryColor = Color(0xFF6C5CE7);
  static const Color primaryLight = Color(0xFFA29BFE);
  static const Color primaryDark = Color(0xFF4834D4);
  static const Color secondaryColor = Color(0xFF0984E3);
  static const Color secondaryLight = Color(0xFF74B9FF);
  static const Color accentColor = Color(0xFFFDCB6E);
  static const Color accentDark = Color(0xFFF39C12);
  static const Color successColor = Color(0xFF00B894);
  static const Color dangerColor = Color(0xFFFF6B6B);
  static const Color warningColor = Color(0xFFE17055);
  static const Color infoColor = Color(0xFF74B9FF);
  static const Color backgroundColor = Color(0xFFF8F9FE);
  static const Color surfaceColor = Colors.white;
  static const Color textPrimary = Color(0xFF2D3436);
  static const Color textSecondary = Color(0xFF636E72);
  static const Color textHint = Color(0xFFB2BEC3);

  // === 动画时长 ===
  static const Duration animFast = Duration(milliseconds: 150);
  static const Duration animNormal = Duration(milliseconds: 300);
  static const Duration animSlow = Duration(milliseconds: 500);
  static const Duration animBounce = Duration(milliseconds: 400);

  // === 圆角 ===
  static const double radiusSm = 12.0;
  static const double radiusMd = 16.0;
  static const double radiusLg = 20.0;
  static const double radiusXl = 28.0;
  static const double radiusFull = 100.0;

  // === 间距 ===
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 48.0;

  // === 卡片集颜色列表 - 更鲜艳活泼 ===
  static const List<Color> cardSetColors = [
    Color(0xFF6C5CE7), // 紫色
    Color(0xFF0984E3), // 蓝色
    Color(0xFF00B894), // 绿色
    Color(0xFFFDCB6E), // 金色
    Color(0xFFFF6B6B), // 珊瑚红
    Color(0xFFE84393), // 粉色
    Color(0xFF00CEC9), // 青色
    Color(0xFFA29BFE), // 薰衣草
  ];

  // 卡片集对应的 emoji
  static const List<String> cardSetEmojis = [
    '📚', '🌊', '🌿', '⭐', '🎀', '🌸', '💎', '🦋',
  ];

  // 掌握等级对应颜色
  static Color masteryColor(String level) {
    switch (level) {
      case 'mastered':
        return successColor;
      case 'learning':
        return accentDark;
      default:
        return textHint;
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

  // === 亮色主题 ===
  static ThemeData get lightTheme {
    return _buildTheme(Brightness.light);
  }

  // === 暗色主题 ===
  static ThemeData get darkTheme {
    return _buildTheme(Brightness.dark);
  }

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1A1A2E) : backgroundColor;
    final surface = isDark ? const Color(0xFF16213E) : surfaceColor;
    final textPrimary = isDark ? const Color(0xFFEAEAEA) : AppTheme.textPrimary;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: bgColor,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primaryColor,
        onPrimary: Colors.white,
        secondary: secondaryColor,
        onSecondary: Colors.white,
        surface: surface,
        onSurface: textPrimary,
        error: dangerColor,
        onError: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMd)),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMd)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMd)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusLg)),
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        color: surface,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        hintStyle: TextStyle(color: textHint, fontSize: 16),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        highlightElevation: 8,
        shape: CircleBorder(),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMd)),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusXl)),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  // === 背景渐变 ===
  static const LinearGradient homeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF8F0FE), Color(0xFFF0F4FF), Color(0xFFFFF8E1)],
  );

  static const LinearGradient gameGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6C5CE7), Color(0xFF0984E3)],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00B894), Color(0xFF00CEC9)],
  );

  static LinearGradient warmGradient(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
          : [const Color(0xFFFFF5F5), const Color(0xFFF8F0FE)],
    );
  }
}

// === 通用装饰工具 ===

class AppDecorations {
  static BoxDecoration cardDecoration({
    required BuildContext context,
    Color? color,
    Color? borderColor,
    double radius = AppTheme.radiusLg,
    double blur = 12,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: color ?? (isDark ? const Color(0xFF16213E) : Colors.white),
      borderRadius: BorderRadius.circular(radius),
      border: borderColor != null
          ? Border.all(color: borderColor)
          : isDark
              ? Border.all(color: Colors.white10)
              : Border.all(color: Colors.grey.shade100),
      boxShadow: [
        BoxShadow(
          color: (isDark ? Colors.black : Colors.grey.shade300).withOpacity(0.15),
          blurRadius: blur,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static BoxDecoration gradientCardDecoration({
    required Color color,
    double radius = AppTheme.radiusLg,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [color.withOpacity(0.18), color.withOpacity(0.06)],
      ),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: color.withOpacity(0.25)),
    );
  }

  static BoxDecoration pillDecoration({
    required Color color,
    double radius = AppTheme.radiusFull,
  }) {
    return BoxDecoration(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(radius),
    );
  }
}
