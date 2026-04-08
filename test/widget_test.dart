import 'package:flutter_test/flutter_test.dart';
import 'package:race_word_game/main.dart';

void main() {
  testWidgets('App renders', (WidgetTester tester) async {
    await tester.pumpWidget(const RaceWordGameApp());
    // Just verify no crash
  });
}
