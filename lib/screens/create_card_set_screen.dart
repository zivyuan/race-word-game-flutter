import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class CreateCardSetScreen extends StatefulWidget {
  const CreateCardSetScreen({super.key});

  @override
  State<CreateCardSetScreen> createState() => _CreateCardSetScreenState();
}

class _CreateCardSetScreenState extends State<CreateCardSetScreen> {
  final _nameController = TextEditingController();
  bool _loading = false;

  final List<Map<String, String>> _presets = [
    {'name': '动物单词', 'emoji': '🐾', 'color': '0xFF00B894'},
    {'name': '水果单词', 'emoji': '🍎', 'color': '0xFFFF6B6B'},
    {'name': '颜色单词', 'emoji': '🎨', 'color': '0xFF6C5CE7'},
    {'name': '身体部位', 'emoji': '🦶', 'color': '0xFF0984E3'},
    {'name': '交通工具', 'emoji': '🚗', 'color': '0xFFF39C12'},
    {'name': '家庭称呼', 'emoji': '👨‍👩‍👧', 'color': '0xFFE84393'},
  ];

  Future<void> _create(String name) async {
    setState(() => _loading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      if (userId == null) return;
      await ApiService.createCardSet(userId, name);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        FriendlyErrorDialog.show(
          context,
          message: '创建卡片集失败了，请检查网络后重试',
          onRetry: () {
            Navigator.pop(context);
            _create(name);
          },
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
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
            child: const Icon(Icons.close, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('创建卡片集'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeIn(
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.08),
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusSm),
                    ),
                    child: const Icon(
                      Icons.edit_note_rounded,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingMd),
                  const Text(
                    '给卡片集起个名字',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            FadeIn(
              delay: const Duration(milliseconds: 100),
              child: TextField(
                controller: _nameController,
                decoration: const InputDecoration(hintText: '例如：动物单词'),
                textInputAction: TextInputAction.done,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(height: AppTheme.spacingXl),
            FadeIn(
              delay: const Duration(milliseconds: 200),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor.withOpacity(0.15),
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusSm),
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: AppTheme.accentDark,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingMd),
                  const Text(
                    '或者选择预设模板',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 2.8,
              ),
              itemCount: _presets.length,
              itemBuilder: (context, index) {
                final preset = _presets[index];
                final color = Color(int.parse(preset['color']!));
                return FadeIn(
                  delay: Duration(milliseconds: 250 + index * 60),
                  child: BounceButton(
                    onPressed: _loading ? null : () => _create(preset['name']!),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF16213E)
                            : Colors.white,
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMd),
                        border: Border.all(
                          color: color.withOpacity(0.2),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(preset['emoji']!,
                              style: const TextStyle(fontSize: 22)),
                          const SizedBox(width: 8),
                          Text(
                            preset['name']!,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: AppTheme.spacingXl),
            FadeIn(
              delay: const Duration(milliseconds: 600),
              child: BounceButton(
                onPressed: _loading || _nameController.text.trim().isEmpty
                    ? null
                    : () => _create(_nameController.text.trim()),
                child: AnimatedContainer(
                  duration: AppTheme.animNormal,
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: _nameController.text.trim().isNotEmpty
                        ? const LinearGradient(
                            colors: [
                              AppTheme.primaryColor,
                              AppTheme.primaryDark
                            ],
                          )
                        : null,
                    color: _nameController.text.trim().isNotEmpty
                        ? null
                        : AppTheme.textHint.withOpacity(0.15),
                    borderRadius:
                        BorderRadius.circular(AppTheme.radiusMd),
                    boxShadow: _nameController.text.trim().isNotEmpty
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
                            '创建',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: _nameController.text.trim().isNotEmpty
                                  ? Colors.white
                                  : AppTheme.textHint,
                            ),
                          ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacingLg),
          ],
        ),
      ),
    );
  }
}
