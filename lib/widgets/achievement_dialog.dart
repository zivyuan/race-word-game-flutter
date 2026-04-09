import 'package:flutter/material.dart';
import 'package:race_word_game/models/achievement_models.dart';
import 'package:race_word_game/services/api_service.dart';

class AchievementUnlockDialog extends StatefulWidget {
  final AchievementModel achievement;
  final VoidCallback? onClose;

  const AchievementUnlockDialog({
    super.key,
    required this.achievement,
    this.onClose,
  });

  @override
  State<AchievementUnlockDialog> createState() =>
      AchievementUnlockDialogState();

  static void showAchievementUnlock(
    BuildContext context,
    AchievementModel achievement,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AchievementUnlockDialog(
        achievement: achievement,
        onClose: () {},
      ),
    );
  }

  static Future<void> checkAndShowAchievements(
    BuildContext context,
    String userId,
    Map<String, dynamic> gameData,
  ) async {
    try {
      final achievements = await ApiService.getUserAchievements(userId);
      final allAchievements = await ApiService.getAchievements();

      final newAchievements = <AchievementModel>[];

      for (final achievement in allAchievements) {
        final isUnlocked = achievements.any(
          (ua) => ua.achievementId == achievement.id,
        );
        if (!isUnlocked && _checkAchievementCondition(achievement, gameData)) {
          newAchievements.add(achievement);
        }
      }

      for (final achievement in newAchievements) {
        await Future.delayed(const Duration(milliseconds: 500));
        if (context.mounted) {
          showAchievementUnlock(context, achievement);
          await ApiService.unlockAchievement(
            userId,
            achievement.id,
            progress: gameData,
          );
        }
      }
    } catch (e) {
      debugPrint('检查成就失败: $e');
    }
  }

  static bool _checkAchievementCondition(
    AchievementModel achievement,
    Map<String, dynamic> gameData,
  ) {
    final requirement = achievement.requirement;
    final type = requirement['type'];

    switch (type) {
      case 'perfect_score':
        final accuracy = gameData['accuracy'] ?? 0;
        final requiredAccuracy = (requirement['accuracy'] ?? 100) / 100;
        return accuracy >= requiredAccuracy;
      case 'max_combo':
        final maxCombo = gameData['maxCombo'] ?? 0;
        final requiredCombo = requirement['count'] ?? 10;
        return maxCombo >= requiredCombo;
      case 'complete_game':
        return gameData['completed'] ?? false;
      default:
        return false;
    }
  }
}

class AchievementUnlockDialogState extends State<AchievementUnlockDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.elasticOut),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.zero,
      child: ListenableBuilder(
        listenable: _controller,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: Transform.translate(
              offset: Offset(0.0, _slideAnimation.value),
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: _buildAchievementContent(context),
              ),
            ),
          );
        },
      ),
    );
  }


  Widget _buildAchievementContent(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLarge = size.width > 600;

    return Container(
      width: size.width * 0.9,
      constraints: BoxConstraints(
        maxWidth: isLarge ? 400 : 300,
        maxHeight: isLarge ? 500 : 400,
      ),
      child: Stack(
        children: [
          // 背景渐变
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors:
                    _getAchievementGradient(widget.achievement.difficulty),
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
          ),
          // 内容
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 成就图标
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      widget.achievement.icon,
                      style: const TextStyle(fontSize: 40),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // 成就标题
                Text(
                  widget.achievement.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isLarge ? 24 : 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 4,
                        offset: const Offset(1, 1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // 成就描述
                Text(
                  widget.achievement.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isLarge ? 16 : 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 16),
                // 难度标签
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color:
                        _getAchievementColor(widget.achievement.difficulty),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getDifficultyText(widget.achievement.difficulty),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // 确认按钮
                GestureDetector(
                  onTap: () {
                    widget.onClose?.call();
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '太棒了！',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _getAchievementGradient(String difficulty) {
    switch (difficulty) {
      case 'bronze':
        return [const Color(0xFFCD7F32), const Color(0xFFE4A853)];
      case 'silver':
        return [const Color(0xFFC0C0C0), const Color(0xFFE8E8E8)];
      case 'gold':
        return [const Color(0xFFFFD700), const Color(0xFFFFF700)];
      case 'diamond':
        return [const Color(0xFFB9F2FF), const Color(0xFFE0F7FF)];
      default:
        return [Colors.blue, Colors.lightBlue];
    }
  }

  Color _getAchievementColor(String difficulty) {
    switch (difficulty) {
      case 'bronze':
        return const Color(0xFFCD7F32);
      case 'silver':
        return const Color(0xFFC0C0C0);
      case 'gold':
        return const Color(0xFFFFD700);
      case 'diamond':
        return const Color(0xFFB9F2FF);
      default:
        return Colors.blue;
    }
  }

  String _getDifficultyText(String difficulty) {
    switch (difficulty) {
      case 'bronze':
        return '青铜';
      case 'silver':
        return '白银';
      case 'gold':
        return '黄金';
      case 'diamond':
        return '钻石';
      default:
        return '普通';
    }
  }
}
