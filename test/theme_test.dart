import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:race_word_game/theme/app_theme.dart';

void main() {
  group('AppTheme', () {
    test('primary color is defined', () {
      expect(AppTheme.primaryColor, const Color(0xFF6C5CE7));
    });

    test('secondary color is defined', () {
      expect(AppTheme.secondaryColor, const Color(0xFF0984E3));
    });

    test('accent color is defined', () {
      expect(AppTheme.accentColor, const Color(0xFFFDCB6E));
    });

    test('success color is defined', () {
      expect(AppTheme.successColor, const Color(0xFF00B894));
    });

    test('danger color is defined', () {
      expect(AppTheme.dangerColor, const Color(0xFFFF6B6B));
    });

    test('cardSetColors has 8 entries', () {
      expect(AppTheme.cardSetColors.length, 8);
    });

    test('cardSetColors all have alpha 0xFF (fully opaque)', () {
      for (final color in AppTheme.cardSetColors) {
        expect(color.alpha, 0xFF);
      }
    });

    test('light theme is Material3', () {
      expect(AppTheme.lightTheme.useMaterial3, true);
    });

    test('light theme has light brightness', () {
      expect(AppTheme.lightTheme.brightness, Brightness.light);
    });

    test('dark theme has dark brightness', () {
      expect(AppTheme.darkTheme.brightness, Brightness.dark);
    });
  });

  group('masteryColor', () {
    test('returns successColor for mastered', () {
      expect(AppTheme.masteryColor('mastered'), AppTheme.successColor);
    });

    test('returns accentDark for learning', () {
      expect(AppTheme.masteryColor('learning'), AppTheme.accentDark);
    });

    test('returns textHint for new', () {
      expect(AppTheme.masteryColor('new'), AppTheme.textHint);
    });

    test('returns textHint for unknown level', () {
      expect(AppTheme.masteryColor('unknown'), AppTheme.textHint);
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
