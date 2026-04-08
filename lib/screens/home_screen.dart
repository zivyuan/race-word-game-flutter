import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import 'card_set_detail_screen.dart';
import 'create_card_set_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserProfile? _user;
  List<CardSetInfo> _cardSets = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final nickname = prefs.getString('nickname');
    final avatarUrl = prefs.getString('avatarUrl');

    if (userId != null) {
      setState(() {
        _user = UserProfile(
            id: userId, nickname: nickname ?? '', avatarUrl: avatarUrl ?? '🐶');
      });
      _loadCardSets();
    } else {
      if (mounted) Navigator.of(context).pushReplacementNamed('/onboarding');
    }
  }

  Future<void> _loadCardSets() async {
    if (_user == null) return;
    try {
      final sets = await ApiService.getCardSets(_user!.id);
      setState(() {
        _cardSets = sets;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        FriendlyErrorDialog.show(
          context,
          message: '加载卡片集失败了，请检查网络连接',
          onRetry: () {
            Navigator.pop(context);
            setState(() => _loading = true);
            _loadCardSets();
          },
        );
      }
    }
  }

  Future<void> _deleteCardSet(String id) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: '删除卡片集',
      message: '确定要删除这个卡片集吗？里面的卡片也会一起删除哦。',
      confirmText: '删除',
      isDangerous: true,
      icon: Icons.delete_outline,
    );
    if (confirmed != true || _user == null) return;
    try {
      await ApiService.deleteCardSet(id, _user!.id);
      _loadCardSets();
    } catch (e) {
      if (mounted) {
        FriendlyErrorDialog.show(
          context,
          message: '删除失败了，请稍后重试',
          onRetry: () {
            Navigator.pop(context);
            _deleteCardSet(id);
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.warmGradient(context),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            color: AppTheme.primaryColor,
            onRefresh: _loadCardSets,
            child: CustomScrollView(
              slivers: [
                // 顶部留白
                const SliverToBoxAdapter(child: SizedBox(height: 8)),

                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingMd),
                    child: FadeIn(
                      child: Container(
                        padding: const EdgeInsets.all(AppTheme.spacingMd),
                        decoration: AppDecorations.cardDecoration(
                          context: context,
                          borderColor:
                              AppTheme.primaryColor.withOpacity(0.08),
                          radius: AppTheme.radiusXl,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.08),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  _user?.avatarUrl ?? '🐶',
                                  style: const TextStyle(fontSize: 30),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppTheme.spacingMd),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _user?.nickname ?? '',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '准备好开始学习了吗？ ✨',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    AppTheme.primaryColor,
                                    AppTheme.secondaryColor
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(
                                    AppTheme.radiusMd),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primaryColor
                                        .withOpacity(0.25),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    '${_cardSets.length}',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      height: 1,
                                    ),
                                  ),
                                  Text(
                                    '卡片集',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color:
                                          Colors.white.withOpacity(0.85),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 20)),

                // Title
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingLg),
                    child: FadeIn(
                      delay: const Duration(milliseconds: 100),
                      child: Row(
                        children: [
                          const Text(
                            '我的卡片集',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const Spacer(),
                          BounceButton(
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const CreateCardSetScreen(),
                                ),
                              );
                              _loadCardSets();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(
                                    AppTheme.radiusFull),
                                border: Border.all(
                                  color:
                                      AppTheme.primaryColor.withOpacity(0.15),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.add_circle_rounded,
                                    color: AppTheme.primaryColor,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '新建',
                                    style: TextStyle(
                                      color: AppTheme.primaryColor,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 12)),

                // Card Sets Grid
                if (_loading)
                  const SliverFillRemaining(
                    child: Center(
                      child: FunLoadingIndicator(
                        message: '加载中',
                      ),
                    ),
                  )
                else if (_cardSets.isEmpty)
                  SliverFillRemaining(
                    child: EmptyState(
                      emoji: '📭',
                      title: '还没有卡片集',
                      subtitle: '点击"新建"创建你的第一个卡片集吧！',
                      action: BounceButton(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CreateCardSetScreen(),
                            ),
                          );
                          _loadCardSets();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.spacingXl,
                              vertical: 14),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppTheme.primaryColor,
                                AppTheme.primaryDark,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(
                                AppTheme.radiusFull),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryColor
                                    .withOpacity(0.25),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Text(
                            '创建第一个卡片集',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingMd),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.82,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final set = _cardSets[index];
                          final color = AppTheme.cardSetColors[
                              index % AppTheme.cardSetColors.length];
                          final emoji = AppTheme.cardSetEmojis[
                              index % AppTheme.cardSetEmojis.length];
                          return FadeIn(
                            delay: Duration(
                                milliseconds: 80 * (index % 6)),
                            slideOffset:
                                const Offset(0, 0.15),
                            child: _CardSetCard(
                              cardSet: set,
                              color: color,
                              emoji: emoji,
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        CardSetDetailScreen(cardSet: set),
                                  ),
                                );
                                _loadCardSets();
                              },
                              onDelete: () => _deleteCardSet(set.id),
                            ),
                          );
                        },
                        childCount: _cardSets.length,
                      ),
                    ),
                  ),

                // 底部留白
                const SliverToBoxAdapter(
                    child: SizedBox(height: 100)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CardSetCard extends StatelessWidget {
  final CardSetInfo cardSet;
  final Color color;
  final String emoji;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _CardSetCard({
    required this.cardSet,
    required this.color,
    required this.emoji,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onDelete,
      child: Container(
        decoration: AppDecorations.gradientCardDecoration(color: color),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusSm),
                    ),
                    child: Center(
                      child: Text(emoji, style: const TextStyle(fontSize: 24)),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: color,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                cardSet.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.touch_app_rounded,
                      size: 14, color: AppTheme.textHint),
                  const SizedBox(width: 4),
                  Text(
                    '点击开始学习',
                    style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textHint,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
