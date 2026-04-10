import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../models/achievement_models.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfile? _user;
  List<UserAchievementModel> _achievements = [];
  List<CardSetInfo> _cardSets = [];
  bool _loading = true;
  bool _darkMode = false;
  bool _soundEnabled = true;
  int _totalCards = 0;
  int _gameSessions = 0;
  double _accuracy = 0.0;

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _darkMode = prefs.getBool('darkMode') ?? false;
      _soundEnabled = prefs.getBool('soundEnabled') ?? true;
    });
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final nickname = prefs.getString('nickname');
    final avatarUrl = prefs.getString('avatarUrl');

    if (userId == null) return;

    setState(() {
      _user = UserProfile(
        id: userId,
        nickname: nickname ?? '',
        avatarUrl: avatarUrl ?? '🐶',
      );
    });

    try {
      // Load data in parallel
      final results = await Future.wait([
        ApiService.getCardSets(userId),
        ApiService.getUserAchievements(userId).catchError((_) => <UserAchievementModel>[]),
      ]);

      final sets = results[0] as List<CardSetInfo>;
      final achievements = results[1] as List<UserAchievementModel>;

      // Load cards count for each set
      int totalCards = 0;
      for (final set in sets) {
        try {
          final cards = await ApiService.getCards(set.id);
          totalCards += cards.length;
          // Get game stats for accuracy calculation
          try {
            final stats = await ApiService.getGameStats(set.id);
            for (final stat in stats) {
              if (stat.timesShown > 0) {
                _gameSessions++;
                _accuracy += stat.timesKnown / stat.timesShown;
              }
            }
          } catch (_) {}
        } catch (_) {}
      }

      if (mounted) {
        setState(() {
          _cardSets = sets;
          _achievements = achievements;
          _totalCards = totalCards;
          _accuracy = _gameSessions > 0 ? (_accuracy / _gameSessions) * 100 : 0;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _editNickname() async {
    final controller = TextEditingController(text: _user?.nickname ?? '');
    final newNickname = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingXl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.edit_rounded,
                    color: AppTheme.primaryColor,
                    size: 28,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingLg),
                const Text(
                  '修改昵称',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingMd),
                TextField(
                  controller: controller,
                  autofocus: true,
                  decoration: const InputDecoration(hintText: '输入新昵称'),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (v) => Navigator.pop(ctx, v.trim()),
                ),
                const SizedBox(height: AppTheme.spacingLg),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('取消'),
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingMd),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () =>
                            Navigator.pop(ctx, controller.text.trim()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('确定'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (newNickname != null && newNickname.isNotEmpty && _user != null) {
      try {
        final updated = await ApiService.updateUserProfile(
          _user!.id,
          nickname: newNickname,
        );
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('nickname', updated.nickname);
        setState(() {
          _user = updated;
        });
      } catch (e) {
        if (mounted) {
          FriendlyErrorDialog.show(
            context,
            message: '修改昵称失败，请稍后重试',
          );
        }
      }
    }
    controller.dispose();
  }

  Future<void> _logout() async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: '退出登录',
      message: '确定要退出登录吗？你的数据不会丢失。',
      confirmText: '退出',
      isDangerous: true,
      icon: Icons.logout,
    );
    if (confirmed != true) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('nickname');
    await prefs.remove('avatarUrl');
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/onboarding', (_) => false);
    }
  }

  Color _difficultyColor(String difficulty) {
    switch (difficulty) {
      case 'easy':
        return AppTheme.successColor;
      case 'medium':
        return AppTheme.accentDark;
      case 'hard':
        return AppTheme.dangerColor;
      default:
        return AppTheme.textHint;
    }
  }

  String _difficultyLabel(String difficulty) {
    switch (difficulty) {
      case 'easy':
        return '简单';
      case 'medium':
        return '中等';
      case 'hard':
        return '困难';
      default:
        return difficulty;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.textHint.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('个人资料'),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: FunLoadingIndicator(message: '加载中'))
          : Container(
              decoration: BoxDecoration(
                gradient: AppTheme.warmGradient(context),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppTheme.spacingMd),
                child: Column(
                  children: [
                    // Avatar + Name section
                    FadeIn(
                      child: Container(
                        padding: const EdgeInsets.all(AppTheme.spacingXl),
                        decoration: AppDecorations.cardDecoration(
                          context: context,
                          borderColor: AppTheme.primaryColor.withOpacity(0.08),
                          radius: AppTheme.radiusXl,
                        ),
                        child: Column(
                          children: [
                            // Avatar
                            GestureDetector(
                              onTap: _editNickname,
                              child: Stack(
                                children: [
                                  PulseAnimation(
                                    child: Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryColor
                                            .withOpacity(0.08),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppTheme.primaryColor
                                              .withOpacity(0.2),
                                          width: 3,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          _user?.avatarUrl ?? '🐶',
                                          style: const TextStyle(fontSize: 52),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryColor,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Theme.of(context)
                                              .scaffoldBackgroundColor,
                                          width: 2,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.edit_rounded,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppTheme.spacingMd),
                            // Nickname
                            GestureDetector(
                              onTap: _editNickname,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _user?.nickname ?? '',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Icon(
                                    Icons.edit_rounded,
                                    size: 16,
                                    color: AppTheme.textHint,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'ID: ${_user?.id ?? ''}',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppTheme.textHint,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: AppTheme.spacingMd),

                    // Stats cards
                    FadeIn(
                      delay: const Duration(milliseconds: 100),
                      child: Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              icon: '📚',
                              value: '${_cardSets.length}',
                              label: '卡片集',
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _StatCard(
                              icon: '🃏',
                              value: '$_totalCards',
                              label: '总卡片',
                              color: AppTheme.secondaryColor,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _StatCard(
                              icon: '🎮',
                              value: '$_gameSessions',
                              label: '游戏次数',
                              color: AppTheme.accentDark,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),
                    FadeIn(
                      delay: const Duration(milliseconds: 150),
                      child: _StatCard(
                        icon: '🎯',
                        value: '${_accuracy.toStringAsFixed(0)}%',
                        label: '正确率',
                        color: AppTheme.successColor,
                        fullWidth: true,
                      ),
                    ),

                    const SizedBox(height: AppTheme.spacingMd),

                    // Achievements section
                    FadeIn(
                      delay: const Duration(milliseconds: 200),
                      child: Container(
                        padding: const EdgeInsets.all(AppTheme.spacingLg),
                        decoration: AppDecorations.cardDecoration(
                          context: context,
                          radius: AppTheme.radiusXl,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  '🏆 成就',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                const SizedBox(width: AppTheme.spacingSm),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppTheme.accentColor.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(
                                        AppTheme.radiusFull),
                                  ),
                                  child: Text(
                                    '${_achievements.length} 个已解锁',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.accentDark,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppTheme.spacingMd),
                            if (_achievements.isEmpty)
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: AppTheme.spacingMd),
                                  child: Column(
                                    children: [
                                      Text('🔒',
                                          style: TextStyle(fontSize: 32)),
                                      const SizedBox(height: 8),
                                      Text(
                                        '还没有解锁任何成就',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AppTheme.textHint,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              ..._achievements.map((ua) => Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: AppTheme.spacingSm),
                                    child: _AchievementItem(
                                      achievement: ua,
                                      difficultyColor: _difficultyColor(
                                          ua.achievement.difficulty),
                                      difficultyLabel: _difficultyLabel(
                                          ua.achievement.difficulty),
                                    ),
                                  )),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: AppTheme.spacingMd),

                    // Settings section
                    FadeIn(
                      delay: const Duration(milliseconds: 250),
                      child: Container(
                        padding: const EdgeInsets.all(AppTheme.spacingLg),
                        decoration: AppDecorations.cardDecoration(
                          context: context,
                          radius: AppTheme.radiusXl,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '⚙️ 设置',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: AppTheme.spacingMd),
                            // Dark mode toggle
                            _SettingItem(
                              icon: Icons.dark_mode_rounded,
                              label: '深色模式',
                              value: _darkMode,
                              onChanged: (v) async {
                                setState(() => _darkMode = v);
                                final prefs =
                                    await SharedPreferences.getInstance();
                                await prefs.setBool('darkMode', v);
                              },
                            ),
                            const SizedBox(height: AppTheme.spacingSm),
                            // Sound toggle
                            _SettingItem(
                              icon: Icons.volume_up_rounded,
                              label: '音效',
                              value: _soundEnabled,
                              onChanged: (v) async {
                                setState(() => _soundEnabled = v);
                                final prefs =
                                    await SharedPreferences.getInstance();
                                await prefs.setBool('soundEnabled', v);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: AppTheme.spacingMd),

                    // Logout button
                    FadeIn(
                      delay: const Duration(milliseconds: 300),
                      child: BounceButton(
                        onPressed: _logout,
                        child: Container(
                          width: double.infinity,
                          height: 52,
                          decoration: BoxDecoration(
                            color: AppTheme.dangerColor.withOpacity(0.08),
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusMd),
                            border: Border.all(
                              color: AppTheme.dangerColor.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.logout_rounded,
                                  color: AppTheme.dangerColor, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                '退出登录',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.dangerColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppTheme.spacingXl),
                  ],
                ),
              ),
            ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String icon;
  final String value;
  final String label;
  final Color color;
  final bool fullWidth;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: fullWidth
          ? const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingLg, vertical: AppTheme.spacingMd)
          : const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingMd, vertical: AppTheme.spacingMd),
      decoration: AppDecorations.cardDecoration(
        context: context,
        radius: AppTheme.radiusLg,
      ),
      child: Row(
        mainAxisAlignment:
            fullWidth ? MainAxisAlignment.start : MainAxisAlignment.center,
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment:
                fullWidth ? CrossAxisAlignment.start : CrossAxisAlignment.center,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: fullWidth ? 22 : 18,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AchievementItem extends StatelessWidget {
  final UserAchievementModel achievement;
  final Color difficultyColor;
  final String difficultyLabel;

  const _AchievementItem({
    required this.achievement,
    required this.difficultyColor,
    required this.difficultyLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.04),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: difficultyColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Center(
              child: Text(
                achievement.achievement.icon,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: AppTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.achievement.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  achievement.achievement.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: difficultyColor.withOpacity(0.1),
              borderRadius:
                  BorderRadius.circular(AppTheme.radiusFull),
            ),
            child: Text(
              difficultyLabel,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: difficultyColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 22, color: AppTheme.textSecondary),
        const SizedBox(width: AppTheme.spacingMd),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppTheme.primaryColor,
        ),
      ],
    );
  }
}
