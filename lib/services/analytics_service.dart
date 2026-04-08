import 'dart:async';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/local_database.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._();
  factory AnalyticsService() => _instance;
  AnalyticsService._();

  final _statsController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get onStatsChanged => _statsController.stream;

  // Record a completed study session
  Future<void> recordSession({
    required String userId,
    required String cardSetId,
    required int totalQuestions,
    required int correctAnswers,
    required int maxStreak,
    required int durationSeconds,
  }) async {
    await LocalDatabase.saveStudySession(
      userId: userId,
      cardSetId: cardSetId,
      totalQuestions: totalQuestions,
      correctAnswers: correctAnswers,
      maxStreak: maxStreak,
      durationSeconds: durationSeconds,
    );

    // Check achievements after recording
    await _checkAchievements(
      userId: userId,
      totalQuestions: totalQuestions,
      correctAnswers: correctAnswers,
      maxStreak: maxStreak,
    );

    // Notify listeners
    final stats = await getLearningStats(userId);
    _statsController.add(stats);
  }

  Future<Map<String, dynamic>> getLearningStats(String userId) async {
    return LocalDatabase.getLearningStats(userId);
  }

  Future<List<Map<String, dynamic>>> getWeeklyStats(String userId) async {
    return LocalDatabase.getWeeklyStats(userId);
  }

  Future<List<Map<String, dynamic>>> getAllAchievements(String userId) async {
    return LocalDatabase.getAllAchievements(userId);
  }

  // === Achievement Definitions ===
  static const _achievements = [
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

  Future<void> _checkAchievements({
    required String userId,
    required int totalQuestions,
    required int correctAnswers,
    required int maxStreak,
  }) async {
    final stats = await LocalDatabase.getLearningStats(userId);

    // First game
    if (stats['totalSessions'] >= 1) {
      await LocalDatabase.unlockAchievement(
        userId: userId,
        key: 'first_game',
        title: '初次尝试',
        description: '完成第一局游戏',
        icon: '🌟',
      );
    }

    // Perfect game
    if (totalQuestions > 0 && correctAnswers == totalQuestions) {
      await LocalDatabase.unlockAchievement(
        userId: userId,
        key: 'perfect_game',
        title: '完美表现',
        description: '一局游戏中全部答对',
        icon: '💯',
      );
    }

    // Streak achievements
    if (maxStreak >= 5) {
      await LocalDatabase.unlockAchievement(
        userId: userId,
        key: 'streak_5',
        title: '五连击',
        description: '连续答对5题',
        icon: '🔥',
      );
    }
    if (maxStreak >= 10) {
      await LocalDatabase.unlockAchievement(
        userId: userId,
        key: 'streak_10',
        title: '十连击',
        description: '连续答对10题',
        icon: '💥',
      );
    }

    // Session count
    if (stats['totalSessions'] >= 5) {
      await LocalDatabase.unlockAchievement(
        userId: userId,
        key: 'sessions_5',
        title: '勤奋学习者',
        description: '完成5局游戏',
        icon: '📚',
      );
    }
    if (stats['totalSessions'] >= 10) {
      await LocalDatabase.unlockAchievement(
        userId: userId,
        key: 'sessions_10',
        title: '学习达人',
        description: '完成10局游戏',
        icon: '🎓',
      );
    }
    if (stats['totalSessions'] >= 25) {
      await LocalDatabase.unlockAchievement(
        userId: userId,
        key: 'sessions_25',
        title: '学习大师',
        description: '完成25局游戏',
        icon: '👑',
      );
    }

    // Accuracy
    if (stats['accuracy'] >= 80) {
      await LocalDatabase.unlockAchievement(
        userId: userId,
        key: 'accuracy_80',
        title: '正确率达人',
        description: '累计正确率达到80%',
        icon: '🎯',
      );
    }

    // Streak days
    if (stats['streakDays'] >= 3) {
      await LocalDatabase.unlockAchievement(
        userId: userId,
        key: 'streak_3_days',
        title: '三日坚持',
        description: '连续学习3天',
        icon: '📅',
      );
    }
    if (stats['streakDays'] >= 7) {
      await LocalDatabase.unlockAchievement(
        userId: userId,
        key: 'streak_7_days',
        title: '一周坚持',
        description: '连续学习7天',
        icon: '🗓️',
      );
    }

    // Words learned
    if (stats['totalQuestions'] >= 50) {
      await LocalDatabase.unlockAchievement(
        userId: userId,
        key: 'words_50',
        title: '词汇新手',
        description: '学习50个单词',
        icon: '📖',
      );
    }
    if (stats['totalQuestions'] >= 100) {
      await LocalDatabase.unlockAchievement(
        userId: userId,
        key: 'words_100',
        title: '词汇达人',
        description: '学习100个单词',
        icon: '📗',
      );
    }
  }

  void dispose() {
    _statsController.close();
  }
}
