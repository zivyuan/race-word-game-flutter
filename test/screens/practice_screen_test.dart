import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:race_word_game/models/models.dart';
import 'package:race_word_game/screens/practice_screen.dart';
import 'package:race_word_game/theme/app_theme.dart';

void main() {
  final testCards = [
    CardItem(
      id: 'c-1',
      cardSetId: 'cs-1',
      imageUrl: '/uploads/apple.png',
      word: 'apple',
      createdAt: '2026-01-01T00:00:00Z',
    ),
    CardItem(
      id: 'c-2',
      cardSetId: 'cs-1',
      imageUrl: '/uploads/banana.png',
      word: 'banana',
      createdAt: '2026-01-01T00:00:00Z',
    ),
  ];

  Widget buildSubject({List<CardItem> cards = const []}) => MaterialApp(
        theme: AppTheme.lightTheme,
        home: PracticeScreen(cards: cards),
      );

  group('PracticeScreen', () {
    testWidgets('shows title "发音练习"', (tester) async {
      await tester.pumpWidget(buildSubject(cards: testCards));
      await tester.pumpAndSettle();

      expect(find.text('发音练习'), findsOneWidget);
    });

    testWidgets('has back button', (tester) async {
      await tester.pumpWidget(buildSubject(cards: testCards));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('shows current word', (tester) async {
      await tester.pumpWidget(buildSubject(cards: testCards));
      await tester.pumpAndSettle();

      expect(find.text('apple'), findsOneWidget);
    });

    testWidgets('has progress indicator', (tester) async {
      await tester.pumpWidget(buildSubject(cards: testCards));
      await tester.pumpAndSettle();

      expect(find.text('1/2'), findsOneWidget);
    });

    testWidgets('has "听发音" button', (tester) async {
      await tester.pumpWidget(buildSubject(cards: testCards));
      await tester.pumpAndSettle();

      expect(find.text('听发音'), findsOneWidget);
    });

    testWidgets('has microphone button', (tester) async {
      await tester.pumpWidget(buildSubject(cards: testCards));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.mic_rounded), findsOneWidget);
    });

    testWidgets('shows "按住说话" label', (tester) async {
      await tester.pumpWidget(buildSubject(cards: testCards));
      await tester.pumpAndSettle();

      expect(find.text('按住说话'), findsOneWidget);
    });

    testWidgets('shows voice not ready warning', (tester) async {
      await tester.pumpWidget(buildSubject(cards: testCards));
      await tester.pumpAndSettle();

      // Voice service is not initialized in test env
      expect(find.text('语音识别未就绪，请检查权限'), findsOneWidget);
    });

    testWidgets('has navigation arrows', (tester) async {
      await tester.pumpWidget(buildSubject(cards: testCards));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward_rounded), findsOneWidget);
    });

    testWidgets('has share button', (tester) async {
      await tester.pumpWidget(buildSubject(cards: testCards));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.share_rounded), findsOneWidget);
    });

    testWidgets('progress updates with single card', (tester) async {
      await tester.pumpWidget(buildSubject(cards: [testCards[0]]));
      await tester.pumpAndSettle();

      expect(find.text('1/1'), findsOneWidget);
    });
  });
}
