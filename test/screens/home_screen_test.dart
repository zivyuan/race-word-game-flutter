import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:race_word_game/screens/home_screen.dart';
import 'package:race_word_game/theme/app_theme.dart';
import 'package:race_word_game/widgets/app_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('HomeScreen', () {
    Widget buildSubject() => MaterialApp(
          theme: AppTheme.lightTheme,
          home: const HomeScreen(),
        );

    testWidgets('shows loading indicator initially', (tester) async {
      SharedPreferences.setMockInitialValues({
        'userId': 'test-user-123',
        'nickname': '测试用户',
        'avatarUrl': '🐱',
      });

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      // FunLoadingIndicator shows animated text like "加载中." / "加载中.."
      expect(find.byType(FunLoadingIndicator), findsOneWidget);
    });

    testWidgets('shows user nickname after loading', (tester) async {
      SharedPreferences.setMockInitialValues({
        'userId': 'test-user-123',
        'nickname': '小明',
        'avatarUrl': '🐶',
      });

      await tester.pumpWidget(buildSubject());
      await tester.pump(const Duration(seconds: 5));

      // After API fails, user info should be set
      expect(find.text('小明'), findsOneWidget);
    });

    testWidgets('renders Scaffold', (tester) async {
      SharedPreferences.setMockInitialValues({
        'userId': 'u1',
        'nickname': 'Alice',
        'avatarUrl': '🦊',
      });

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('has "新建" button in title area', (tester) async {
      SharedPreferences.setMockInitialValues({
        'userId': 'u1',
        'nickname': 'Test',
        'avatarUrl': '🐶',
      });

      await tester.pumpWidget(buildSubject());
      await tester.pump(const Duration(seconds: 5));

      expect(find.text('新建'), findsOneWidget);
    });

    testWidgets('shows empty state when no card sets', (tester) async {
      SharedPreferences.setMockInitialValues({
        'userId': 'u1',
        'nickname': 'Test',
        'avatarUrl': '🐶',
      });

      await tester.pumpWidget(buildSubject());
      await tester.pump(const Duration(seconds: 5));

      // API fails so cardSets remains empty
      expect(find.text('还没有卡片集'), findsOneWidget);
    });

    testWidgets('has greeting text', (tester) async {
      SharedPreferences.setMockInitialValues({
        'userId': 'u1',
        'nickname': 'Bob',
        'avatarUrl': '🐼',
      });

      await tester.pumpWidget(buildSubject());
      await tester.pump(const Duration(seconds: 5));

      expect(find.text('准备好开始学习了吗？ ✨'), findsOneWidget);
    });

    testWidgets('has "我的卡片集" section title', (tester) async {
      SharedPreferences.setMockInitialValues({
        'userId': 'u1',
        'nickname': 'Test',
        'avatarUrl': '🐶',
      });

      await tester.pumpWidget(buildSubject());
      await tester.pump(const Duration(seconds: 5));

      expect(find.text('我的卡片集'), findsOneWidget);
    });

    testWidgets('shows card set count badge', (tester) async {
      SharedPreferences.setMockInitialValues({
        'userId': 'u1',
        'nickname': 'Test',
        'avatarUrl': '🐶',
      });

      await tester.pumpWidget(buildSubject());
      await tester.pump(const Duration(seconds: 5));

      expect(find.text('卡片集'), findsOneWidget);
    });

    testWidgets('has subtitle with encouragement', (tester) async {
      SharedPreferences.setMockInitialValues({
        'userId': 'u1',
        'nickname': 'Test',
        'avatarUrl': '🐶',
      });

      await tester.pumpWidget(buildSubject());
      await tester.pump(const Duration(seconds: 5));

      expect(find.text('准备好开始学习了吗？ ✨'), findsOneWidget);
    });

    testWidgets('navigates away when no userId', (tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // No user -> should try to navigate away
      expect(find.byType(HomeScreen), findsNothing);
    });
  });
}
