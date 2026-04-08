class UserProfile {
  final String id;
  final String nickname;
  final String avatarUrl;

  UserProfile({
    required this.id,
    required this.nickname,
    required this.avatarUrl,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      nickname: json['nickname'] as String,
      avatarUrl: json['avatarUrl'] as String? ?? '🐶',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nickname': nickname,
    'avatarUrl': avatarUrl,
  };
}

class CardSetInfo {
  final String id;
  final String userId;
  final String name;
  final String createdAt;

  CardSetInfo({
    required this.id,
    required this.userId,
    required this.name,
    required this.createdAt,
  });

  factory CardSetInfo.fromJson(Map<String, dynamic> json) {
    return CardSetInfo(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      createdAt: json['createdAt'] as String? ?? '',
    );
  }
}

class CardItem {
  final String id;
  final String cardSetId;
  final String imageUrl;
  final String word;
  final String createdAt;

  CardItem({
    required this.id,
    required this.cardSetId,
    required this.imageUrl,
    required this.word,
    required this.createdAt,
  });

  factory CardItem.fromJson(Map<String, dynamic> json) {
    return CardItem(
      id: json['id'] as String,
      cardSetId: json['cardSetId'] as String,
      imageUrl: json['imageUrl'] as String,
      word: json['word'] as String,
      createdAt: json['createdAt'] as String? ?? '',
    );
  }
}

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
