import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/models.dart';
import '../services/voice_service.dart';
import '../services/share_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class PracticeScreen extends StatefulWidget {
  final List<CardItem> cards;

  const PracticeScreen({super.key, required this.cards});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen>
    with TickerProviderStateMixin {
  final VoiceService _voice = VoiceService();
  final FlutterTts _tts = FlutterTts();
  int _currentIndex = 0;
  bool _isListening = false;
  bool _showResult = false;
  PronunciationScore? _score;
  String _spokenText = '';
  bool _voiceInitialized = false;

  late AnimationController _micController;
  late Animation<double> _micScale;
  late AnimationController _resultController;
  late Animation<double> _resultScale;

  StreamSubscription<VoiceResult>? _voiceSubscription;

  @override
  void initState() {
    super.initState();
    _initServices();
    _micController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _micScale = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _micController, curve: Curves.easeInOut),
    );
    _resultController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _resultScale = CurvedAnimation(
      parent: _resultController,
      curve: Curves.elasticOut,
    );
  }

  Future<void> _initServices() async {
    _tts.setLanguage('en-US');
    _tts.setSpeechRate(0.7);
    _voiceInitialized = await _voice.init();
  }

  Future<void> _playWord() async {
    if (_currentIndex >= widget.cards.length) return;
    await _tts.speak(widget.cards[_currentIndex].word);
  }

  Future<void> _startListening() async {
    if (!_voiceInitialized || _isListening) return;

    setState(() {
      _isListening = true;
      _showResult = false;
      _spokenText = '';
      _score = null;
    });
    _micController.repeat(reverse: true);

    _voiceSubscription = _voice.onResult.listen((result) {
      if (!mounted) return;
      setState(() => _spokenText = result.text);

      if (result.isFinal) {
        _stopListeningAndEvaluate();
      }
    });

    await _voice.startListening();
  }

  Future<void> _stopListeningAndEvaluate() async {
    await _voice.stopListening();
    _micController.stop();

    if (!mounted) return;

    final card = widget.cards[_currentIndex];
    final score = _voice.evaluatePronunciation(card.word, _spokenText);

    setState(() {
      _isListening = false;
      _showResult = true;
      _score = score;
    });

    _resultController.forward(from: 0);
    _voiceSubscription?.cancel();
  }

  void _nextCard() {
    if (_currentIndex < widget.cards.length - 1) {
      setState(() {
        _currentIndex++;
        _showResult = false;
        _score = null;
        _spokenText = '';
      });
    }
  }

  void _prevCard() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _showResult = false;
        _score = null;
        _spokenText = '';
      });
    }
  }

  @override
  void dispose() {
    _voiceSubscription?.cancel();
    _voice.dispose();
    _tts.stop();
    _micController.dispose();
    _resultController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final card = widget.cards[_currentIndex];
    final progress = (_currentIndex + 1) / widget.cards.length;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.textHint.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('发音练习'),
        actions: [
          BounceButton(
            onPressed: () => ShareService.shareWordCard(
              word: card.word,
              cardSetName: '发音练习',
            ),
            child: Container(
              margin: const EdgeInsets.only(right: AppTheme.spacingSm),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              ),
              child: const Icon(Icons.share_rounded,
                  color: AppTheme.primaryColor, size: 18),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress bar
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingMd,
              vertical: AppTheme.spacingSm,
            ),
            child: Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppTheme.primaryColor),
                      minHeight: 6,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${_currentIndex + 1}/${widget.cards.length}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Card display
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              child: Column(
                children: [
                  const SizedBox(height: AppTheme.spacingMd),

                  // Word card
                  FadeIn(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppTheme.spacingXl),
                      decoration: AppDecorations.cardDecoration(
                        context,
                        radius: AppTheme.radiusXl,
                      ),
                      child: Column(
                        children: [
                          Text(
                            card.word,
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacingMd),
                          BounceButton(
                            onPressed: _playWord,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.08),
                                borderRadius:
                                    BorderRadius.circular(AppTheme.radiusFull),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.volume_up_rounded,
                                      color: AppTheme.primaryColor, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    '听发音',
                                    style: TextStyle(
                                      color: AppTheme.primaryColor,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppTheme.spacingXl),

                  // Microphone button
                  AnimatedBuilder(
                    animation: _micScale,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _isListening ? _micScale.value : 1.0,
                        child: child,
                      );
                    },
                    child: GestureDetector(
                      onTap: _isListening
                          ? _stopListeningAndEvaluate
                          : _startListening,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: _isListening
                              ? AppTheme.dangerColor
                              : AppTheme.primaryColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: (_isListening
                                      ? AppTheme.dangerColor
                                      : AppTheme.primaryColor)
                                  .withOpacity(0.3),
                              blurRadius: _isListening ? 30 : 16,
                              spreadRadius: _isListening ? 4 : 0,
                            ),
                          ],
                        ),
                        child: Center(
                          child: _isListening
                              ? Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(Icons.stop_rounded,
                                        color: Colors.white, size: 36),
                                    SizedBox(height: 4),
                                    Text(
                                      '停止',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(Icons.mic_rounded,
                                        color: Colors.white, size: 40),
                                    SizedBox(height: 2),
                                    Text(
                                      '按住说话',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ),

                  if (!_voiceInitialized) ...[
                    const SizedBox(height: 12),
                    Text(
                      '语音识别未就绪，请检查权限',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.dangerColor,
                      ),
                    ),
                  ],

                  // Spoken text display
                  if (_spokenText.isNotEmpty) ...[
                    const SizedBox(height: AppTheme.spacingLg),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppTheme.spacingMd),
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryColor.withOpacity(0.06),
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMd),
                        border: Border.all(
                          color: AppTheme.secondaryColor.withOpacity(0.15),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '你说的是:',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _spokenText,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.secondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Result display
                  if (_showResult && _score != null) ...[
                    const SizedBox(height: AppTheme.spacingLg),
                    ScaleTransition(
                      scale: _resultScale,
                      child: _buildResultCard(),
                    ),
                  ],

                  const SizedBox(height: AppTheme.spacingXl),

                  // Navigation
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      BounceButton(
                        onPressed:
                            _currentIndex > 0 ? _prevCard : null,
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppTheme.textHint.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back_rounded,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingXl),
                      Text(
                        '${_currentIndex + 1}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingXl),
                      BounceButton(
                        onPressed: _currentIndex < widget.cards.length - 1
                            ? _nextCard
                            : null,
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.08),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_forward_rounded,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    final score = _score!;
    final gradeColor = switch (score.grade) {
      PronunciationGrade.excellent => AppTheme.successColor,
      PronunciationGrade.good => AppTheme.primaryColor,
      PronunciationGrade.okay => AppTheme.accentDark,
      PronunciationGrade.poor => AppTheme.warningColor,
      PronunciationGrade.none => AppTheme.dangerColor,
    };

    final gradeEmoji = switch (score.grade) {
      PronunciationGrade.excellent => '🌟',
      PronunciationGrade.good => '👍',
      PronunciationGrade.okay => '💪',
      PronunciationGrade.poor => '🔄',
      PronunciationGrade.none => '🎧',
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      decoration: BoxDecoration(
        color: gradeColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(color: gradeColor.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(gradeEmoji, style: const TextStyle(fontSize: 40)),
          const SizedBox(height: 8),
          Text(
            score.feedback,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: gradeColor,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${(score.score * 100).round()}分',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: gradeColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: score.score,
              backgroundColor: gradeColor.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(gradeColor),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}
