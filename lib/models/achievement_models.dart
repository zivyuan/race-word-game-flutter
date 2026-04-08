class AchievementModel {
  final String id;
  final String name;
  final String description;
  final String icon;
  final String color;
  final String difficulty;
  final String category;
  final Map<String, dynamic> requirement;

  AchievementModel({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.difficulty,
    required this.category,
    required this.requirement,
  });

  factory AchievementModel.fromJson(Map<String, dynamic> json) {
    return AchievementModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      color: json['color'] as String,
      difficulty: json['difficulty'] as String,
      category: json['category'] as String,
      requirement: json['requirement'] as Map<String, dynamic>,
    );
  }
}

class UserAchievementModel {
  final String id;
  final String userId;
  final String achievementId;
  final String unlockedAt;
  final AchievementModel achievement;

  UserAchievementModel({
    required this.id,
    required this.userId,
    required this.achievementId,
    required this.unlockedAt,
    required this.achievement,
  });

  factory UserAchievementModel.fromJson(Map<String, dynamic> json) {
    return UserAchievementModel(
      id: json['userAchievement']['id'] as String,
      userId: json['userAchievement']['userId'] as String,
      achievementId: json['userAchievement']['achievementId'] as String,
      unlockedAt: json['userAchievement']['unlockedAt'] as String,
      achievement: AchievementModel.fromJson(json['achievement']),
    );
  }
}