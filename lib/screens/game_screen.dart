import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

enum GamePhase { idle, countdown, playing, result }

class GameScreen extends StatefulWidget {
  final CardSetInfo cardSet;
  final List<CardItem> cards;

  const GameScreen({super.key, required this.cardSet, required this.cards});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with TickerProviderStateMixin {
  GamePhase _phase = GamePhase.idle;
  final FlutterTts _tts = FlutterTts();
  int _countdown = 5;
  CardItem? _currentCard;
  int _score = 0;
  int _total = 0;
  int _streak = 0;
  int _maxStreak = 0;
  bool _showFeedback = false;
  String _feedbackText = '';
  Color _feedbackColor = Colors.transparent;
  Timer? _timer;
  final Random _random = Random();

  // 倒计时 key 用于触发动画重建
  int _countdownKey = 0;

  // 结果页动画
  late AnimationController _resultController;
  late Animation<double> _resultScale;

  @override
  void initState() {
    super.initState();
    _initTts();
    _resultController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _resultScale = CurvedAnimation(
      parent: _resultController,
      curve: Curves.elasticOut,
    );
  }

  void _initTts() {
    _tts.setLanguage('en-US');
    _tts.setSpeechRate(0.8);
    _tts.setVolume(1.0);
  }

  void _startCountdown() {
    setState(() {
      _phase = GamePhase.countdown;
      _countdown = 5;
      _countdownKey = 0;
      _score = 0;
      _total = 0;
      _streak = 0;
      _maxStreak = 0;
    });
    _tickCountdown();
  }

  void _tickCountdown() {
    _timer = Timer(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        _countdown--;
        _countdownKey++;
      });
      if (_countdown <= 0) {
        _startPlaying();
      } else {
        _tickCountdown();
      }
    });
  }

  void _startPlaying() {
    if (widget.cards.isEmpty) return;
    setState(() => _phase = GamePhase.playing);
    _speakRandomCard();
  }

  void _speakRandomCard() {
    final index = _random.nextInt(widget.cards.length);
    setState(() {
      _currentCard = widget.cards[index];
      _showFeedback = false;
    });
    _tts.speak(_currentCard!.word);
  }

  Future<void> _onCardTapped(CardItem card) async {
    if (_currentCard == null || _showFeedback) return;

    final correct = card.id == _currentCard!.id;
    setState(() {
      _total++;
      _showFeedback = true;
      if (correct) {
        _score++;
        _streak++;
        if (_streak > _maxStreak) _maxStreak = _streak;
        _feedbackText = _streak > 1 ? '连续答对 $_streak 次！🔥' : '答对了！✅';
        _feedbackColor = AppTheme.successColor;
      } else {
        _streak = 0;
        _feedbackText = '正确答案: ${_currentCard!.word}';
        _feedbackColor = AppTheme.dangerColor;
      }
    });

    try {
      await ApiService.recordShown(_currentCard!.id);
      if (correct) {
        await ApiService.recordKnown(_currentCard!.id);
      }
    } catch (_) {}

    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      if (_total >= widget.cards.length * 2) {
        _endGame();
      } else {
        _speakRandomCard();
      }
    });
  }

  void _endGame() {
    _resultController.forward(from: 0);
    setState(() => _phase = GamePhase.result);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _tts.stop();
    _resultController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: switch (_phase) {
        GamePhase.idle => _buildIdle(),
        GamePhase.countdown => _buildCountdown(),
        GamePhase.playing => _buildPlaying(),
        GamePhase.result => _buildResult(),
      },
    );
  }

  Widget _buildIdle() {
    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.gameGradient),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingXl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FadeIn(
                  child: PulseAnimation(
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 3,
                        ),
                      ),
                      child: const Center(
                        child: Text('🎯', style: TextStyle(fontSize: 64)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingXl),
                FadeIn(
                  delay: const Duration(milliseconds: 200),
                  child: Text(
                    widget.cardSet.name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingSm),
                FadeIn(
                  delay: const Duration(milliseconds: 300),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingLg,
                        vertical: AppTheme.spacingSm),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusFull),
                    ),
                    child: Text(
                      '${widget.cards.length} 张卡片',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.85),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingXxl),
                FadeIn(
                  delay: const Duration(milliseconds: 500),
                  child: BounceButton(
                    onPressed: widget.cards.length >= 2
                        ? _startCountdown
                        : null,
                    child: AnimatedContainer(
                      duration: AppTheme.animNormal,
                      width: 200,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusXl),
                        boxShadow: widget.cards.length >= 2
                            ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          widget.cards.length < 2
                              ? '至少需要 2 张卡片'
                              : '开始游戏 🚀',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: widget.cards.length < 2
                                ? AppTheme.textHint
                                : AppTheme.primaryColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCountdown() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: isDark
            ? const LinearGradient(
                colors: [Color(0xFF1A1A2E), Color(0xFF16213E)])
            : AppTheme.gameGradient,
      ),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CountdownNumber(
                key: ValueKey(_countdownKey),
                number: _countdown,
              ),
              const SizedBox(height: AppTheme.spacingMd),
              FadeIn(
                key: ValueKey(_countdownKey),
                duration: const Duration(milliseconds: 200),
                child: Text(
                  _countdown > 3
                      ? '准备好了吗？'
                      : _countdown > 1
                          ? '${_countdown - 1}...'
                          : '开始！',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacingLg),
              Text(
                '🎧 听到单词后，点击对应卡片',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaying() {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Score bar
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingMd,
                  vertical: AppTheme.spacingSm),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF16213E)
                    : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.08),
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusFull),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🎯', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 4),
                        Text(
                          '$_score / $_total',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingSm),
                  StreakFire(streak: _streak),
                  const Spacer(),
                  BounceButton(
                    onPressed: () {
                      if (_currentCard != null) {
                        _tts.speak(_currentCard!.word);
                      }
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.volume_up_rounded,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Prompt
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                '🎧 听到单词后，点击对应的卡片！',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            // Feedback overlay
            if (_showFeedback)
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingMd),
                child: FeedbackBubble(
                  key: ValueKey(_total),
                  text: _feedbackText,
                  isSuccess: _feedbackColor == AppTheme.successColor,
                ),
              ),
            if (_showFeedback) const SizedBox(height: 8),
            // Card grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(AppTheme.spacingMd),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.82,
                ),
                itemCount: widget.cards.length,
                itemBuilder: (context, index) {
                  final card = widget.cards[index];
                  return BounceButton(
                    onPressed: () => _onCardTapped(card),
                    child: Container(
                      decoration: AppDecorations.cardDecoration(
                        context: context,
                        radius: AppTheme.radiusLg,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: CachedNetworkImage(
                              imageUrl:
                                  '${ApiService.baseUrl}${card.imageUrl}',
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(
                                color: AppTheme.primaryColor
                                    .withOpacity(0.04),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppTheme.primaryColor),
                                ),
                              ),
                              errorWidget: (_, __, ___) => Container(
                                color: AppTheme.primaryColor
                                    .withOpacity(0.04),
                                child: const Center(
                                  child: Icon(Icons.image_rounded,
                                      size: 36,
                                      color: AppTheme.textHint),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 8),
                            child: Text(
                              card.word,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResult() {
    final accuracy = _total > 0 ? (_score / _total * 100).round() : 0;
    final emoji = accuracy >= 80 ? '🎉' : accuracy >= 50 ? '👍' : '💪';
    final message = accuracy >= 80
        ? '太棒了！你是单词小天才！'
        : accuracy >= 50
            ? '做得不错，继续加油！'
            : '别灰心，多练习几次就好了！';

    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.gameGradient),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacingXl),
            child: ScaleTransition(
              scale: _resultScale,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PulseAnimation(
                    child: Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.25),
                          width: 3,
                        ),
                      ),
                      child: Center(
                        child: Text(emoji,
                            style: const TextStyle(fontSize: 64)),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingXl),
                  const Text(
                    '游戏结束！',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingSm),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.85),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingXl),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppTheme.spacingXl),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusXl),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.15)),
                    ),
                    child: Column(
                      children: [
                        _StatRow(
                            icon: '📝', label: '总题数', value: '$_total'),
                        const Divider(color: Colors.white12, height: 24),
                        _StatRow(
                            icon: '✅', label: '答对', value: '$_score'),
                        const Divider(color: Colors.white12, height: 24),
                        _StatRow(
                            icon: '📊',
                            label: '正确率',
                            value: '$accuracy%'),
                        const Divider(color: Colors.white12, height: 24),
                        _StatRow(
                            icon: '🔥',
                            label: '最高连续',
                            value: '$_maxStreak'),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingXxl),
                  Row(
                    children: [
                      Expanded(
                        child: BounceButton(
                          onPressed: () => Navigator.pop(context),
                          child: Container(
                            height: 52,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(
                                  AppTheme.radiusMd),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.3)),
                            ),
                            child: const Center(
                              child: Text(
                                '返回',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingMd),
                      Expanded(
                        child: BounceButton(
                          onPressed: _startCountdown,
                          child: Container(
                            height: 52,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(
                                  AppTheme.radiusMd),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 16,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                '再来一局',
                                style: TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String icon;
  final String label;
  final String value;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.75),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
