import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import 'game_screen.dart';

class CardSetDetailScreen extends StatefulWidget {
  final CardSetInfo cardSet;

  const CardSetDetailScreen({super.key, required this.cardSet});

  @override
  State<CardSetDetailScreen> createState() => _CardSetDetailScreenState();
}

class _CardSetDetailScreenState extends State<CardSetDetailScreen> {
  List<CardItem> _cards = [];
  bool _loading = true;
  bool _addingCard = false;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    try {
      final cards = await ApiService.getCards(widget.cardSet.id);
      setState(() {
        _cards = cards;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        FriendlyErrorDialog.show(
          context,
          message: '加载卡片失败了，请检查网络连接',
          onRetry: () {
            Navigator.pop(context);
            setState(() => _loading = true);
            _loadCards();
          },
        );
      }
    }
  }

  Future<void> _addCard() async {
    if (_addingCard) return;
    setState(() => _addingCard = true);

    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (image == null) {
        setState(() => _addingCard = false);
        return;
      }

      if (!mounted) return;
      final word = await showDialog<String>(
        context: context,
        builder: (ctx) {
          final controller = TextEditingController();
          return Dialog(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingXl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.text_fields_rounded,
                      color: AppTheme.primaryColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingLg),
                  const Text(
                    '输入英文单词',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  TextField(
                    controller: controller,
                    autofocus: true,
                    decoration: const InputDecoration(hintText: '例如：apple'),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (v) => Navigator.pop(ctx, v.trim()),
                  ),
                  const SizedBox(height: AppTheme.spacingLg),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('取消'),
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingMd),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () =>
                              Navigator.pop(ctx, controller.text.trim()),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('确定'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );

      if (word == null || word.isEmpty) {
        setState(() => _addingCard = false);
        return;
      }

      await ApiService.createCard(widget.cardSet.id, word, image.path);
      if (mounted) _loadCards();
    } catch (e) {
      if (mounted) {
        FriendlyErrorDialog.show(
          context,
          message: '添加卡片失败了，请重试',
          onRetry: () {
            Navigator.pop(context);
            _addCard();
          },
        );
      }
    } finally {
      if (mounted) setState(() => _addingCard = false);
    }
  }

  Future<void> _deleteCard(String id) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: '删除卡片',
      message: '确定要删除这张卡片吗？删除后无法恢复。',
      confirmText: '删除',
      isDangerous: true,
      icon: Icons.delete_outline,
    );
    if (confirmed != true) return;
    try {
      await ApiService.deleteCard(id);
      _loadCards();
    } catch (e) {
      if (mounted) {
        FriendlyErrorDialog.show(
          context,
          message: '删除失败了，请稍后重试',
          onRetry: () {
            Navigator.pop(context);
            _deleteCard(id);
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
        title: Text(widget.cardSet.name),
        actions: [
          if (_cards.isNotEmpty)
            BounceButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GameScreen(
                        cardSet: widget.cardSet, cards: _cards),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(right: AppTheme.spacingSm),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
                  children: const [
                    Icon(Icons.play_arrow_rounded,
                        color: AppTheme.successColor, size: 22),
                    SizedBox(width: 4),
                    Text(
                      '开始',
                      style: TextStyle(
                        color: AppTheme.successColor,
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
      body: _loading
          ? const Center(child: FunLoadingIndicator(message: '加载中'))
          : Column(
              children: [
                // Stats bar
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingLg,
                      vertical: AppTheme.spacingMd),
                  margin: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingMd,
                      vertical: AppTheme.spacingSm),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.05),
                    borderRadius:
                        BorderRadius.circular(AppTheme.radiusFull),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.style_rounded,
                          size: 16, color: AppTheme.primaryColor),
                      const SizedBox(width: 6),
                      Text(
                        '共 ${_cards.length} 张卡片',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Cards grid
                Expanded(
                  child: _cards.isEmpty
                      ? EmptyState(
                          emoji: '📷',
                          title: '还没有卡片',
                          subtitle: '点击下方按钮拍照添加第一张卡片吧！',
                          action: BounceButton(
                            onPressed: _addCard,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppTheme.spacingXl,
                                  vertical: 14),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    AppTheme.primaryColor,
                                    AppTheme.primaryDark,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(
                                    AppTheme.radiusFull),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primaryColor
                                        .withOpacity(0.25),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: const Text(
                                '拍照添加第一张',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(AppTheme.spacingMd),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.78,
                          ),
                          itemCount: _cards.length,
                          itemBuilder: (context, index) {
                            final card = _cards[index];
                            return FadeIn(
                              delay: Duration(
                                  milliseconds: 60 * (index % 8)),
                              slideOffset: const Offset(0, 0.1),
                              child: GestureDetector(
                                onLongPress: () => _deleteCard(card.id),
                                child: Container(
                                  decoration: AppDecorations
                                      .cardDecoration(context: context),
                                  clipBehavior: Clip.antiAlias,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Expanded(
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            CachedNetworkImage(
                                              imageUrl:
                                                  '${ApiService.baseUrl}${card.imageUrl}',
                                              fit: BoxFit.cover,
                                              placeholder: (_, __) =>
                                                  Container(
                                                color: AppTheme.primaryColor
                                                    .withOpacity(0.04),
                                                child: const Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    color:
                                                        AppTheme.primaryColor,
                                                  ),
                                                ),
                                              ),
                                              errorWidget: (_, __, ___) =>
                                                  Container(
                                                color: AppTheme.primaryColor
                                                    .withOpacity(0.04),
                                                child: Center(
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .image_not_supported_rounded,
                                                        size: 36,
                                                        color: AppTheme
                                                            .textHint,
                                                      ),
                                                      const SizedBox(
                                                          height: 4),
                                                      Text(
                                                        '加载失败',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: AppTheme
                                                              .textHint,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            // 长按提示角标
                                            Positioned(
                                              bottom: 4,
                                              right: 4,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(4),
                                                decoration: BoxDecoration(
                                                  color: Colors.black
                                                      .withOpacity(0.3),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.delete_outline_rounded,
                                                  size: 14,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 8),
                                        child: Text(
                                          card.word,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: AppTheme.textPrimary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addingCard ? null : _addCard,
        backgroundColor: AppTheme.primaryColor,
        icon: _addingCard
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Icon(Icons.camera_alt_rounded, color: Colors.white),
        label: Text(
          _addingCard ? '添加中...' : '拍照添加',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
