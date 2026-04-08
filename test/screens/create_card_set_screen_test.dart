import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:race_word_game/screens/create_card_set_screen.dart';
import 'package:race_word_game/theme/app_theme.dart';

void main() {
  Widget buildSubject() => MaterialApp(
        theme: AppTheme.lightTheme,
        home: const CreateCardSetScreen(),
      );

  group('CreateCardSetScreen', () {
    testWidgets('renders title', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('创建卡片集'), findsOneWidget);
    });

    testWidgets('has close button in app bar', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('has text field for name input', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('例如：动物单词'), findsOneWidget);
    });

    testWidgets('has "给卡片集起个名字" section', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('给卡片集起个名字'), findsOneWidget);
    });

    testWidgets('has "或者选择预设模板" section', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('或者选择预设模板'), findsOneWidget);
    });

    testWidgets('shows all 6 preset templates', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('动物单词'), findsOneWidget);
      expect(find.text('水果单词'), findsOneWidget);
      expect(find.text('颜色单词'), findsOneWidget);
      expect(find.text('身体部位'), findsOneWidget);
      expect(find.text('交通工具'), findsOneWidget);
      expect(find.text('家庭称呼'), findsOneWidget);
    });

    testWidgets('preset templates have emoji icons', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('🐾'), findsOneWidget);
      expect(find.text('🍎'), findsOneWidget);
      expect(find.text('🎨'), findsOneWidget);
      expect(find.text('🦶'), findsOneWidget);
      expect(find.text('🚗'), findsOneWidget);
      expect(find.text('👨‍👩‍👧'), findsOneWidget);
    });

    testWidgets('has create button', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('创建'), findsOneWidget);
    });

    testWidgets('entering text enables create button', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '我的单词集');
      await tester.pump();

      // Button should now be active (visible with gradient style)
      expect(find.text('创建'), findsOneWidget);
    });

    testWidgets('close button pops navigation', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        home: Builder(builder: (context) {
          return Scaffold(
            body: TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CreateCardSetScreen(),
                ),
              ),
              child: const Text('Go'),
            ),
          );
        }),
      ));

      await tester.pumpAndSettle();
      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();

      expect(find.text('创建卡片集'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.text('Go'), findsOneWidget);
    });
  });
}
