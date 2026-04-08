import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class ShareService {
  /// Share game results to social media
  static Future<void> shareGameResult({
    required String cardSetName,
    required int score,
    required int total,
    required int maxStreak,
    required int accuracy,
    String? userName,
  }) async {
    final text = '''
$userName 在「单词竞速卡片」中挑战「$cardSetName」！

🎯 答对: $score / $total
📊 正确率: $accuracy%
🔥 最高连击: $maxStreak

来和我一起学单词吧！ 🚀
#单词竞速卡片 #英语学习 #儿童教育
'''.trim();

    await Share.share(
      text,
      subject: '我的单词竞速成绩 - $accuracy%',
    );
  }

  /// Share an achievement unlock
  static Future<void> shareAchievement({
    required String title,
    required String description,
    required String icon,
    String? userName,
  }) async {
    final text = '''
$icon $userName 解锁了成就「$title」！

$description

来和我一起学单词，解锁更多成就吧！ 🏆
#单词竞速卡片 #学习成就
'''.trim();

    await Share.share(
      text,
      subject: '解锁成就 - $title',
    );
  }

  /// Share weekly learning summary
  static Future<void> shareWeeklySummary({
    required int sessionsCount,
    required int wordsLearned,
    required int accuracy,
    required int streakDays,
    String? userName,
  }) async {
    final text = '''
📚 $userName 的本周学习报告

🎯 学习次数: $sessionsCount 次
📖 学习单词: $wordsLearned 个
📊 正确率: $accuracy%
🔥 连续学习: $streakDays 天

继续加油，成为单词小达人！💪
#单词竞速卡片 #每周总结
'''.trim();

    await Share.share(
      text,
      subject: '我的本周学习报告',
    );
  }

  /// Share a specific word card (AR-style)
  static Future<void> shareWordCard({
    required String word,
    required String cardSetName,
    String? userName,
  }) async {
    final text = '''
我正在用「单词竞速卡片」学习 $word！

来自卡片集「$cardSetName」
快来一起学习吧！ ✨
#单词竞速卡片 #英语单词
'''.trim();

    await Share.share(
      text,
      subject: '学习单词 - $word',
    );
  }

  /// Generate a shareable image (using canvas)
  static Future<void> shareWithImage({
    required BuildContext context,
    required String title,
    required List<String> stats,
  }) async {
    // Share as text for now; image generation can be added with RepaintBoundary
    final statsText = stats.map((s) => '  $s').join('\n');
    final text = '$title\n\n$statsText\n\n#单词竞速卡片 #英语学习';

    await Share.share(text, subject: title);
  }
}
