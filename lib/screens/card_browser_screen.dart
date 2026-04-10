import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class CardBrowserScreen extends StatefulWidget {
  final CardSetInfo cardSet;
  final List<CardItem> cards;

  const CardBrowserScreen({
    super.key,
    required this.cardSet,
    required this.cards,
  });

  @override
  State<CardBrowserScreen> createState() => _CardBrowserScreenState();
}

class _CardBrowserScreenState extends State<CardBrowserScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  int _currentIndex = 0;
  int _knownCount = 0;
  int _unknownCount = 0;
  bool _showSummary = false;
  double _swipeOffset = 0.0;
  bool _isDragging = false;

  // Game records for mastery info
  List<GameRecordInfo> _gameRecords = [];

  final FlutterTts _tts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _tts.setLanguage('en-US');
    _tts.setSpeechRate(0.5);
    _loadGameRecords();
  }

  Future<void> _loadGameRecords() async {
    try {
      final stats = await ApiService.getGameStats(widget.cardSet.id);
      if (mounted) setState(() => _gameRecords = stats);
    } catch (_) {}
  }

  GameRecordInfo? _getRecordForCard(String cardId) {
    try {
      return _gameRecords.firstWhere((r) => r.card.id == cardId);
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _tts.stop();
    super.dispose();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _swipeOffset += details.delta.dx;
      _isDragging = true;
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (!_isDragging) return;

    final screenWidth = MediaQuery.of(context).size.width;
    final velocity = details.primaryVelocity ?? 0;

    // Swipe left = unknown, swipe right = known
    if (_swipeOffset < -screenWidth * 0.3 || velocity < -500) {
      _markCard('unknown');
    } else if (_swipeOffset > screenWidth * 0.3 || velocity > 500) {
      _markCard('known');
    }

    setState(() {
      _swipeOffset = 0.0;
      _isDragging = false;
    });
  }

  void _markCard(String result) {
    final card = widget.cards[_currentIndex];
    if (result == 'known') {
      _knownCount++;
    } else {
      _unknownCount++;
    }

    // Record to API
    if (result == 'known') {
      ApiService.recordKnown(card.id);
    } else {
      ApiService.recordShown(card.id);
    }

    if (_currentIndex < widget.cards.length - 1) {
      _pageController.nextPage(
        duration: AppTheme.animNormal,
        curve: Curves.easeOut,
      );
    } else {
      // Last card - show summary
      setState(() => _showSummary = true);
    }
  }

  Future<void> _speakWord(String word) async {
    await _tts.speak(word);
  }

  @override
  Widget build(BuildContext context) {
    if (_showSummary) return _buildSummary();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.warmGradient(context),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingMd,
                  vertical: AppTheme.spacingSm,
                ),
                child: Row(
                  children: [
                    // Back button
                    BounceButton(
                      onPressed: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.textHint.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 22,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Mastery stats
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.successColor.withOpacity(0.1),
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusFull),
                        border: Border.all(
                          color: AppTheme.successColor.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle_rounded,
                              color: AppTheme.successColor, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            '$_knownCount/${widget.cards.length}',
                            style: const TextStyle(
                              color: AppTheme.successColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppTheme.spacingSm),

              // Progress bar
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingMd),
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(AppTheme.radiusFull),
                  child: LinearProgressIndicator(
                    value: (_currentIndex + 1) / widget.cards.length,
                    backgroundColor: AppTheme.textHint.withOpacity(0.1),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        AppTheme.primaryColor),
                    minHeight: 6,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  '${_currentIndex + 1} / ${widget.cards.length}',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: AppTheme.spacingMd),

              // Swipe instruction labels
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingXl),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Opacity(
                      opacity: _isDragging && _swipeOffset < -30 ? 1.0 : 0.4,
                      child: Column(
                        children: [
                          Icon(Icons.close_rounded,
                              color: AppTheme.dangerColor, size: 28),
                          const SizedBox(height: 4),
                          Text(
                            '不认识',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.dangerColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Opacity(
                      opacity: _isDragging && _swipeOffset > 30 ? 1.0 : 0.4,
                      child: Column(
                        children: [
                          Icon(Icons.check_rounded,
                              color: AppTheme.successColor, size: 28),
                          const SizedBox(height: 4),
                          Text(
                            '认识',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.successColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppTheme.spacingMd),

              // Card area
              Expanded(
                child: GestureDetector(
                  onHorizontalDragUpdate: _onHorizontalDragUpdate,
                  onHorizontalDragEnd: _onHorizontalDragEnd,
                  child: PageView.builder(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.cards.length,
                    onPageChanged: (index) {
                      setState(() => _currentIndex = index);
                    },
                    itemBuilder: (context, index) {
                      final card = widget.cards[index];
                      final record = _getRecordForCard(card.id);
                      return _SwipeableCard(
                        card: card,
                        swipeOffset: _swipeOffset,
                        isDragging: _isDragging,
                        record: record,
                        onTapWord: () => _speakWord(card.word),
                      );
                    },
                  ),
                ),
              ),

              // Bottom buttons
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacingLg),
                child: Row(
                  children: [
                    Expanded(
                      child: BounceButton(
                        onPressed: () => _markCard('unknown'),
                        child: Container(
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppTheme.dangerColor.withOpacity(0.1),
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusMd),
                            border: Border.all(
                              color: AppTheme.dangerColor.withOpacity(0.2),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.close_rounded,
                                  color: AppTheme.dangerColor, size: 24),
                              SizedBox(width: 8),
                              Text(
                                '不认识',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.dangerColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingMd),
                    Expanded(
                      child: BounceButton(
                        onPressed: () => _speakWord(
                            widget.cards[_currentIndex].word),
                        child: Container(
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppTheme.secondaryColor.withOpacity(0.1),
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusMd),
                            border: Border.all(
                              color:
                                  AppTheme.secondaryColor.withOpacity(0.2),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.volume_up_rounded,
                                  color: AppTheme.secondaryColor,
                                  size: 24),
                              SizedBox(width: 8),
                              Text(
                                '发音',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.secondaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingMd),
                    Expanded(
                      child: BounceButton(
                        onPressed: () => _markCard('known'),
                        child: Container(
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppTheme.successColor.withOpacity(0.1),
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusMd),
                            border: Border.all(
                              color: AppTheme.successColor.withOpacity(0.2),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_rounded,
                                  color: AppTheme.successColor, size: 24),
                              SizedBox(width: 8),
                              Text(
                                '认识',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.successColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummary() {
    final total = _knownCount + _unknownCount;
    final percentage = total > 0 ? ((_knownCount / total) * 100).round() : 0;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.warmGradient(context),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spacingXl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FadeIn(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppTheme.successColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          percentage >= 80 ? '🎉' :
                          percentage >= 50 ? '👍' : '💪',
                          style: const TextStyle(fontSize: 56),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingLg),
                  FadeIn(
                    delay: const Duration(milliseconds: 150),
                    child: Text(
                      '浏览完成！',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingLg),
                  FadeIn(
                    delay: const Duration(milliseconds: 300),
                    child: Container(
                      padding: const EdgeInsets.all(AppTheme.spacingXl),
                      decoration: AppDecorations.cardDecoration(
                        context: context,
                        borderColor:
                            AppTheme.primaryColor.withOpacity(0.08),
                        radius: AppTheme.radiusXl,
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _SummaryStat(
                                  icon: '✅',
                                  label: '认识',
                                  value: '$_knownCount',
                                  color: AppTheme.successColor,
                                ),
                              ),
                              Expanded(
                                child: _SummaryStat(
                                  icon: '❌',
                                  label: '不认识',
                                  value: '$_unknownCount',
                                  color: AppTheme.dangerColor,
                                ),
                              ),
                              Expanded(
                                child: _SummaryStat(
                                  icon: '📊',
                                  label: '正确率',
                                  value: '$percentage%',
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingXl),
                  FadeIn(
                    delay: const Duration(milliseconds: 500),
                    child: BounceButton(
                      onPressed: () => Navigator.pop(context),
                      child: Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppTheme.primaryColor,
                              AppTheme.primaryDark,
                            ],
                          ),
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusMd),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryColor
                                  .withOpacity(0.25),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            '返回',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
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
      ),
    );
  }
}

class _SwipeableCard extends StatelessWidget {
  final CardItem card;
  final double swipeOffset;
  final bool isDragging;
  final GameRecordInfo? record;
  final VoidCallback onTapWord;

  const _SwipeableCard({
    required this.card,
    required this.swipeOffset,
    required this.isDragging,
    required this.record,
    required this.onTapWord,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Clamp rotation to max ~15 degrees
    final rotation = (swipeOffset / screenWidth).clamp(-1.0, 1.0) * 0.26;

    // Determine swipe direction color
    Color? overlayColor;
    IconData? overlayIcon;
    if (isDragging) {
      if (swipeOffset < -30) {
        overlayColor = AppTheme.dangerColor;
        overlayIcon = Icons.close_rounded;
      } else if (swipeOffset > 30) {
        overlayColor = AppTheme.successColor;
        overlayIcon = Icons.check_rounded;
      }
    }

    return Center(
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..rotateZ(rotation)
          ..translate(swipeOffset * 0.3, 0.0),
        child: Container(
          width: screenWidth * 0.85,
          margin: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingMd),
          decoration: AppDecorations.cardDecoration(
            context: context,
            radius: AppTheme.radiusXl,
            blur: 20,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              // Card image
              Expanded(
                flex: 3,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl:
                          '${ApiService.baseUrl}${card.imageUrl}',
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        color: AppTheme.primaryColor.withOpacity(0.04),
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: AppTheme.primaryColor.withOpacity(0.04),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.image_rounded,
                                  size: 48, color: AppTheme.textHint),
                              const SizedBox(height: 8),
                              Text('图片加载失败',
                                  style: TextStyle(
                                      color: AppTheme.textHint)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Swipe direction overlay
                    if (overlayColor != null)
                      Container(
                        color: overlayColor.withOpacity(
                            (swipeOffset.abs() / screenWidth * 0.4)
                                .clamp(0.0, 0.3)),
                        child: Center(
                          child: Icon(
                            overlayIcon,
                            size: 64,
                            color: overlayColor.withOpacity(0.6),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Word + mastery info
              Container(
                padding: const EdgeInsets.symmetric(
                    vertical: AppTheme.spacingLg,
                    horizontal: AppTheme.spacingMd),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: onTapWord,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            card.word,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.volume_up_rounded,
                              size: 20, color: AppTheme.textHint),
                        ],
                      ),
                    ),
                    if (record != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.masteryColor(record!.masteryLevel)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                              AppTheme.radiusFull),
                        ),
                        child: Text(
                          AppTheme.masteryLabel(record!.masteryLevel),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.masteryColor(
                                record!.masteryLevel),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final Color color;

  const _SummaryStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 28)),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
