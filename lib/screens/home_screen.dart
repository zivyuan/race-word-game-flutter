import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
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
        _user = UserProfile(id: userId, nickname: nickname ?? '', avatarUrl: avatarUrl ?? '🐶');
      });
      _loadCardSets();
    } else {
      // 退出到引导页
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载失败: $e')),
        );
      }
    }
  }

  Future<void> _deleteCardSet(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除卡片集'),
        content: const Text('确定要删除这个卡片集吗？里面的卡片也会一起删除。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.dangerColor),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (confirmed != true || _user == null) return;
    try {
      await ApiService.deleteCardSet(id, _user!.id);
      _loadCardSets();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('删除失败: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalCards = 0; // TODO: 从 API 获取

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFEF7FF), Color(0xFFF0F9FF), Color(0xFFFEFCE8)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.8)),
                  ),
                  child: Row(
                    children: [
                      Text(_user?.avatarUrl ?? '🐶', style: const TextStyle(fontSize: 40)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_user?.nickname ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E1B4B))),
                            const Text('准备好开始学习了吗？', style: TextStyle(fontSize: 13, color: Colors.grey)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [AppTheme.primaryColor, AppTheme.secondaryColor]),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_cardSets.length}',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Row(
                  children: [
                    const Text('我的卡片集', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E1B4B))),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () async {
                        await Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateCardSetScreen()));
                        _loadCardSets();
                      },
                      icon: const Icon(Icons.add_circle, color: AppTheme.primaryColor),
                      label: const Text('新建', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),

              // Card Sets Grid
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _cardSets.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('📭', style: TextStyle(fontSize: 64)),
                                const SizedBox(height: 16),
                                Text('还没有卡片集', style: TextStyle(fontSize: 18, color: Colors.grey[500])),
                                const SizedBox(height: 8),
                                Text('点击"新建"创建你的第一个卡片集吧！', style: TextStyle(fontSize: 14, color: Colors.grey[400])),
                              ],
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 0.85,
                            ),
                            itemCount: _cardSets.length,
                            itemBuilder: (context, index) {
                              final set = _cardSets[index];
                              final color = AppTheme.cardSetColors[index % AppTheme.cardSetColors.length];
                              return _CardSetCard(
                                cardSet: set,
                                color: color,
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => CardSetDetailScreen(cardSet: set),
                                    ),
                                  );
                                  _loadCardSets();
                                },
                                onDelete: () => _deleteCardSet(set.id),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardSetCard extends StatelessWidget {
  final CardSetInfo cardSet;
  final Color color;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _CardSetCard({
    required this.cardSet,
    required this.color,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onDelete,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.style, color: color, size: 24),
              ),
              const Spacer(),
              Text(
                cardSet.name,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E1B4B)),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '点击开始学习 →',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
