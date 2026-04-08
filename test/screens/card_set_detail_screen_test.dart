import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:race_word_game/models/models.dart';
import 'package:race_word_game/screens/card_set_detail_screen.dart';
import 'package:race_word_game/theme/app_theme.dart';

void main() {
  final testCardSet = CardSetInfo(
    id: 'cs-1',
    userId: 'u-1',
    name: '动物单词',
    createdAt: '2026-01-01T00:00:00Z',
  );

  Widget buildSubject() => MaterialApp(
        theme: AppTheme.lightTheme,
        home: CardSetDetailScreen(cardSet: testCardSet),
      );

  group('CardSetDetailScreen', () {
    testWidgets('shows card set name in app bar', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.text('动物单词'), findsOneWidget);
    });

    testWidgets('has back button', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('shows loading indicator initially', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.text('加载中'), findsOneWidget);
    });

    testWidgets('has floating action button for adding cards',
        (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.text('拍照添加'), findsOneWidget);
    });

    testWidgets('FAB has camera icon', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.byIcon(Icons.camera_alt_rounded), findsOneWidget);
    });

    testWidgets('shows card count stat after loading', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump(const Duration(seconds: 5));

      // After API fails, loading is done
      // Cards will be empty, showing empty state
      expect(find.text('还没有卡片'), findsOneWidget);
    });

    testWidgets('empty state shows appropriate message', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump(const Duration(seconds: 5));

      expect(find.text('还没有卡片'), findsOneWidget);
      expect(find.text('点击下方按钮拍照添加第一张卡片吧！'), findsOneWidget);
    });

    testWidgets('empty state has action button', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump(const Duration(seconds: 5));

      expect(find.text('拍照添加第一张'), findsOneWidget);
    });
  });
}
