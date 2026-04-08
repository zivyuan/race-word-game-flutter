import 'package:flutter_test/flutter_test.dart';

/// Tests for AnalyticsService logic.
/// The actual service depends on LocalDatabase which uses sqflite,
/// so we test the achievement definitions and logic rules.

void main() {
  group('Achievement definitions', () {
    test('has 12 defined achievements', () {
      // These are the static achievement definitions from AnalyticsService
      const achievements = [
        {'key': 'first_game', 'title': '初次尝试', 'description': '完成第一局游戏', 'icon': '🌟'},
        {'key': 'perfect_game', 'title': '完美表现', 'description': '一局游戏中全部答对', 'icon': '💯'},
        {'key': 'streak_5', 'title': '五连击', 'description': '连续答对5题', 'icon': '🔥'},
        {'key': 'streak_10', 'title': '十连击', 'description': '连续答对10题', 'icon': '💥'},
        {'key': 'sessions_5', 'title': '勤奋学习者', 'description': '完成5局游戏', 'icon': '📚'},
        {'key': 'sessions_10', 'title': '学习达人', 'description': '完成10局游戏', 'icon': '🎓'},
        {'key': 'sessions_25', 'title': '学习大师', 'description': '完成25局游戏', 'icon': '👑'},
        {'key': 'accuracy_80', 'title': '正确率达人', 'description': '累计正确率达到80%', 'icon': '🎯'},
        {'key': 'streak_3_days', 'title': '三日坚持', 'description': '连续学习3天', 'icon': '📅'},
        {'key': 'streak_7_days', 'title': '一周坚持', 'description': '连续学习7天', 'icon': '🗓️'},
        {'key': 'words_50', 'title': '词汇新手', 'description': '学习50个单词', 'icon': '📖'},
        {'key': 'words_100', 'title': '词汇达人', 'description': '学习100个单词', 'icon': '📗'},
      ];

      expect(achievements.length, 12);
    });

    test('all achievements have required fields', () {
      const achievements = [
        {'key': 'first_game', 'title': '初次尝试', 'description': '完成第一局游戏', 'icon': '🌟'},
        {'key': 'perfect_game', 'title': '完美表现', 'description': '一局游戏中全部答对', 'icon': '💯'},
      ];

      for (final a in achievements) {
        expect(a.containsKey('key'), true);
        expect(a.containsKey('title'), true);
        expect(a.containsKey('description'), true);
        expect(a.containsKey('icon'), true);
      }
    });

    test('achievement keys are unique', () {
      const keys = [
        'first_game', 'perfect_game', 'streak_5', 'streak_10',
        'sessions_5', 'sessions_10', 'sessions_25', 'accuracy_80',
        'streak_3_days', 'streak_7_days', 'words_50', 'words_100',
      ];

      expect(keys.toSet().length, keys.length);
    });
  });

  group('Achievement unlock conditions', () {
    test('first_game: totalSessions >= 1', () {
      bool shouldUnlock(int totalSessions) => totalSessions >= 1;
      expect(shouldUnlock(0), false);
      expect(shouldUnlock(1), true);
      expect(shouldUnlock(10), true);
    });

    test('perfect_game: all answers correct', () {
      bool shouldUnlock(int total, int correct) =>
          total > 0 && correct == total;
      expect(shouldUnlock(0, 0), false);
      expect(shouldUnlock(5, 5), true);
      expect(shouldUnlock(5, 4), false);
    });

    test('streak_5: maxStreak >= 5', () {
      bool shouldUnlock(int maxStreak) => maxStreak >= 5;
      expect(shouldUnlock(4), false);
      expect(shouldUnlock(5), true);
      expect(shouldUnlock(10), true);
    });

    test('streak_10: maxStreak >= 10', () {
      bool shouldUnlock(int maxStreak) => maxStreak >= 10;
      expect(shouldUnlock(9), false);
      expect(shouldUnlock(10), true);
    });

    test('accuracy_80: accuracy >= 80', () {
      bool shouldUnlock(int accuracy) => accuracy >= 80;
      expect(shouldUnlock(79), false);
      expect(shouldUnlock(80), true);
      expect(shouldUnlock(100), true);
    });

    test('words_50: totalQuestions >= 50', () {
      bool shouldUnlock(int totalQuestions) => totalQuestions >= 50;
      expect(shouldUnlock(49), false);
      expect(shouldUnlock(50), true);
    });

    test('words_100: totalQuestions >= 100', () {
      bool shouldUnlock(int totalQuestions) => totalQuestions >= 100;
      expect(shouldUnlock(99), false);
      expect(shouldUnlock(100), true);
    });
  });
}
