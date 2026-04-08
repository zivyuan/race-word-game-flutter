import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/app_theme.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RaceWordGameApp());
}

class RaceWordGameApp extends StatelessWidget {
  const RaceWordGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '单词竞速卡片',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
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
    setState(() {
      _hasUser = userId != null;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🏃‍♂️💨', style: TextStyle(fontSize: 64)),
              SizedBox(height: 16),
              CircularProgressIndicator(color: AppTheme.primaryColor),
            ],
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
