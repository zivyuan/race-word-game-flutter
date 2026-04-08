import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:race_word_game/widgets/app_widgets.dart';
import 'package:race_word_game/theme/app_theme.dart';

void main() {
  Widget wrapWithMaterial(Widget child) => MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(body: Center(child: child)),
      );

  group('BounceButton', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(wrapWithMaterial(
        const BounceButton(child: Text('Click me')),
      ));

      expect(find.text('Click me'), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      var pressed = false;
      await tester.pumpWidget(wrapWithMaterial(
        BounceButton(
          onPressed: () => pressed = true,
          child: const Text('Tap'),
        ),
      ));

      await tester.tap(find.text('Tap'));
      expect(pressed, true);
    });

    testWidgets('does not crash when onPressed is null', (tester) async {
      await tester.pumpWidget(wrapWithMaterial(
        const BounceButton(child: Text('Disabled')),
      ));

      await tester.tap(find.text('Disabled'));
      // No crash expected
    });

    testWidgets('applies backgroundColor when provided', (tester) async {
      await tester.pumpWidget(wrapWithMaterial(
        const BounceButton(
          backgroundColor: Colors.red,
          child: Text('Colored'),
        ),
      ));

      expect(find.text('Colored'), findsOneWidget);
    });
  });

  group('FadeIn', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(wrapWithMaterial(
        const FadeIn(child: Text('Fade')),
      ));
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Fade'), findsOneWidget);
    });

    testWidgets('animates in after delay', (tester) async {
      await tester.pumpWidget(wrapWithMaterial(
        const FadeIn(
          delay: Duration(milliseconds: 100),
          child: Text('Delayed'),
        ),
      ));

      // After delay + animation duration, should be fully visible
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Delayed'), findsOneWidget);
    });

    testWidgets('supports slide offset', (tester) async {
      await tester.pumpWidget(wrapWithMaterial(
        const FadeIn(
          slideOffset: Offset(0, 0.1),
          child: Text('Slide'),
        ),
      ));
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Slide'), findsOneWidget);
    });
  });

  group('PulseAnimation', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(wrapWithMaterial(
        const PulseAnimation(child: Text('Pulse')),
      ));

      expect(find.text('Pulse'), findsOneWidget);
    });

    testWidgets('child is visible', (tester) async {
      await tester.pumpWidget(wrapWithMaterial(
        const PulseAnimation(child: Icon(Icons.star)),
      ));

      expect(find.byIcon(Icons.star), findsOneWidget);
    });
  });

  group('FunLoadingIndicator', () {
    testWidgets('shows running emoji', (tester) async {
      await tester.pumpWidget(wrapWithMaterial(
        const FunLoadingIndicator(),
      ));

      expect(find.text('🏃‍♂️💨'), findsOneWidget);
    });

    testWidgets('shows message when provided', (tester) async {
      await tester.pumpWidget(wrapWithMaterial(
        const FunLoadingIndicator(message: '加载中'),
      ));

      expect(find.text('🏃‍♂️💨'), findsOneWidget);
    });

    testWidgets('works without message', (tester) async {
      await tester.pumpWidget(wrapWithMaterial(
        const FunLoadingIndicator(),
      ));

      // Should not crash
      expect(find.byType(FunLoadingIndicator), findsOneWidget);
    });
  });

  group('FriendlyErrorDialog', () {
    testWidgets('shows title and message', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        home: Builder(builder: (context) {
          return Scaffold(
            body: TextButton(
              onPressed: () => FriendlyErrorDialog.show(
                context,
                message: '网络连接失败',
              ),
              child: const Text('Show'),
            ),
          );
        }),
      ));

      await tester.pumpAndSettle();
      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      expect(find.text('糟糕了！'), findsOneWidget);
      expect(find.text('网络连接失败'), findsOneWidget);
      expect(find.text('重试'), findsOneWidget);
    });

    testWidgets('shows custom title', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        home: Builder(builder: (context) {
          return Scaffold(
            body: TextButton(
              onPressed: () => FriendlyErrorDialog.show(
                context,
                title: '出错了',
                message: 'something failed',
              ),
              child: const Text('Show'),
            ),
          );
        }),
      ));

      await tester.pumpAndSettle();
      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      expect(find.text('出错了'), findsOneWidget);
    });

    testWidgets('dismisses on retry button tap', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        home: Builder(builder: (context) {
          return Scaffold(
            body: TextButton(
              onPressed: () => FriendlyErrorDialog.show(
                context,
                message: 'test error',
              ),
              child: const Text('Show'),
            ),
          );
        }),
      ));

      await tester.pumpAndSettle();
      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('重试'));
      await tester.pumpAndSettle();

      expect(find.text('糟糕了！'), findsNothing);
    });
  });

  group('ConfirmDialog', () {
    testWidgets('shows title and message', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        home: Builder(builder: (context) {
          return Scaffold(
            body: TextButton(
              onPressed: () => ConfirmDialog.show(
                context,
                title: '确认删除',
                message: '确定要删除吗？',
              ),
              child: const Text('Show'),
            ),
          );
        }),
      ));

      await tester.pumpAndSettle();
      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      expect(find.text('确认删除'), findsOneWidget);
      expect(find.text('确定要删除吗？'), findsOneWidget);
      expect(find.text('确定'), findsOneWidget);
      expect(find.text('取消'), findsOneWidget);
    });

    testWidgets('dismisses on cancel', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        home: Builder(builder: (context) {
          return Scaffold(
            body: TextButton(
              onPressed: () => ConfirmDialog.show(
                context,
                title: 'Test',
                message: 'Test msg',
              ),
              child: const Text('Show'),
            ),
          );
        }),
      ));

      await tester.pumpAndSettle();
      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('取消'));
      await tester.pumpAndSettle();

      expect(find.text('Test'), findsNothing);
    });

    testWidgets('dismisses on confirm', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        home: Builder(builder: (context) {
          return Scaffold(
            body: TextButton(
              onPressed: () => ConfirmDialog.show(
                context,
                title: 'Test',
                message: 'Test msg',
              ),
              child: const Text('Show'),
            ),
          );
        }),
      ));

      await tester.pumpAndSettle();
      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('确定'));
      await tester.pumpAndSettle();

      expect(find.text('Test'), findsNothing);
    });

    testWidgets('uses danger color for dangerous actions', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        home: Builder(builder: (context) {
          return Scaffold(
            body: TextButton(
              onPressed: () => ConfirmDialog.show(
                context,
                title: '删除',
                message: '确认删除？',
                isDangerous: true,
                icon: Icons.delete_outline,
              ),
              child: const Text('Show'),
            ),
          );
        }),
      ));

      await tester.pumpAndSettle();
      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });
  });

  group('EmptyState', () {
    testWidgets('shows emoji and title', (tester) async {
      await tester.pumpWidget(wrapWithMaterial(
        const EmptyState(emoji: '📭', title: '没有数据'),
      ));
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('📭'), findsOneWidget);
      expect(find.text('没有数据'), findsOneWidget);
    });

    testWidgets('shows subtitle when provided', (tester) async {
      await tester.pumpWidget(wrapWithMaterial(
        const EmptyState(
          emoji: '📭',
          title: '没有数据',
          subtitle: '点击按钮创建',
        ),
      ));
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('点击按钮创建'), findsOneWidget);
    });

    testWidgets('shows action widget when provided', (tester) async {
      await tester.pumpWidget(wrapWithMaterial(
        const EmptyState(
          emoji: '📭',
          title: '没有数据',
          action: Text('创建'),
        ),
      ));
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('创建'), findsOneWidget);
    });
  });

  group('FeedbackBubble', () {
    testWidgets('renders with success state', (tester) async {
      await tester.pumpWidget(wrapWithMaterial(
        const FeedbackBubble(text: '答对了！✅', isSuccess: true),
      ));

      expect(find.text('答对了！✅'), findsOneWidget);
    });

    testWidgets('renders with error state', (tester) async {
      await tester.pumpWidget(wrapWithMaterial(
        const FeedbackBubble(text: '答错了！❌', isSuccess: false),
      ));

      expect(find.text('答错了！❌'), findsOneWidget);
    });
  });

  group('CountdownNumber', () {
    testWidgets('displays the number', (tester) async {
      await tester.pumpWidget(wrapWithMaterial(
        const CountdownNumber(number: 3),
      ));

      expect(find.text('3'), findsOneWidget);
    });
  });

  group('StreakFire', () {
    testWidgets('shows nothing for streak < 2', (tester) async {
      await tester.pumpWidget(wrapWithMaterial(
        const StreakFire(streak: 0),
      ));

      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('shows nothing for streak of 1', (tester) async {
      await tester.pumpWidget(wrapWithMaterial(
        const StreakFire(streak: 1),
      ));

      expect(find.byType(StreakFire), findsOneWidget);
    });

    testWidgets('shows fire for streak >= 2', (tester) async {
      await tester.pumpWidget(wrapWithMaterial(
        const StreakFire(streak: 3),
      ));

      expect(find.text('🔥'), findsOneWidget);
      expect(find.text('x3'), findsOneWidget);
    });
  });

  group('ShimmerLoading', () {
    testWidgets('shows child when not loading', (tester) async {
      await tester.pumpWidget(wrapWithMaterial(
        const ShimmerLoading(
          isLoading: false,
          child: Text('Content'),
        ),
      ));

      expect(find.text('Content'), findsOneWidget);
    });

    testWidgets('shows child when loading', (tester) async {
      await tester.pumpWidget(wrapWithMaterial(
        const ShimmerLoading(
          isLoading: true,
          child: Text('Shimmer'),
        ),
      ));

      // Child should still be rendered (with shimmer effect overlay)
      expect(find.text('Shimmer'), findsOneWidget);
    });
  });

  group('AppDecorations', () {
    testWidgets('cardDecoration creates valid decoration', (tester) async {
      await tester.pumpWidget(wrapWithMaterial(
        const SizedBox(),
      ));
      final context = tester.element(find.byType(Scaffold));
      final decoration = AppDecorations.cardDecoration(context: context);

      expect(decoration.borderRadius, isNotNull);
      expect(decoration.boxShadow, isNotNull);
    });

    testWidgets('gradientCardDecoration creates valid decoration',
        (tester) async {
      final decoration = AppDecorations.gradientCardDecoration(
        color: AppTheme.primaryColor,
      );

      expect(decoration.borderRadius, isNotNull);
      expect(decoration.gradient, isNotNull);
    });

    testWidgets('pillDecoration creates valid decoration', (tester) async {
      final decoration = AppDecorations.pillDecoration(
        color: AppTheme.accentColor,
      );

      expect(decoration.borderRadius, isNotNull);
    });
  });
}
