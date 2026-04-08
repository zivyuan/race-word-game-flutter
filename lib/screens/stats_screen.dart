import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/analytics_service.dart';
import '../services/share_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class StatsScreen extends StatefulWidget {
  final UserProfile user;

  const StatsScreen({super.key, required this.user});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  Map<String, dynamic> _stats = {};
  List<Map<String, dynamic>> _weeklyStats = [];
  List<Map<String, dynamic>> _achievements = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final analytics = AnalyticsService();
    final stats = await analytics.getLearningStats(widget.user.id);
    final weekly = await analytics.getWeeklyStats(widget.user.id);
    final achievements = await analytics.getAllAchievements(widget.user.id);
    if (mounted) {
      setState(() {
        _stats = stats;
        _weeklyStats = weekly;
        _achievements = achievements;
        _loading = false;
      });
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
        title: const Text('学习统计'),
        actions: [
          BounceButton(
            onPressed: () => ShareService.shareWeeklySummary(
              sessionsCount: _stats['totalSessions'] ?? 0,
              wordsLearned: _stats['totalQuestions'] ?? 0,
              accuracy: _stats['accuracy'] ?? 0,
              streakDays: _stats['streakDays'] ?? 0,
              userName: widget.user.nickname,
            ),
            child: Container(
              margin: const EdgeInsets.only(right: AppTheme.spacingSm),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                border: Border.all(
                  color: AppTheme.primaryColor.withOpacity(0.15),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.share_rounded,
                      color: AppTheme.primaryColor, size: 18),
                  SizedBox(width: 4),
                  Text(
                    '分享',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: FunLoadingIndicator(message: '加载统计中'))
          : RefreshIndicator(
              color: AppTheme.primaryColor,
              onRefresh: _loadStats,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppTheme.spacingMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Overview cards
                    FadeIn(child: _buildOverview()),
                    const SizedBox(height: AppTheme.spacingLg),

                    // Streak card
                    FadeIn(
                      delay: const Duration(milliseconds: 100),
                      child: _buildStreakCard(),
                    ),
                    const SizedBox(height: AppTheme.spacingLg),

                    // Weekly activity
                    FadeIn(
                      delay: const Duration(milliseconds: 200),
                      child: _buildWeeklyActivity(),
                    ),
                    const SizedBox(height: AppTheme.spacingLg),

                    // Progress bars
                    FadeIn(
                      delay: const Duration(milliseconds: 300),
                      child: _buildProgressSection(),
                    ),
                    const SizedBox(height: AppTheme.spacingLg),

                    // Achievements
                    FadeIn(
                      delay: const Duration(milliseconds: 400),
                      child: _buildAchievements(),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildOverview() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      decoration: AppDecorations.cardDecoration(context, radius: AppTheme.radiusXl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: const Icon(Icons.bar_chart_rounded,
                    color: AppTheme.primaryColor, size: 22),
              ),
              const SizedBox(width: AppTheme.spacingMd),
              const Text(
                '学习总览',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingLg),
          Row(
            children: [
              Expanded(child: _StatCard(
                icon: '🎮',
                label: '学习次数',
                value: '${_stats['totalSessions'] ?? 0}',
                color: AppTheme.primaryColor,
              )),
              const SizedBox(width: 12),
              Expanded(child: _StatCard(
                icon: '📝',
                label: '答题数',
                value: '${_stats['totalQuestions'] ?? 0}',
                color: AppTheme.secondaryColor,
              )),
              const SizedBox(width: 12),
              Expanded(child: _StatCard(
                icon: '📊',
                label: '正确率',
                value: '${_stats['accuracy'] ?? 0}%',
                color: AppTheme.successColor,
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard() {
    final streakDays = _stats['streakDays'] ?? 0;
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: streakDays >= 7
              ? [const Color(0xFFFF6B6B), const Color(0xFFE84393)]
              : streakDays >= 3
                  ? [AppTheme.accentColor, AppTheme.accentDark]
                  : [AppTheme.primaryColor, AppTheme.secondaryColor],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          PulseAnimation(
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🔥', style: TextStyle(fontSize: 36)),
              ),
            ),
          ),
          const SizedBox(width: AppTheme.spacingLg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '连续学习',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$streakDays',
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        '天',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  streakDays >= 7
                      ? '太厉害了，坚持就是胜利！'
                      : streakDays >= 3
                          ? '很棒，继续保持！'
                          : '每天学习一点点！',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          // Streak dots
          ...List.generate(7, (i) {
            final active = i < streakDays;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: active ? Colors.white : Colors.white.withOpacity(0.25),
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildWeeklyActivity() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      decoration: AppDecorations.cardDecoration(context, radius: AppTheme.radiusXl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: const Icon(Icons.calendar_today_rounded,
                    color: AppTheme.successColor, size: 20),
              ),
              const SizedBox(width: AppTheme.spacingMd),
              const Text(
                '本周活跃度',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingLg),
          SizedBox(
            height: 120,
            child: _weeklyStats.isEmpty
                ? Center(
                    child: Text(
                      '本周还没有学习记录\n快来挑战吧！',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textHint,
                      ),
                    ),
                  )
                : _buildBarChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    final maxQuestions = _weeklyStats.isEmpty
        ? 1
        : _weeklyStats
            .map((d) => d['questions'] as int? ?? 0)
            .reduce((a, b) => a > b ? a : b)
            .toDouble();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: _weeklyStats.map((day) {
        final questions = (day['questions'] as int?) ?? 0;
        final height = maxQuestions > 0
            ? (questions / maxQuestions * 100).clamp(8.0, 100.0)
            : 8.0;
        final dateStr = day['date'] as String;
        final dayLabel = dateStr.substring(5, 10); // MM-DD

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (questions > 0)
                  Text(
                    '$questions',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                const SizedBox(height: 4),
                Container(
                  height: height,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppTheme.primaryColor,
                        AppTheme.secondaryColor,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  dayLabel,
                  style: TextStyle(
                    fontSize: 10,
                    color: AppTheme.textHint,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildProgressSection() {
    final mastered = _stats['masteredCards'] ?? 0;
    final learning = _stats['learningCards'] ?? 0;
    final total = _stats['totalCards'] ?? 0;
    final studyTime = _stats['totalStudyTime'] ?? 0;
    final minutes = (studyTime / 60).round();

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      decoration: AppDecorations.cardDecoration(context, radius: AppTheme.radiusXl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: const Icon(Icons.trending_up_rounded,
                    color: AppTheme.accentDark, size: 22),
              ),
              const SizedBox(width: AppTheme.spacingMd),
              const Text(
                '学习进度',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingLg),

          // Mastery progress
          _ProgressBar(
            label: '已掌握',
            count: mastered,
            total: total,
            color: AppTheme.successColor,
            icon: '⭐',
          ),
          const SizedBox(height: AppTheme.spacingMd),
          _ProgressBar(
            label: '学习中',
            count: learning,
            total: total,
            color: AppTheme.accentDark,
            icon: '📖',
          ),
          const SizedBox(height: AppTheme.spacingMd),
          _ProgressBar(
            label: '未学习',
            count: total - mastered - learning,
            total: total,
            color: AppTheme.textHint,
            icon: '🆕',
          ),

          const SizedBox(height: AppTheme.spacingLg),
          const Divider(),
          const SizedBox(height: AppTheme.spacingMd),

          // Study time
          Row(
            children: [
              const Text('⏱️', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Text(
                '累计学习时间',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                minutes >= 60
                    ? '${minutes ~/ 60}小时${minutes % 60}分'
                    : '$minutes 分钟',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Row(
            children: [
              const Text('🔥', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Text(
                '最高连击记录',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                '${_stats['totalMaxStreak'] ?? 0} 次',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAchievements() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      decoration: AppDecorations.cardDecoration(context, radius: AppTheme.radiusXl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.warningColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: const Icon(Icons.emoji_events_rounded,
                    color: AppTheme.warningColor, size: 22),
              ),
              const SizedBox(width: AppTheme.spacingMd),
              const Text(
                '我的成就',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
                child: Text(
                  '${_achievements.length}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.accentDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMd),
          if (_achievements.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingMd),
              child: Center(
                child: Text(
                  '还没有解锁成就\n完成游戏来解锁吧！',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textHint,
                  ),
                ),
              ),
            )
          else
            ..._achievements.map((a) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _AchievementTile(
                    icon: a['icon'] as String,
                    title: a['title'] as String,
                    description: a['description'] as String,
                    onTap: () => ShareService.shareAchievement(
                      title: a['title'] as String,
                      description: a['description'] as String,
                      icon: a['icon'] as String,
                      userName: widget.user.nickname,
                    ),
                  ),
                )),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: color.withOpacity(0.12)),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final String label;
  final int count;
  final int total;
  final Color color;
  final String icon;

  const _ProgressBar({
    required this.label,
    required this.count,
    required this.total,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final fraction = total > 0 ? count / total : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
            const Spacer(),
            Text(
              '$count / $total',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: LinearProgressIndicator(
            value: fraction,
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}

class _AchievementTile extends StatelessWidget {
  final String icon;
  final String title;
  final String description;
  final VoidCallback? onTap;

  const _AchievementTile({
    required this.icon,
    required this.title,
    required this.description,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.accentColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: AppTheme.accentColor.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: Center(
                child: Text(icon, style: const TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.share_rounded,
              size: 18,
              color: AppTheme.textHint,
            ),
          ],
        ),
      ),
    );
  }
}
