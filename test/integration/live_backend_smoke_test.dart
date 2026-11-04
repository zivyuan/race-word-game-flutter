// 三端联调冒烟测试：登录 → 建卡组 → 建卡 → 展示/认识计数 → 统计 全流程
// 默认跳过；需要后端在跑时显式开启：
//   flutter test test/integration/live_backend_smoke_test.dart --dart-define=RUN_LIVE=1 --dart-define=API_BASE_URL=http://localhost:8000
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:race_word_game/services/api_service.dart';

void main() {
  const runLive = String.fromEnvironment('RUN_LIVE') == '1';
  test('live backend smoke: auth + cardset CRUD + card + record + stats',
      () async {
    ApiService.baseUrl =
        const String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:8000');
    final username = 'bot_smoke_${DateTime.now().millisecondsSinceEpoch}';

    // 1. 注册即登录
    final user = await ApiService.register(
      username: username,
      password: '123456',
      nickname: '联调冒烟',
    );
    expect(user.id, isNotEmpty);

    // 2. 卡组 CRUD
    final set = await ApiService.createCardSet(user.id, '冒烟卡组');
    expect(set.name, '冒烟卡组');
    final sets = await ApiService.getCardSets(user.id);
    expect(sets.any((s) => s.id == set.id), isTrue);

    // 3. 建卡 + 列表
    final card = await ApiService.createCardInSet(set.id, 'apple');
    expect(card.word, 'apple');
    final cards = await ApiService.getCards(set.id, userId: user.id);
    expect(cards.any((c) => c.id == card.id), isTrue);

    // 4. 计数
    await ApiService.recordShown(card.id, userId: user.id);
    await ApiService.recordShown(card.id, userId: user.id);
    await ApiService.recordKnown(card.id, userId: user.id);

    // 5. 统计（按 userId 聚合）
    final stats = await ApiService.getGameStats(user.id);
    final mine = stats.firstWhere((s) => s.card.id == card.id);
    expect(mine.timesShown, 2);
    expect(mine.timesKnown, 1);
    expect(mine.masteryLevel, 'learning'); // 1/2 = 50% → learning

    final raw = await ApiService.getGameStatsRaw(user.id);
    expect(raw['totalCards'], greaterThanOrEqualTo(1));
    expect(raw['totalShown'], greaterThanOrEqualTo(2));

    // 6. 清理
    await ApiService.deleteCardSet(set.id, user.id);
    final setsAfter = await ApiService.getCardSets(user.id);
    expect(setsAfter.any((s) => s.id == set.id), isFalse);
  }, skip: !runLive
      ? 'live-only: 需要 Docker 后端，加 --dart-define=RUN_LIVE=1 运行'
      : false, timeout: const Timeout(Duration(seconds: 60)));
}
