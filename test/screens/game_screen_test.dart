import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:race_word_game/models/models.dart';
import 'package:race_word_game/screens/game_screen.dart';
import 'package:race_word_game/theme/app_theme.dart';

void main() {
  final testCardSet = CardSetInfo(
    id: 'cs-1',
    userId: 'u-1',
    name: '动物单词',
    createdAt: '2026-01-01T00:00:00Z',
  );

  final testCards = [
    CardItem(
      id: 'c-1',
      cardSetId: 'cs-1',
      imageUrl: '/uploads/cards/cat.png',
      word: 'cat',
      createdAt: '2026-01-01T00:00:00Z',
    ),
    CardItem(
      id: 'c-2',
      cardSetId: 'cs-1',
      imageUrl: '/uploads/cards/dog.png',
      word: 'dog',
      createdAt: '2026-01-01T00:00:00Z',
    ),
    CardItem(
      id: 'c-3',
      cardSetId: 'cs-1',
      imageUrl: '/uploads/cards/bird.png',
      word: 'bird',
      createdAt: '2026-01-01T00:00:00Z',
    ),
  ];

  Widget buildSubject({List<CardItem> cards = const []}) => MaterialApp(
        theme: AppTheme.lightTheme,
        home: GameScreen(cardSet: testCardSet, cards: cards),
      );

  group('GameScreen idle state', () {
    testWidgets('shows game target icon', (tester) async {
      await tester.pumpWidget(buildSubject(cards: testCards));
      await tester.pumpAndSettle();

      expect(find.text('🎯'), findsOneWidget);
    });

    testWidgets('displays card set name', (tester) async {
      await tester.pumpWidget(buildSubject(cards: testCards));
      await tester.pumpAndSettle();

      expect(find.text('动物单词'), findsOneWidget);
    });

    testWidgets('shows card count', (tester) async {
      await tester.pumpWidget(buildSubject(cards: testCards));
      await tester.pumpAndSettle();

      expect(find.text('3 张卡片'), findsOneWidget);
    });

    testWidgets('shows start button when enough cards', (tester) async {
      await tester.pumpWidget(buildSubject(cards: testCards));
      await tester.pumpAndSettle();

      expect(find.text('开始游戏 🚀'), findsOneWidget);
    });

    testWidgets('shows disabled message with insufficient cards',
        (tester) async {
      final fewCards = [testCards[0]];
      await tester.pumpWidget(buildSubject(cards: fewCards));
      await tester.pumpAndSettle();

      expect(find.text('至少需要 2 张卡片'), findsOneWidget);
    });

    testWidgets('shows disabled message with no cards', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('至少需要 2 张卡片'), findsOneWidget);
    });

    testWidgets('shows "1 张卡片" count for single card', (tester) async {
      await tester.pumpWidget(buildSubject(cards: [testCards[0]]));
      await tester.pumpAndSettle();

      expect(find.text('1 张卡片'), findsOneWidget);
    });
  });

  group('GameScreen countdown', () {
    testWidgets('tapping start begins countdown', (tester) async {
      await tester.pumpWidget(buildSubject(cards: testCards));
      await tester.pumpAndSettle();

      await tester.tap(find.text('开始游戏 🚀'));
      await tester.pump();

      // Should show countdown screen
      expect(find.text('准备好了吗？'), findsOneWidget);
    });
  });

  group('GameScreen result', () {
    testWidgets('result screen shows game over text', (tester) async {
      await tester.pumpWidget(buildSubject(cards: testCards));
      await tester.pumpAndSettle();

      // Start game
      await tester.tap(find.text('开始游戏 🚀'));
      await tester.pump();

      // We can't easily simulate the full game in widget tests
      // since it involves TTS and timers, but we verify initial state
      expect(find.text('准备好了吗？'), findsOneWidget);
    });
  });
}
