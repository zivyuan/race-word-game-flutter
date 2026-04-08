import 'package:flutter_test/flutter_test.dart';
import 'package:race_word_game/theme/app_theme.dart';

void main() {
  group('AppTheme', () {
    test('primary color is defined', () {
      expect(AppTheme.primaryColor, const Color(0xFF7C3AED));
    });

    test('secondary color is defined', () {
      expect(AppTheme.secondaryColor, const Color(0xFF2563EB));
    });

    test('accent color is defined', () {
      expect(AppTheme.accentColor, const Color(0xFFF59E0B));
    });

    test('success color is defined', () {
      expect(AppTheme.successColor, const Color(0xFF10B981));
    });

    test('danger color is defined', () {
      expect(AppTheme.dangerColor, const Color(0xFFEF4444));
    });

    test('cardSetColors has 8 entries', () {
      expect(AppTheme.cardSetColors.length, 8);
    });

    test('cardSetColors all have alpha 0xFF (fully opaque)', () {
      for (final color in AppTheme.cardSetColors) {
        expect(color.alpha, 0xFF);
      }
    });

    test('theme is Material3', () {
      expect(AppTheme.theme.useMaterial3, true);
    });

    test('theme has light brightness', () {
      expect(AppTheme.theme.brightness, Brightness.light);
    });
  });

  group('masteryColor', () {
    test('returns successColor for mastered', () {
      expect(AppTheme.masteryColor('mastered'), AppTheme.successColor);
    });

    test('returns accentColor for learning', () {
      expect(AppTheme.masteryColor('learning'), AppTheme.accentColor);
    });

    test('returns grey for new', () {
      expect(AppTheme.masteryColor('new'), Colors.grey);
    });

    test('returns grey for unknown level', () {
      expect(AppTheme.masteryColor('unknown'), Colors.grey);
    });
  });

  group('masteryLabel', () {
    test('returns correct label for mastered', () {
      expect(AppTheme.masteryLabel('mastered'), '已掌握 ⭐');
    });

    test('returns correct label for learning', () {
      expect(AppTheme.masteryLabel('learning'), '学习中 📖');
    });

    test('returns correct label for new', () {
      expect(AppTheme.masteryLabel('new'), '未学习 🆕');
    });
  });
}
