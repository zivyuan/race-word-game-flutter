import 'dart:async';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceService {
  static final VoiceService _instance = VoiceService._();
  factory VoiceService() => _instance;
  VoiceService._();

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _initialized = false;
  bool _isListening = false;
  String _lastWords = '';
  double _confidence = 0.0;
  final _resultController = StreamController<VoiceResult>.broadcast();

  bool get isListening => _isListening;
  String get lastWords => _lastWords;
  double get confidence => _confidence;
  Stream<VoiceResult> get onResult => _resultController.stream;

  Future<bool> init() async {
    if (_initialized) return true;
    _initialized = await _speech.initialize(
      onStatus: _onStatus,
      onError: _onError,
    );
    return _initialized;
  }

  void _onStatus(String status) {
    if (status == 'done' || status == 'notListening') {
      _isListening = false;
    }
  }

  void _onError(dynamic error) {
    _isListening = false;
    _resultController.add(VoiceResult(
      text: '',
      confidence: 0,
      isFinal: true,
      isError: true,
    ));
  }

  /// Start listening for speech in English
  Future<void> startListening({String languageId = 'en-US'}) async {
    if (!_initialized) {
      final ok = await init();
      if (!ok) return;
    }

    _isListening = true;
    _lastWords = '';
    _confidence = 0.0;

    await _speech.listen(
      onResult: (result) {
        _lastWords = result.recognizedWords;
        _confidence = result.confidence;

        _resultController.add(VoiceResult(
          text: result.recognizedWords,
          confidence: result.confidence,
          isFinal: result.finalResult,
          isError: false,
        ));
      },
      localeId: languageId,
      listenMode: stt.ListenMode.dictation,
      partialResults: true,
      cancelOnError: true,
    );
  }

  /// Stop listening
  Future<void> stopListening() async {
    await _speech.stop();
    _isListening = false;
  }

  /// Evaluate pronunciation by comparing spoken word with expected word
  /// Returns a score from 0.0 to 1.0
  PronunciationScore evaluatePronunciation(String expected, String spoken) {
    if (spoken.isEmpty) {
      return PronunciationScore(score: 0.0, feedback: '没有检测到语音', grade: PronunciationGrade.none);
    }

    final expectedLower = expected.toLowerCase().trim();
    final spokenLower = spoken.toLowerCase().trim();

    // Exact match
    if (expectedLower == spokenLower) {
      return PronunciationScore(
        score: 1.0,
        feedback: '发音完美！太棒了！',
        grade: PronunciationGrade.excellent,
      );
    }

    // Check if spoken contains the expected word
    if (spokenLower.contains(expectedLower)) {
      return PronunciationScore(
        score: 0.9,
        feedback: '很好！非常接近！',
        grade: PronunciationGrade.good,
      );
    }

    // Levenshtein distance for fuzzy matching
    final distance = _levenshteinDistance(expectedLower, spokenLower);
    final maxLen = expectedLower.length > spokenLower.length
        ? expectedLower.length
        : spokenLower.length;
    final similarity = 1.0 - (distance / maxLen);

    if (similarity >= 0.7) {
      return PronunciationScore(
        score: similarity,
        feedback: '不错，再练习一下！',
        grade: PronunciationGrade.okay,
      );
    } else if (similarity >= 0.4) {
      return PronunciationScore(
        score: similarity,
        feedback: '再试一次，你可以的！',
        grade: PronunciationGrade.poor,
      );
    } else {
      return PronunciationScore(
        score: similarity,
        feedback: '再听一遍，跟着读吧！',
        grade: PronunciationGrade.none,
      );
    }
  }

  int _levenshteinDistance(String a, String b) {
    if (a == b) return 0;
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;

    List<int> prev = List<int>.generate(b.length + 1, (i) => i);
    List<int> curr = List<int>.filled(b.length + 1, 0);

    for (int i = 1; i <= a.length; i++) {
      curr[0] = i;
      for (int j = 1; j <= b.length; j++) {
        int cost = a[i - 1] == b[j - 1] ? 0 : 1;
        curr[j] = [
          prev[j] + 1,      // deletion
          curr[j - 1] + 1,  // insertion
          prev[j - 1] + cost, // substitution
        ].reduce((a, b) => a < b ? a : b);
      }
      prev = List<int>.from(curr);
    }
    return prev[b.length];
  }

  void dispose() {
    _resultController.close();
  }
}

class VoiceResult {
  final String text;
  final double confidence;
  final bool isFinal;
  final bool isError;

  VoiceResult({
    required this.text,
    required this.confidence,
    required this.isFinal,
    this.isError = false,
  });
}

class PronunciationScore {
  final double score;
  final String feedback;
  final PronunciationGrade grade;

  PronunciationScore({
    required this.score,
    required this.feedback,
    required this.grade,
  });
}

enum PronunciationGrade {
  none,     // Score < 0.4
  poor,     // Score 0.4 - 0.7
  okay,     // Score 0.7 - 0.9
  good,     // Score 0.9 - 1.0 (contains)
  excellent, // Score 1.0 (exact)
}
