import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class CreateCardSetScreen extends StatefulWidget {
  const CreateCardSetScreen({super.key});

  @override
  State<CreateCardSetScreen> createState() => _CreateCardSetScreenState();
}

class _CreateCardSetScreenState extends State<CreateCardSetScreen> {
  final _nameController = TextEditingController();
  bool _loading = false;

  final List<Map<String, String>> _presets = [
    {'name': '动物单词 🐾', 'emoji': '🐶'},
    {'name': '水果单词 🍎', 'emoji': '🍎'},
    {'name': '颜色单词 🎨', 'emoji': '🎨'},
    {'name': '身体部位 🦶', 'emoji': '🦶'},
    {'name': '交通工具 🚗', 'emoji': '🚗'},
    {'name': '家庭称呼 👨‍👩‍👧', 'emoji': '👨‍👩‍👧'},
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('创建失败: $e')));
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
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
        title: const Text('创建卡片集'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '给卡片集起个名字',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E1B4B)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(hintText: '例如：动物单词'),
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 32),
            const Text(
              '或者选择预设模板',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1E1B4B)),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 2.5,
              ),
              itemCount: _presets.length,
              itemBuilder: (context, index) {
                final preset = _presets[index];
                return GestureDetector(
                  onTap: _loading ? null : () => _create(preset['name']!),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Center(
                      child: Text(preset['name']!, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
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
                onPressed: _loading || _nameController.text.trim().isEmpty
                    ? null
                    : () => _create(_nameController.text.trim()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: _loading
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('创建', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
