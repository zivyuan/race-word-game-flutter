export 'achievement_models.dart';

// =============================================
// 卡片分类枚举
// =============================================
enum CardCategory {
  animals,
  food,
  colors,
  body,
  travel,
  general;

  String get label {
    switch (this) {
      case CardCategory.animals: return '🐾 动物';
      case CardCategory.food:    return '🍎 食物';
      case CardCategory.colors:  return '🎨 颜色';
      case CardCategory.body:    return '🧍 身体';
      case CardCategory.travel:  return '✈️ 旅行';
      case CardCategory.general: return '📚 综合';
    }
  }

  static CardCategory fromString(String value) {
    return CardCategory.values.firstWhere(
      (e) => e.name == value,
      orElse: () => CardCategory.general,
    );
  }
}

// =============================================
// 用户模型 (对齐 Cook API: /api/auth, /api/users)
// 对外保持 String id 兼容 screens，内部处理 int↔String 转换
// =============================================
class UserProfile {
  final String id;
  final String username;
  final String nickname;
  final String avatarUrl;
  final int totalGames;
  final int wins;
  final int bestTime;
  final String createdAt;

  UserProfile({
    required this.id,
    this.username = '',
    this.nickname = '',
    this.avatarUrl = '',
    this.totalGames = 0,
    this.wins = 0,
    this.bestTime = 0,
    this.createdAt = '',
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'].toString(),
      username: json['username'] as String? ?? '',
      nickname: json['nickname'] as String? ?? '',
      avatarUrl: json['avatar'] as String? ?? json['avatarUrl'] as String? ?? '',
      totalGames: json['total_games'] as int? ?? 0,
      wins: json['wins'] as int? ?? 0,
      bestTime: json['best_time'] as int? ?? 0,
      createdAt: json['created_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'nickname': nickname,
    'avatar': avatarUrl,
    'total_games': totalGames,
    'wins': wins,
    'best_time': bestTime,
    'created_at': createdAt,
  };

  /// Cook API 的 int id
  int get idInt => int.tryParse(id) ?? 0;
}

// =============================================
// 卡片列表项 (GET /api/cards 返回的简要视图)
// 兼容旧 CardSetInfo: name → title, userId → ownerId
// =============================================
class CardListItem {
  final String id;
  final String title;
  final String description;
  final CardCategory category;
  final int difficulty;
  final int wordCount;
  final String userId;     // 兼容旧字段，值来自 ownerId
  final String? nickname;
  final String createdAt;

  CardListItem({
    required this.id,
    this.title = '',
    this.description = '',
    this.category = CardCategory.general,
    this.difficulty = 1,
    this.wordCount = 0,
    this.userId = '',
    this.nickname,
    this.createdAt = '',
  });

  factory CardListItem.fromJson(Map<String, dynamic> json) {
    return CardListItem(
      id: json['id'].toString(),
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: CardCategory.fromString(json['category'] as String? ?? 'general'),
      difficulty: json['difficulty'] as int? ?? 1,
      wordCount: json['word_count'] as int? ?? 0,
      userId: json['owner_id']?.toString() ?? json['userId']?.toString() ?? '',
      nickname: json['nickname'] as String?,
      createdAt: json['created_at'] as String? ?? '',
    );
  }

  /// 兼容旧 CardSetInfo.name
  String get name => title;
  /// Cook API 的 int id
  int get idInt => int.tryParse(id) ?? 0;
}

/// 兼容旧代码的类型别名
typedef CardSetInfo = CardListItem;

// =============================================
// 卡片详情 (GET /api/cards/{id} 返回完整视图，含 words)
// =============================================
class CardDetail {
  final String id;
  final String title;
  final String description;
  final CardCategory category;
  final int difficulty;
  final bool isPublic;
  final int wordCount;
  final String userId;     // 兼容旧字段，值来自 ownerId
  final List<String> words;
  final String createdAt;
  final String updatedAt;

  CardDetail({
    required this.id,
    this.title = '',
    this.description = '',
    this.category = CardCategory.general,
    this.difficulty = 1,
    this.isPublic = true,
    this.wordCount = 0,
    this.userId = '',
    this.words = const [],
    this.createdAt = '',
    this.updatedAt = '',
  });

  factory CardDetail.fromJson(Map<String, dynamic> json) {
    return CardDetail(
      id: json['id'].toString(),
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: CardCategory.fromString(json['category'] as String? ?? 'general'),
      difficulty: json['difficulty'] as int? ?? 1,
      isPublic: json['is_public'] as bool? ?? true,
      wordCount: json['word_count'] as int? ?? 0,
      userId: json['owner_id']?.toString() ?? '',
      words: (json['words'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
    );
  }

  /// 转为 CardListItem 用于列表展示
  CardListItem toListItem() => CardListItem(
    id: id,
    title: title,
    description: description,
    category: category,
    difficulty: difficulty,
    wordCount: wordCount,
    userId: userId,
    createdAt: createdAt,
  );

  /// 兼容旧 CardSetInfo.name
  String get name => title;
  int get idInt => int.tryParse(id) ?? 0;
}

// =============================================
// CardItem — 单个词汇卡片 (本地使用)
// =============================================
class CardItem {
  final String id;
  final String cardSetId;
  final String imageUrl;
  final String word;
  final String createdAt;

  CardItem({
    required this.id,
    this.cardSetId = '',
    this.imageUrl = '',
    required this.word,
    this.createdAt = '',
  });

  factory CardItem.fromJson(Map<String, dynamic> json) {
    return CardItem(
      id: json['id']?.toString() ?? '',
      cardSetId: json['cardSetId']?.toString() ?? json['card_set_id']?.toString() ?? '',
      imageUrl: json['imageUrl'] as String? ?? json['image_url'] as String? ?? '',
      word: json['word'] as String,
      createdAt: json['createdAt'] as String? ?? json['created_at'] as String? ?? '',
    );
  }
}

// =============================================
// 游戏记录 (本地计算)
// =============================================
class GameRecordInfo {
  final CardItem card;
  final int timesShown;
  final int timesKnown;
  final String? lastPlayedAt;
  final String masteryLevel; // 'new', 'learning', 'mastered'

  GameRecordInfo({
    required this.card,
    required this.timesShown,
    required this.timesKnown,
    this.lastPlayedAt,
    required this.masteryLevel,
  });

  factory GameRecordInfo.fromJson(Map<String, dynamic> json) {
    return GameRecordInfo(
      card: CardItem.fromJson(json['card'] as Map<String, dynamic>),
      timesShown: json['timesShown'] as int? ?? 0,
      timesKnown: json['timesKnown'] as int? ?? 0,
      lastPlayedAt: json['lastPlayedAt'] as String?,
      masteryLevel: json['masteryLevel'] as String? ?? 'new',
    );
  }
}
