import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const LoginScreen({super.key, required this.onComplete});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _userIdController = TextEditingController();
  bool _loading = false;

  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: AppTheme.animNormal,
    )..forward();
  }

  @override
  void dispose() {
    _userIdController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final userId = _userIdController.text.trim();
    if (userId.isEmpty) return;

    setState(() => _loading = true);
    try {
      final user = await ApiService.getUser(userId);
      if (user == null) {
        if (mounted) {
          FriendlyErrorDialog.show(
            context,
            title: '找不到用户',
            message: '没有找到这个用户ID，请检查后重试或注册新账号',
            buttonText: '知道了',
            icon: Icons.person_search_rounded,
          );
        }
        return;
      }
      // Save user data and navigate to home
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', user.id);
      await prefs.setString('nickname', user.nickname);
      await prefs.setString('avatarUrl', user.avatarUrl);
      if (mounted) widget.onComplete();
    } catch (e) {
      if (mounted) {
        FriendlyErrorDialog.show(
          context,
          message: '登录失败了，请检查网络连接后重试',
          onRetry: _login,
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
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
          child: FadeTransition(
            opacity: _fadeController,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppTheme.spacingXl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Back button
                    Align(
                      alignment: Alignment.centerLeft,
                      child: BounceButton(
                        onPressed: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.textHint.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.arrow_back_rounded,
                            color: AppTheme.textSecondary,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingLg),

                    // Logo
                    FadeIn(
                      delay: const Duration(milliseconds: 100),
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryColor.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text('🔑', style: TextStyle(fontSize: 56)),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingLg),
                    FadeIn(
                      delay: const Duration(milliseconds: 200),
                      child: const Text(
                        '欢迎回来！',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingSm),
                    FadeIn(
                      delay: const Duration(milliseconds: 300),
                      child: Text(
                        '输入你的用户ID来登录',
                        style: TextStyle(
                          fontSize: 15,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingXl),

                    // User ID input
                    FadeIn(
                      delay: const Duration(milliseconds: 400),
                      child: TextField(
                        controller: _userIdController,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                        decoration: const InputDecoration(
                          hintText: '输入用户ID',
                          prefixIcon: Icon(Icons.person_rounded),
                        ),
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _login(),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingXl),

                    // Login button
                    FadeIn(
                      delay: const Duration(milliseconds: 500),
                      child: BounceButton(
                        onPressed: (_loading || _userIdController.text.trim().isEmpty)
                            ? null
                            : _login,
                        child: AnimatedContainer(
                          duration: AppTheme.animNormal,
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: _userIdController.text.trim().isNotEmpty
                                ? const LinearGradient(
                                    colors: [
                                      AppTheme.primaryColor,
                                      AppTheme.primaryDark,
                                    ],
                                  )
                                : null,
                            color: _userIdController.text.trim().isNotEmpty
                                ? null
                                : AppTheme.textHint.withOpacity(0.3),
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusMd),
                            boxShadow: _userIdController.text.trim().isNotEmpty
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
                            child: _loading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : Text(
                                    '登录',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: _userIdController.text.trim().isNotEmpty
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
        ),
      ),
    );
  }
}
