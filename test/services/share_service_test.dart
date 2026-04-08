import 'package:flutter_test/flutter_test.dart';

/// Tests for ShareService text generation logic.
/// The actual Share.share() call requires platform channels, so we
/// only test the text formatting here.

void main() {
  group('Share text formatting', () {
    group('shareGameResult', () {
      String formatGameResult({
        String? userName,
        required String cardSetName,
        required int score,
        required int total,
        required int maxStreak,
        required int accuracy,
      }) {
        return '''
${userName ?? ''} 在「单词竞速卡片」中挑战「$cardSetName」！

🎯 答对: $score / $total
📊 正确率: $accuracy%
🔥 最高连击: $maxStreak

来和我一起学单词吧！ 🚀
#单词竞速卡片 #英语学习 #儿童教育'''.trim();
      }

      test('formats game result with user name', () {
        final text = formatGameResult(
          userName: '小明',
          cardSetName: '动物单词',
          score: 8,
          total: 10,
          maxStreak: 5,
          accuracy: 80,
        );

        expect(text, contains('小明'));
        expect(text, contains('动物单词'));
        expect(text, contains('8 / 10'));
        expect(text, contains('80%'));
        expect(text, contains('5'));
      });

      test('formats game result without user name', () {
        final text = formatGameResult(
          userName: '',
          cardSetName: '水果',
          score: 5,
          total: 10,
          maxStreak: 2,
          accuracy: 50,
        );

        expect(text, contains('水果'));
        expect(text, contains('5 / 10'));
      });

      test('contains hashtags', () {
        final text = formatGameResult(
          userName: 'Test',
          cardSetName: 'Test',
          score: 10,
          total: 10,
          maxStreak: 10,
          accuracy: 100,
        );

        expect(text, contains('#单词竞速卡片'));
        expect(text, contains('#英语学习'));
        expect(text, contains('#儿童教育'));
      });
    });

    group('shareAchievement', () {
      String formatAchievement({
        String? userName,
        required String title,
        required String description,
        required String icon,
      }) {
        return '''
$icon ${userName ?? ''} 解锁了成就「$title」！

$description

来和我一起学单词，解锁更多成就吧！ 🏆
#单词竞速卡片 #学习成就'''.trim();
      }

      test('formats achievement text', () {
        final text = formatAchievement(
          userName: 'Alice',
          title: '五连击',
          description: '连续答对5题',
          icon: '🔥',
        );

        expect(text, contains('Alice'));
        expect(text, contains('五连击'));
        expect(text, contains('连续答对5题'));
        expect(text, contains('🔥'));
      });

      test('contains achievement hashtags', () {
        final text = formatAchievement(
          userName: 'Test',
          title: 'Test',
          description: 'Test',
          icon: '🌟',
        );

        expect(text, contains('#单词竞速卡片'));
        expect(text, contains('#学习成就'));
      });
    });

    group('shareWeeklySummary', () {
      String formatWeekly({
        String? userName,
        required int sessionsCount,
        required int wordsLearned,
        required int accuracy,
        required int streakDays,
      }) {
        return '''
📚 ${userName ?? ''} 的本周学习报告

🎯 学习次数: $sessionsCount 次
📖 学习单词: $wordsLearned 个
📊 正确率: $accuracy%
🔥 连续学习: $streakDays 天

继续加油，成为单词小达人！💪
#单词竞速卡片 #每周总结'''.trim();
      }

      test('formats weekly summary', () {
        final text = formatWeekly(
          userName: 'Bob',
          sessionsCount: 7,
          wordsLearned: 42,
          accuracy: 85,
          streakDays: 5,
        );

        expect(text, contains('Bob'));
        expect(text, contains('7 次'));
        expect(text, contains('42 个'));
        expect(text, contains('85%'));
        expect(text, contains('5 天'));
      });
    });

    group('shareWordCard', () {
      String formatWordCard({
        String? userName,
        required String word,
        required String cardSetName,
      }) {
        return '''
我正在用「单词竞速卡片」学习 $word！

来自卡片集「$cardSetName」
快来一起学习吧！ ✨
#单词竞速卡片 #英语单词'''.trim();
      }

      test('formats word card share text', () {
        final text = formatWordCard(
          userName: '小明',
          word: 'elephant',
          cardSetName: '动物单词',
        );

        expect(text, contains('elephant'));
        expect(text, contains('动物单词'));
      });
    });
  });
}
