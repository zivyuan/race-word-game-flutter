import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

enum GamePhase { idle, countdown, playing, result }

class GameScreen extends StatefulWidget {
  final CardSetInfo cardSet;
  final List<CardItem> cards;

  const GameScreen({super.key, required this.cardSet, required this.cards});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  GamePhase _phase = GamePhase.idle;
  final FlutterTts _tts = FlutterTts();
  int _countdown = 5;
  CardItem? _currentCard;
  int _score = 0;
  int _total = 0;
  int _streak = 0;
  bool _showFeedback = false;
  String _feedbackText = '';
  Color _feedbackColor = Colors.transparent;
  Timer? _timer;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _initTts();
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
      _score = 0;
      _total = 0;
      _streak = 0;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _countdown--;
      });
      if (_countdown <= 0) {
        timer.cancel();
        _startPlaying();
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
        _feedbackText = _streak > 1 ? '连续答对 $_streak 次！🔥' : '答对了！✅';
        _feedbackColor = AppTheme.successColor;
      } else {
        _streak = 0;
        _feedbackText = '正确答案是: ${_currentCard!.word}';
        _feedbackColor = AppTheme.dangerColor;
      }
    });

    // 记录到后端
    try {
      await ApiService.recordShown(_currentCard!.id);
      if (correct) {
        await ApiService.recordKnown(_currentCard!.id);
      }
    } catch (_) {}

    // 2秒后下一题或结束
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
    setState(() => _phase = GamePhase.result);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _tts.stop();
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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🎯', style: TextStyle(fontSize: 80)),
                const SizedBox(height: 16),
                Text(
                  widget.cardSet.name,
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.cards.length} 张卡片',
                  style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.8)),
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: 200,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: widget.cards.length >= 2 ? _startCountdown : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primaryColor,
                      disabledBackgroundColor: Colors.white.withOpacity(0.3),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(
                      widget.cards.length < 2 ? '至少需要 2 张卡片' : '开始游戏 🚀',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$_countdown',
                style: const TextStyle(fontSize: 120, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text(
                _countdown > 3 ? '准备好了吗？' : _countdown > 1 ? '3...' : '开始！',
                style: TextStyle(fontSize: 24, color: Colors.white.withOpacity(0.9)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaying() {
    return Container(
      color: const Color(0xFFFFFBFE),
      child: SafeArea(
        child: Column(
          children: [
            // Score bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.white,
              child: Row(
                children: [
                  Text('🎯 $_score/$_total', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 16),
                  if (_streak > 1)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('🔥 x$_streak', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.accentColor)),
                    ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.volume_up, color: AppTheme.primaryColor),
                    onPressed: () {
                      if (_currentCard != null) _tts.speak(_currentCard!.word);
                    },
                  ),
                ],
              ),
            ),
            // Prompt
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: const Text(
                '🎧 听到单词后，点击对应的卡片！',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
            // Feedback overlay
            if (_showFeedback)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: _feedbackColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _feedbackText,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: _feedbackColor),
                ),
              ),
            const SizedBox(height: 8),
            // Card grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemCount: widget.cards.length,
                itemBuilder: (context, index) {
                  final card = widget.cards[index];
                  return GestureDetector(
                    onTap: () => _onCardTapped(card),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[200]!),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: Image.network(
                              '${ApiService.baseUrl}${card.imageUrl}',
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: Colors.grey[200],
                                child: const Icon(Icons.image, size: 40, color: Colors.grey),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              card.word,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
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

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 80)),
                const SizedBox(height: 16),
                const Text('游戏结束！', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      _StatRow(label: '总题数', value: '$_total'),
                      _StatRow(label: '答对', value: '$_score'),
                      _StatRow(label: '正确率', value: '$accuracy%'),
                      _StatRow(label: '最高连续', value: '$_streak'),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text('返回', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _startCountdown,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppTheme.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text('再来一局', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.8))),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
    );
  }
}
