import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/app_theme.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';
import 'widgets/app_widgets.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const RaceWordGameApp());
}

class RaceWordGameApp extends StatelessWidget {
  const RaceWordGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '单词竞速卡片',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const _AppEntry(),
    );
  }
}

class _AppEntry extends StatefulWidget {
  const _AppEntry();

  @override
  State<_AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<_AppEntry> {
  bool _loading = true;
  bool _hasUser = false;

  @override
  void initState() {
    super.initState();
    _checkUser();
  }

  Future<void> _checkUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    // 稍微延迟让加载动画显示
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() {
        _hasUser = userId != null;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.warmGradient(context),
          ),
          child: const Center(
            child: FunLoadingIndicator(
              message: '正在加载',
              size: 130,
            ),
          ),
        ),
      );
    }

    if (_hasUser) {
      return const HomeScreen();
    }

    return OnboardingScreen(
      onComplete: () {
        setState(() => _hasUser = true);
      },
    );
  }
}
