import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _nicknameController = TextEditingController();
  String _selectedAvatar = '🐶';
  int _step = 0; // 0: welcome, 1: nickname, 2: avatar

  final List<String> _avatars = [
    '🐶', '🐱', '🐼', '🦊', '🐻', '🐰',
    '🦁', '🐯', '🐨', '🐸', '🐵', '🦄',
  ];

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_nicknameController.text.trim().isEmpty) return;
    try {
      final user = await ApiService.createUser(
        _nicknameController.text.trim(),
        _selectedAvatar,
      );
      // 保存用户到本地
      final prefs = await _getPrefs();
      await prefs.setString('userId', user.id);
      await prefs.setString('nickname', user.nickname);
      await prefs.setString('avatarUrl', user.avatarUrl);
      widget.onComplete();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('创建失败: $e')),
        );
      }
    }
  }

  Future<SharedPreferences> _getPrefs() {
    return SharedPreferences.getInstance();
  }

  Widget _buildWelcome() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🏃‍♂️💨', style: TextStyle(fontSize: 80)),
            const SizedBox(height: 24),
            const Text(
              '单词竞速卡片',
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF1E1B4B)),
            ),
            const SizedBox(height: 12),
            Text(
              '通过拍照创建卡片，让孩子们在游戏中快乐学习单词！',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => setState(() => _step = 1),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('开始使用', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNickname() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('👤', style: TextStyle(fontSize: 60)),
            const SizedBox(height: 16),
            const Text(
              '你叫什么名字？',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1E1B4B)),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _nicknameController,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                hintText: '输入你的昵称',
                prefixIcon: null,
              ),
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => setState(() => _step = 2),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _nicknameController.text.trim().isNotEmpty
                    ? () => setState(() => _step = 2)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('下一步', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_selectedAvatar, style: const TextStyle(fontSize: 80)),
            const SizedBox(height: 16),
            const Text(
              '选一个你喜欢的头像',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E1B4B)),
            ),
            const SizedBox(height: 8),
            Text(
              _nicknameController.text.trim(),
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemCount: _avatars.length,
              itemBuilder: (context, index) {
                final avatar = _avatars[index];
                final selected = avatar == _selectedAvatar;
                return GestureDetector(
                  onTap: () => setState(() => _selectedAvatar = avatar),
                  child: Container(
                    decoration: BoxDecoration(
                      color: selected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      border: selected ? Border.all(color: AppTheme.primaryColor, width: 3) : null,
                    ),
                    child: Center(
                      child: Text(avatar, style: const TextStyle(fontSize: 36)),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('开始学习！🚀', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: switch (_step) {
          0 => _buildWelcome(),
          1 => _buildNickname(),
          _ => _buildAvatar(),
        },
      ),
    );
  }
}
