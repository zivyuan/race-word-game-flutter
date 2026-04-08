import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/models.dart';

class LocalDatabase {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'race_word_game.db'),
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        nickname TEXT NOT NULL,
        avatar_url TEXT NOT NULL,
        created_at TEXT DEFAULT (datetime('now'))
      )
    ''');

    await db.execute('''
      CREATE TABLE card_sets (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        name TEXT NOT NULL,
        color_index INTEGER DEFAULT 0,
        created_at TEXT,
        synced INTEGER DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE cards (
        id TEXT PRIMARY KEY,
        card_set_id TEXT NOT NULL,
        word TEXT NOT NULL,
        image_url TEXT,
        local_image_path TEXT,
        created_at TEXT,
        synced INTEGER DEFAULT 0,
        FOREIGN KEY (card_set_id) REFERENCES card_sets(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE game_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        card_id TEXT NOT NULL,
        card_set_id TEXT NOT NULL,
        user_id TEXT NOT NULL,
        correct INTEGER DEFAULT 0,
        played_at TEXT DEFAULT (datetime('now')),
        synced INTEGER DEFAULT 0,
        FOREIGN KEY (card_id) REFERENCES cards(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE study_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        card_set_id TEXT NOT NULL,
        total_questions INTEGER DEFAULT 0,
        correct_answers INTEGER DEFAULT 0,
        max_streak INTEGER DEFAULT 0,
        duration_seconds INTEGER DEFAULT 0,
        played_at TEXT DEFAULT (datetime('now'))
      )
    ''');

    await db.execute('''
      CREATE TABLE achievements (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        achievement_key TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        icon TEXT NOT NULL,
        unlocked_at TEXT DEFAULT (datetime('now')),
        notified INTEGER DEFAULT 0,
        UNIQUE(user_id, achievement_key)
      )
    ''');
  }

  static Future<void> _onUpgrade(Database db, int oldV, int newV) async {
    if (oldV < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS study_sessions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id TEXT NOT NULL,
          card_set_id TEXT NOT NULL,
          total_questions INTEGER DEFAULT 0,
          correct_answers INTEGER DEFAULT 0,
          max_streak INTEGER DEFAULT 0,
          duration_seconds INTEGER DEFAULT 0,
          played_at TEXT DEFAULT (datetime('now'))
        )
      ''');
    }
    if (oldV < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS achievements (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id TEXT NOT NULL,
          achievement_key TEXT NOT NULL,
          title TEXT NOT NULL,
          description TEXT NOT NULL,
          icon TEXT NOT NULL,
          unlocked_at TEXT DEFAULT (datetime('now')),
          notified INTEGER DEFAULT 0,
          UNIQUE(user_id, achievement_key)
        )
      ''');
    }
  }

  // === User ===
  static Future<void> saveUser(UserProfile user) async {
    final db = await database;
    await db.insert(
      'users',
      {
        'id': user.id,
        'nickname': user.nickname,
        'avatar_url': user.avatarUrl,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<UserProfile?> getUser(String id) async {
    final db = await database;
    final rows = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return UserProfile(
      id: rows[0]['id'] as String,
      nickname: rows[0]['nickname'] as String,
      avatarUrl: rows[0]['avatar_url'] as String,
    );
  }

  // === Card Sets ===
  static Future<void> saveCardSets(List<CardSetInfo> sets) async {
    final db = await database;
    final batch = db.batch();
    for (final set in sets) {
      batch.insert(
        'card_sets',
        {
          'id': set.id,
          'user_id': set.userId,
          'name': set.name,
          'created_at': set.createdAt,
          'synced': 1,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  static Future<List<CardSetInfo>> getLocalCardSets(String userId) async {
    final db = await database;
    final rows = await db.query(
      'card_sets',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    return rows.map((r) => CardSetInfo(
      id: r['id'] as String,
      userId: r['user_id'] as String,
      name: r['name'] as String,
      createdAt: r['created_at'] as String? ?? '',
    )).toList();
  }

  static Future<void> saveCardSet(CardSetInfo set) async {
    final db = await database;
    await db.insert(
      'card_sets',
      {
        'id': set.id,
        'user_id': set.userId,
        'name': set.name,
        'created_at': set.createdAt,
        'synced': 1,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> deleteLocalCardSet(String id) async {
    final db = await database;
    await db.delete('cards', where: 'card_set_id = ?', whereArgs: [id]);
    await db.delete('card_sets', where: 'id = ?', whereArgs: [id]);
  }

  // === Cards ===
  static Future<void> saveCards(List<CardItem> cards) async {
    final db = await database;
    final batch = db.batch();
    for (final card in cards) {
      batch.insert(
        'cards',
        {
          'id': card.id,
          'card_set_id': card.cardSetId,
          'word': card.word,
          'image_url': card.imageUrl,
          'created_at': card.createdAt,
          'synced': 1,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  static Future<List<CardItem>> getLocalCards(String cardSetId) async {
    final db = await database;
    final rows = await db.query(
      'cards',
      where: 'card_set_id = ?',
      whereArgs: [cardSetId],
    );
    return rows.map((r) => CardItem(
      id: r['id'] as String,
      cardSetId: r['card_set_id'] as String,
      imageUrl: (r['image_url'] as String?) ?? '',
      word: r['word'] as String,
      createdAt: r['created_at'] as String? ?? '',
    )).toList();
  }

  static Future<void> saveCard(CardItem card) async {
    final db = await database;
    await db.insert(
      'cards',
      {
        'id': card.id,
        'card_set_id': card.cardSetId,
        'word': card.word,
        'image_url': card.imageUrl,
        'created_at': card.createdAt,
        'synced': 1,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> deleteLocalCard(String id) async {
    final db = await database;
    await db.delete('cards', where: 'id = ?', whereArgs: [id]);
  }

  // === Game Records ===
  static Future<void> recordGameResult({
    required String cardId,
    required String cardSetId,
    required String userId,
    required bool correct,
  }) async {
    final db = await database;
    await db.insert('game_records', {
      'card_id': cardId,
      'card_set_id': cardSetId,
      'user_id': userId,
      'correct': correct ? 1 : 0,
    });
  }

  static Future<GameRecordInfo?> getCardRecord(String cardId) async {
    final db = await database;
    final rows = await db.query(
      'game_records',
      where: 'card_id = ?',
      whereArgs: [cardId],
    );
    if (rows.isEmpty) return null;

    final cardRows = await db.query('cards', where: 'id = ?', whereArgs: [cardId]);
    if (cardRows.isEmpty) return null;
    final card = CardItem(
      id: cardRows[0]['id'] as String,
      cardSetId: cardRows[0]['card_set_id'] as String,
      imageUrl: (cardRows[0]['image_url'] as String?) ?? '',
      word: cardRows[0]['word'] as String,
      createdAt: cardRows[0]['created_at'] as String? ?? '',
    );

    int timesShown = rows.length;
    int timesKnown = rows.where((r) => (r['correct'] as int) == 1).length;
    double accuracy = timesShown > 0 ? timesKnown / timesShown : 0;
    String masteryLevel = accuracy >= 0.8 ? 'mastered' : timesShown > 0 ? 'learning' : 'new';

    return GameRecordInfo(
      card: card,
      timesShown: timesShown,
      timesKnown: timesKnown,
      lastPlayedAt: rows.last['played_at'] as String?,
      masteryLevel: masteryLevel,
    );
  }

  static Future<List<GameRecordInfo>> getLocalGameStats(String cardSetId) async {
    final db = await database;
    final cards = await db.query('cards', where: 'card_set_id = ?', whereArgs: [cardSetId]);
    final results = <GameRecordInfo>[];
    for (final c in cards) {
      final record = await getCardRecord(c['id'] as String);
      if (record != null) results.add(record);
    }
    return results;
  }

  // === Study Sessions ===
  static Future<int> saveStudySession({
    required String userId,
    required String cardSetId,
    required int totalQuestions,
    required int correctAnswers,
    required int maxStreak,
    required int durationSeconds,
  }) async {
    final db = await database;
    return db.insert('study_sessions', {
      'user_id': userId,
      'card_set_id': cardSetId,
      'total_questions': totalQuestions,
      'correct_answers': correctAnswers,
      'max_streak': maxStreak,
      'duration_seconds': durationSeconds,
    });
  }

  // === Analytics ===
  static Future<Map<String, dynamic>> getLearningStats(String userId) async {
    final db = await database;

    // Total sessions
    final sessionRows = await db.query(
      'study_sessions',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    // Total game records
    final recordRows = await db.query(
      'game_records',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    int totalSessions = sessionRows.length;
    int totalQuestions = recordRows.length;
    int totalCorrect = recordRows.where((r) => (r['correct'] as int) == 1).length;
    int totalMaxStreak = sessionRows.isEmpty
        ? 0
        : sessionRows.map((r) => r['max_streak'] as int? ?? 0).reduce((a, b) => a > b ? a : b);

    // Cards mastered
    final allCards = await db.rawQuery('''
      SELECT c.id FROM cards c
      JOIN card_sets cs ON c.card_set_id = cs.id
      WHERE cs.user_id = ?
    ''', [userId]);

    int mastered = 0;
    int learning = 0;
    for (final c in allCards) {
      final record = await getCardRecord(c['id'] as String);
      if (record != null) {
        if (record.masteryLevel == 'mastered') mastered++;
        else if (record.masteryLevel == 'learning') learning++;
      }
    }

    // Streak days
    final streakDays = await _calculateStreakDays(db, userId);

    // Recent sessions (last 7 days)
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7)).toIso8601String();
    final recentSessions = sessionRows.where((r) =>
      (r['played_at'] as String).compareTo(sevenDaysAgo) >= 0).length;

    // Total study time
    int totalStudyTime = sessionRows.fold(
      0, (sum, r) => sum + ((r['duration_seconds'] as int?) ?? 0));

    return {
      'totalSessions': totalSessions,
      'totalQuestions': totalQuestions,
      'totalCorrect': totalCorrect,
      'accuracy': totalQuestions > 0 ? (totalCorrect / totalQuestions * 100).round() : 0,
      'totalMaxStreak': totalMaxStreak,
      'totalCards': allCards.length,
      'masteredCards': mastered,
      'learningCards': learning,
      'streakDays': streakDays,
      'recentSessions': recentSessions,
      'totalStudyTime': totalStudyTime,
    };
  }

  static Future<int> _calculateStreakDays(Database db, String userId) async {
    final rows = await db.rawQuery('''
      SELECT DISTINCT DATE(played_at) as day FROM study_sessions
      WHERE user_id = ? ORDER BY day DESC
    ''', [userId]);

    if (rows.isEmpty) return 0;

    int streak = 1;
    DateTime checkDate = DateTime.now();
    // If no session today, start from yesterday
    final todayStr = checkDate.toIso8601String().substring(0, 10);
    if (rows[0]['day'] as String != todayStr) {
      checkDate = checkDate.subtract(const Duration(days: 1));
      final yesterdayStr = checkDate.toIso8601String().substring(0, 10);
      if (rows[0]['day'] as String != yesterdayStr) return 0;
    }

    for (int i = 1; i < rows.length; i++) {
      checkDate = checkDate.subtract(const Duration(days: 1));
      final expectedStr = checkDate.toIso8601String().substring(0, 10);
      if (rows[i]['day'] as String == expectedStr) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  static Future<List<Map<String, dynamic>>> getWeeklyStats(String userId) async {
    final db = await database;
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7)).toIso8601String();

    final rows = await db.rawQuery('''
      SELECT DATE(played_at) as day,
             COUNT(*) as sessions,
             SUM(total_questions) as questions,
             SUM(correct_answers) as correct,
             SUM(max_streak) as max_streak,
             SUM(duration_seconds) as duration
      FROM study_sessions
      WHERE user_id = ? AND played_at >= ?
      GROUP BY DATE(played_at)
      ORDER BY day
    ''', [userId, weekAgo]);

    return rows.map((r) => {
      'date': r['day'] as String,
      'sessions': r['sessions'] as int? ?? 0,
      'questions': r['questions'] as int? ?? 0,
      'correct': r['correct'] as int? ?? 0,
      'maxStreak': r['max_streak'] as int? ?? 0,
      'duration': r['duration'] as int? ?? 0,
    }).toList();
  }

  // === Achievements ===
  static Future<List<Map<String, dynamic>>> getUnnotifiedAchievements(String userId) async {
    final db = await database;
    return db.query(
      'achievements',
      where: 'user_id = ? AND notified = 0',
      whereArgs: [userId],
    );
  }

  static Future<void> markAchievementNotified(int id) async {
    final db = await database;
    await db.update('achievements', {'notified': 1}, where: 'id = ?', whereArgs: [id]);
  }

  static Future<bool> unlockAchievement({
    required String userId,
    required String key,
    required String title,
    required String description,
    required String icon,
  }) async {
    final db = await database;
    try {
      await db.insert('achievements', {
        'user_id': userId,
        'achievement_key': key,
        'title': title,
        'description': description,
        'icon': icon,
        'notified': 0,
      });
      return true;
    } catch (_) {
      return false; // Already unlocked
    }
  }

  static Future<List<Map<String, dynamic>>> getAllAchievements(String userId) async {
    final db = await database;
    return db.query(
      'achievements',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'unlocked_at DESC',
    );
  }

  // === Sync ===
  static Future<List<Map<String, dynamic>>> getUnsyncedRecords() async {
    final db = await database;
    final records = await db.query('game_records', where: 'synced = 0');
    return records;
  }

  static Future<void> markRecordsSynced() async {
    final db = await database;
    await db.update('game_records', {'synced': 1}, where: 'synced = 0');
  }

  static Future<bool> hasLocalData(String userId) async {
    final db = await database;
    final sets = await db.query('card_sets', where: 'user_id = ?', whereArgs: [userId]);
    return sets.isNotEmpty;
  }
}
