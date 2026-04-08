import 'package:flutter_test/flutter_test.dart';

/// Pure logic tests for game mechanics without widget dependencies.
/// These test the business rules that GameScreen implements.

void main() {
  group('Game accuracy calculation', () {
    int calculateAccuracy(int score, int total) {
      if (total <= 0) return 0;
      return (score / total * 100).round();
    }

    test('perfect score returns 100%', () {
      expect(calculateAccuracy(10, 10), 100);
    });

    test('zero score returns 0%', () {
      expect(calculateAccuracy(0, 10), 0);
    });

    test('half score returns 50%', () {
      expect(calculateAccuracy(5, 10), 50);
    });

    test('zero total returns 0%', () {
      expect(calculateAccuracy(0, 0), 0);
    });

    test('rounds correctly', () {
      expect(calculateAccuracy(1, 3), 33);
      expect(calculateAccuracy(2, 3), 67);
    });
  });

  group('Game result emoji', () {
    String resultEmoji(int accuracy) {
      if (accuracy >= 80) return '🎉';
      if (accuracy >= 50) return '👍';
      return '💪';
    }

    test('80%+ returns celebration', () {
      expect(resultEmoji(80), '🎉');
      expect(resultEmoji(100), '🎉');
    });

    test('50-79% returns thumbs up', () {
      expect(resultEmoji(50), '👍');
      expect(resultEmoji(79), '👍');
    });

    test('below 50% returns flex', () {
      expect(resultEmoji(49), '💪');
      expect(resultEmoji(0), '💪');
    });
  });

  group('Game end condition', () {
    // Game ends after cards.length * 2 rounds
    int maxRounds(int cardCount) => cardCount * 2;

    test('2 cards ends after 4 rounds', () {
      expect(maxRounds(2), 4);
    });

    test('5 cards ends after 10 rounds', () {
      expect(maxRounds(5), 10);
    });

    test('1 card ends after 2 rounds', () {
      expect(maxRounds(1), 2);
    });
  });

  group('Game minimum cards requirement', () {
    bool canStartGame(int cardCount) => cardCount >= 2;

    test('0 cards cannot start', () {
      expect(canStartGame(0), false);
    });

    test('1 card cannot start', () {
      expect(canStartGame(1), false);
    });

    test('2 cards can start', () {
      expect(canStartGame(2), true);
    });

    test('10 cards can start', () {
      expect(canStartGame(10), true);
    });
  });

  group('Streak feedback text', () {
    String feedbackText(bool correct, int streak) {
      if (correct) {
        return streak > 1 ? '连续答对 $streak 次！🔥' : '答对了！✅';
      }
      return '正确答案是: ...';
    }

    test('first correct answer', () {
      expect(feedbackText(true, 1), '答对了！✅');
    });

    test('streak of 2', () {
      expect(feedbackText(true, 2), '连续答对 2 次！🔥');
    });

    test('streak of 5', () {
      expect(feedbackText(true, 5), '连续答对 5 次！🔥');
    });

    test('wrong answer resets feedback', () {
      expect(feedbackText(false, 0), '正确答案是: ...');
    });
  });

  group('Mastery level calculation', () {
    // Backend logic: timesKnown >= 5 => mastered, timesShown > 0 => learning, else new
    String masteryLevel(int timesShown, int timesKnown) {
      if (timesKnown >= 5) return 'mastered';
      if (timesShown > 0) return 'learning';
      return 'new';
    }

    test('never seen is new', () {
      expect(masteryLevel(0, 0), 'new');
    });

    test('seen once but never correct is learning', () {
      expect(masteryLevel(1, 0), 'learning');
    });

    test('seen 5 times but only 4 correct is learning', () {
      expect(masteryLevel(5, 4), 'learning');
    });

    test('5 correct is mastered', () {
      expect(masteryLevel(5, 5), 'mastered');
    });

    test('10 correct is mastered', () {
      expect(masteryLevel(10, 10), 'mastered');
    });
  });
}
