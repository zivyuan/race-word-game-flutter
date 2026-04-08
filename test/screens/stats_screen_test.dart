import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:race_word_game/models/models.dart';
import 'package:race_word_game/screens/stats_screen.dart';
import 'package:race_word_game/theme/app_theme.dart';

void main() {
  final testUser = UserProfile(
    id: 'u-1',
    nickname: '小明',
    avatarUrl: '🐶',
  );

  Widget buildSubject() => MaterialApp(
        theme: AppTheme.lightTheme,
        home: StatsScreen(user: testUser),
      );

  group('StatsScreen', () {
    testWidgets('shows title "学习统计"', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.text('学习统计'), findsOneWidget);
    });

    testWidgets('has back button', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('shows loading indicator initially', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.text('加载统计中'), findsOneWidget);
    });

    testWidgets('has share button', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.byIcon(Icons.share_rounded), findsOneWidget);
      expect(find.text('分享'), findsOneWidget);
    });

    testWidgets('shows stats after loading completes', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump(const Duration(seconds: 5));

      // After loading, should show overview section
      expect(find.text('学习总览'), findsOneWidget);
    });

    testWidgets('shows streak card', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump(const Duration(seconds: 5));

      expect(find.text('连续学习'), findsOneWidget);
    });

    testWidgets('shows weekly activity section', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump(const Duration(seconds: 5));

      expect(find.text('本周活跃度'), findsOneWidget);
    });

    testWidgets('shows progress section', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump(const Duration(seconds: 5));

      expect(find.text('学习进度'), findsOneWidget);
    });

    testWidgets('shows achievements section', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump(const Duration(seconds: 5));

      expect(find.text('我的成就'), findsOneWidget);
    });

    testWidgets('overview shows stat labels', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump(const Duration(seconds: 5));

      expect(find.text('学习次数'), findsOneWidget);
      expect(find.text('答题数'), findsOneWidget);
      expect(find.text('正确率'), findsOneWidget);
    });

    testWidgets('progress section shows mastery labels', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump(const Duration(seconds: 5));

      expect(find.text('已掌握'), findsOneWidget);
      expect(find.text('学习中'), findsOneWidget);
      expect(find.text('未学习'), findsOneWidget);
    });
  });
}
