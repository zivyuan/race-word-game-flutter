import 'package:flutter_test/flutter_test.dart';
import 'package:race_word_game/services/voice_service.dart';

void main() {
  late VoiceService voiceService;

  setUp(() {
    voiceService = VoiceService();
  });

  group('VoiceService - evaluatePronunciation', () {
    test('exact match returns excellent score', () {
      final result = voiceService.evaluatePronunciation('apple', 'apple');
      expect(result.score, 1.0);
      expect(result.grade, PronunciationGrade.excellent);
      expect(result.feedback, '发音完美！太棒了！');
    });

    test('case insensitive exact match', () {
      final result = voiceService.evaluatePronunciation('Apple', 'APPLE');
      expect(result.score, 1.0);
      expect(result.grade, PronunciationGrade.excellent);
    });

    test('spoken contains expected word returns good score', () {
      final result =
          voiceService.evaluatePronunciation('apple', 'I want an apple');
      expect(result.score, 0.9);
      expect(result.grade, PronunciationGrade.good);
      expect(result.feedback, '很好！非常接近！');
    });

    test('similar word returns okay score', () {
      final result =
          voiceService.evaluatePronunciation('banana', 'bananna');
      expect(result.grade, PronunciationGrade.okay);
      expect(result.score, greaterThanOrEqualTo(0.7));
    });

    test('somewhat similar returns poor score', () {
      final result =
          voiceService.evaluatePronunciation('elephant', 'elfant');
      expect(result.grade, PronunciationGrade.poor);
    });

    test('completely different returns none grade', () {
      final result = voiceService.evaluatePronunciation('cat', 'dog');
      expect(result.grade, PronunciationGrade.none);
    });

    test('empty spoken returns none grade', () {
      final result = voiceService.evaluatePronunciation('apple', '');
      expect(result.score, 0.0);
      expect(result.grade, PronunciationGrade.none);
      expect(result.feedback, '没有检测到语音');
    });

    test('whitespace trimming works', () {
      final result =
          voiceService.evaluatePronunciation('apple', '  apple  ');
      expect(result.score, 1.0);
    });
  });

  group('VoiceService - Levenshtein distance', () {
    test('identical strings return 0', () {
      final result = voiceService.evaluatePronunciation('hello', 'hello');
      expect(result.score, 1.0);
    });

    test('one character difference', () {
      final result = voiceService.evaluatePronunciation('cat', 'bat');
      expect(result.score, greaterThan(0.5));
    });

    test('completely different lengths', () {
      final result = voiceService.evaluatePronunciation('a', 'abcdefghijklmnopqrstuvwxyz');
      // Levenshtein similarity with very short expected and long spoken
      expect(result.score, lessThan(1.0));
      expect(result.grade, PronunciationGrade.none);
    });
  });

  group('VoiceResult', () {
    test('creates with all fields', () {
      final result = VoiceResult(
        text: 'hello',
        confidence: 0.95,
        isFinal: true,
        isError: false,
      );
      expect(result.text, 'hello');
      expect(result.confidence, 0.95);
      expect(result.isFinal, true);
      expect(result.isError, false);
    });

    test('creates error result', () {
      final result = VoiceResult(
        text: '',
        confidence: 0,
        isFinal: true,
        isError: true,
      );
      expect(result.isError, true);
    });
  });

  group('PronunciationScore', () {
    test('creates with all fields', () {
      final score = PronunciationScore(
        score: 0.85,
        feedback: '不错',
        grade: PronunciationGrade.okay,
      );
      expect(score.score, 0.85);
      expect(score.feedback, '不错');
      expect(score.grade, PronunciationGrade.okay);
    });
  });

  group('PronunciationGrade', () {
    test('has correct ordering', () {
      expect(PronunciationGrade.none.index, lessThan(PronunciationGrade.poor.index));
      expect(PronunciationGrade.poor.index, lessThan(PronunciationGrade.okay.index));
      expect(PronunciationGrade.okay.index, lessThan(PronunciationGrade.good.index));
      expect(PronunciationGrade.good.index, lessThan(PronunciationGrade.excellent.index));
    });

    test('has 5 levels', () {
      expect(PronunciationGrade.values.length, 5);
    });
  });
}
