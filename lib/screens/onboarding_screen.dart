import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final _nicknameController = TextEditingController();
  String _selectedAvatar = '🐶';
  int _step = 0;

  late AnimationController _pageController;

  final List<String> _avatars = [
    '🐶', '🐱', '🐼', '🦊', '🐻', '🐰',
    '🦁', '🐯', '🐨', '🐸', '🐵', '🦄',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = AnimationController(
      vsync: this,
      duration: AppTheme.animNormal,
    );
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _goToStep(int step) {
    _pageController.forward().then((_) {
      setState(() => _step = step);
      _pageController.reverse();
    });
  }

  Future<void> _submit() async {
    if (_nicknameController.text.trim().isEmpty) return;

    try {
      final user = await ApiService.createUser(
        _nicknameController.text.trim(),
        _selectedAvatar,
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', user.id);
      await prefs.setString('nickname', user.nickname);
      await prefs.setString('avatarUrl', user.avatarUrl);
      widget.onComplete();
    } catch (e) {
      if (mounted) {
        FriendlyErrorDialog.show(
          context,
          message: '创建用户失败了，请检查网络后重试',
          onRetry: _submit,
        );
      }
    }
  }

  Widget _buildWelcome() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.warmGradient(context),
      ),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingXl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                PulseAnimation(
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text('🏃‍♂️💨',
                          style: TextStyle(fontSize: 72)),
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingXl),
                FadeIn(
                  delay: const Duration(milliseconds: 200),
                  child: ShaderMask(
                    shaderCallback: (bounds) {
                      return const LinearGradient(
                        colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                      ).createShader(bounds);
                    },
                    child: const Text(
                      '单词竞速卡片',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingMd),
                FadeIn(
                  delay: const Duration(milliseconds: 400),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingLg,
                        vertical: AppTheme.spacingSm),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                    ),
                    child: Text(
                      '通过拍照创建卡片，在游戏中快乐学单词！',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: AppTheme.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingXxl),
                FadeIn(
                  delay: const Duration(milliseconds: 600),
                  child: BounceButton(
                    onPressed: () => _goToStep(1),
                    child: Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.primaryColor, AppTheme.primaryDark],
                        ),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        boxShadow: [
                          BoxShadow(
                            color:
                                AppTheme.primaryColor.withOpacity(0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          '开始使用',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNickname() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.warmGradient(context),
      ),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingXl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FadeIn(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryColor.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text('✏️', style: TextStyle(fontSize: 48)),
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingLg),
                FadeIn(
                  delay: const Duration(milliseconds: 150),
                  child: const Text(
                    '你叫什么名字？',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingLg),
                FadeIn(
                  delay: const Duration(milliseconds: 300),
                  child: TextField(
                    controller: _nicknameController,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                    decoration: const InputDecoration(
                      hintText: '输入你的昵称',
                      prefixIcon: null,
                    ),
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) {
                      if (_nicknameController.text.trim().isNotEmpty) {
                        _goToStep(2);
                      }
                    },
                  ),
                ),
                const SizedBox(height: AppTheme.spacingLg),
                FadeIn(
                  delay: const Duration(milliseconds: 450),
                  child: BounceButton(
                    onPressed: _nicknameController.text.trim().isNotEmpty
                        ? () => _goToStep(2)
                        : null,
                    child: AnimatedContainer(
                      duration: AppTheme.animNormal,
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: _nicknameController.text.trim().isNotEmpty
                            ? const LinearGradient(
                                colors: [
                                  AppTheme.primaryColor,
                                  AppTheme.primaryDark
                                ],
                              )
                            : null,
                        color: _nicknameController.text.trim().isNotEmpty
                            ? null
                            : AppTheme.textHint.withOpacity(0.3),
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMd),
                        boxShadow: _nicknameController.text.trim().isNotEmpty
                            ? [
                                BoxShadow(
                                  color: AppTheme.primaryColor
                                      .withOpacity(0.25),
                                  blurRadius: 16,
                                  offset: const Offset(0, 8),
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          '下一步',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color:
                                _nicknameController.text.trim().isNotEmpty
                                    ? Colors.white
                                    : AppTheme.textHint,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.warmGradient(context),
      ),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacingXl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FadeIn(
                  child: PulseAnimation(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor.withOpacity(0.12),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.accentColor.withOpacity(0.3),
                          width: 3,
                        ),
                      ),
                      child: Center(
                        child:
                            Text(_selectedAvatar, style: const TextStyle(fontSize: 64)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingMd),
                FadeIn(
                  delay: const Duration(milliseconds: 100),
                  child: const Text(
                    '选一个你喜欢的头像',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingXs),
                FadeIn(
                  delay: const Duration(milliseconds: 200),
                  child: Text(
                    _nicknameController.text.trim(),
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingLg),
                FadeIn(
                  delay: const Duration(milliseconds: 300),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                    ),
                    itemCount: _avatars.length,
                    itemBuilder: (context, index) {
                      final avatar = _avatars[index];
                      final selected = avatar == _selectedAvatar;
                      return BounceButton(
                        onPressed: () =>
                            setState(() => _selectedAvatar = avatar),
                        child: AnimatedContainer(
                          duration: AppTheme.animNormal,
                          decoration: BoxDecoration(
                            color: selected
                                ? AppTheme.primaryColor.withOpacity(0.1)
                                : Colors.transparent,
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusMd),
                            border: selected
                                ? Border.all(
                                    color: AppTheme.primaryColor, width: 3)
                                : Border.all(
                                    color: Colors.grey.shade200, width: 1),
                          ),
                          child: Center(
                            child: Text(avatar,
                                style: TextStyle(
                                  fontSize: selected ? 38 : 34,
                                )),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppTheme.spacingXl),
                FadeIn(
                  delay: const Duration(milliseconds: 500),
                  child: BounceButton(
                    onPressed: _submit,
                    child: Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppTheme.successColor,
                            Color(0xFF00CEC9),
                          ],
                        ),
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMd),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.successColor.withOpacity(0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          '开始学习！🚀',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget current = switch (_step) {
      0 => _buildWelcome(),
      1 => _buildNickname(),
      _ => _buildAvatar(),
    };

    return Scaffold(
      body: AnimatedSwitcher(
        duration: AppTheme.animNormal,
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: KeyedSubtree(key: ValueKey(_step), child: current),
      ),
    );
  }
}
