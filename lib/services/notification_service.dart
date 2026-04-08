import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;
import '../services/local_database.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Shanghai'));

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
    _initialized = true;
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - could navigate to specific screen
  }

  // === Study Reminders ===
  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
    String title = '该学习啦！📚',
    String body = '今天还有单词没学哦，来挑战一下吧！',
  }) async {
    await _plugin.zonedSchedule(
      0,
      title,
      body,
      _nextOccurrence(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'study_reminder',
          '学习提醒',
          channelDescription: '每日学习提醒通知',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  tz.TZDateTime _nextOccurrence(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  Future<void> cancelDailyReminder() async {
    await _plugin.cancel(0);
  }

  // === Achievement Notifications ===
  Future<void> showAchievementNotification({
    required String title,
    required String description,
    String? icon,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'achievements',
      '成就通知',
      channelDescription: '学习成就解锁通知',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );
    const iosDetails = DarwinNotificationDetails(presentSound: true);
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      '🏆 $title',
      description,
      details,
    );
  }

  // === Streak Reminder ===
  Future<void> showStreakWarning() async {
    const androidDetails = AndroidNotificationDetails(
      'streak',
      '连续学习提醒',
      channelDescription: '保持学习连续性的提醒',
      importance: Importance.defaultImportance,
      priority: Priority.defaultImportance,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000 + 1,
      '🔥 保持连续学习！',
      '你已经连续学习了好几天，今天不要断了哦！',
      details,
    );
  }

  // === Weekly Summary ===
  Future<void> showWeeklySummary({
    required int sessionsCount,
    required int wordsLearned,
    required int accuracy,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'weekly',
      '每周总结',
      channelDescription: '每周学习总结报告',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000 + 2,
      '📊 本周学习报告',
      '本周学习了 $sessionsCount 次，认识了 $wordsLearned 个单词，正确率 $accuracy%',
      details,
    );
  }

  // === Check and fire pending achievement notifications ===
  Future<void> checkPendingAchievements(String userId) async {
    final achievements = await LocalDatabase.getUnnotifiedAchievements(userId);
    for (final a in achievements) {
      await showAchievementNotification(
        title: a['title'] as String,
        description: a['description'] as String,
        icon: a['icon'] as String?,
      );
      await LocalDatabase.markAchievementNotified(a['id'] as int);
    }
  }
}
