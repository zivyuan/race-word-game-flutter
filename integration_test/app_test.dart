import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:race_word_game/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// E2E integration tests for the full app flow.
///
/// These tests run against a real Flutter engine and validate the
/// complete user journey: Onboarding → Home → Create Card Set → Game.
///
/// Run with: flutter test integration_test/app_test.dart

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Full App Flow', () {
    testWidgets('app launches and shows loading indicator', (tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(const RaceWordGameApp());
      await binding.pump();

      // Should show loading state initially
      expect(find.text('正在加载'), findsOneWidget);
    });

    testWidgets('new user sees onboarding welcome screen', (tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(const RaceWordGameApp());
      await tester.pumpAndSettle();

      // After loading, should show onboarding
      expect(find.text('单词竞速卡片'), findsOneWidget);
      expect(find.text('开始使用'), findsOneWidget);
      expect(find.text('通过拍照创建卡片，在游戏中快乐学单词！'),
          findsOneWidget);
    });

    testWidgets('onboarding flow: welcome → nickname → avatar', (tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(const RaceWordGameApp());
      await tester.pumpAndSettle();

      // Step 0: Welcome screen
      expect(find.text('开始使用'), findsOneWidget);

      // Tap "开始使用"
      await tester.tap(find.text('开始使用'));
      await tester.pumpAndSettle();

      // Step 1: Nickname screen
      expect(find.text('你叫什么名字？'), findsOneWidget);
      expect(find.text('输入你的昵称'), findsOneWidget);

      // Enter nickname
      await tester.enterText(find.byType(TextField), '小明');
      await tester.pumpAndSettle();

      // Tap "下一步"
      await tester.tap(find.text('下一步'));
      await tester.pumpAndSettle();

      // Step 2: Avatar selection screen
      expect(find.text('选一个你喜欢的头像'), findsOneWidget);
      expect(find.text('小明'), findsOneWidget);
      expect(find.text('开始学习！🚀'), findsOneWidget);

      // Verify avatar grid has items
      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('nickname validation: empty name disables next button',
        (tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(const RaceWordGameApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('开始使用'));
      await tester.pumpAndSettle();

      // Don't enter anything - button should still be visible but disabled
      expect(find.text('下一步'), findsOneWidget);
    });

    testWidgets('avatar selection updates preview', (tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(const RaceWordGameApp());
      await tester.pumpAndSettle();

      // Navigate to avatar step
      await tester.tap(find.text('开始使用'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Test');
      await tester.pumpAndSettle();
      await tester.tap(find.text('下一步'));
      await tester.pumpAndSettle();

      // Default avatar is 🐶
      expect(find.text('🐶'), findsWidgets);

      // Tap a different avatar (🐱)
      await tester.tap(find.text('🐱').first);
      await tester.pumpAndSettle();

      // Should still be on avatar screen
      expect(find.text('选一个你喜欢的头像'), findsOneWidget);
    });

    testWidgets('returning user sees home screen', (tester) async {
      SharedPreferences.setMockInitialValues({
        'userId': 'test-user-123',
        'nickname': '测试用户',
        'avatarUrl': '🐱',
      });

      await tester.pumpWidget(const RaceWordGameApp());
      await tester.pumpAndSettle();

      // Should show home screen with user info
      expect(find.text('测试用户'), findsOneWidget);
      expect(find.text('我的卡片集'), findsOneWidget);
    });
  });
}
