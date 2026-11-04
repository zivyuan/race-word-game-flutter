import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../services/local_database.dart';
import '../services/connectivity_service.dart';

/// Manages data flow between local SQLite cache and remote API.
/// When online, fetches from API and caches locally.
/// When offline, serves data from local cache.
class OfflineService {
  static final OfflineService _instance = OfflineService._();
  factory OfflineService() => _instance;
  OfflineService._();

  final _connectivity = ConnectivityService();
  Timer? _syncTimer;

  Future<void> init() async {
    await _connectivity.init();
    // Auto-sync every 5 minutes when online
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (_) => _syncUnsentRecords());
  }

  bool get isOnline => _connectivity.isOnline;

  // === User Profile ===
  Future<UserProfile?> getUserProfile(String userId) async {
    if (_connectivity.isOnline) {
      try {
        final user = await ApiService.getUser(userId);
        if (user != null) {
          // Cache user profile locally
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('cached_user_${user.id}', jsonEncode(user.toJson()));
        }
        return user;
      } catch (_) {
        // Fall back to local cache
      }
    }
    return _getCachedUserProfile(userId);
  }

  Future<UserProfile?> _getCachedUserProfile(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('cached_user_$userId');
      if (cached != null) {
        return UserProfile.fromJson(jsonDecode(cached));
      }
    } catch (_) {}
    return null;
  }

  // === Card Sets ===
  Future<List<CardSetInfo>> getCardSets(String userId) async {
    if (_connectivity.isOnline) {
      try {
        final sets = await ApiService.getCardSets(userId);
        await LocalDatabase.saveCardSets(sets);
        return sets;
      } catch (_) {
        // Fall back to local
      }
    }
    return LocalDatabase.getLocalCardSets(userId);
  }

  Future<CardSetInfo> createCardSet(String userId, String name) async {
    CardSetInfo set;
    if (_connectivity.isOnline) {
      // createCardSet 现在直接返回 CardSetInfo
      set = await ApiService.createCardSet(userId, name);
    } else {
      // Generate local ID
      final id = 'local_${DateTime.now().millisecondsSinceEpoch}';
      set = CardSetInfo(
        id: id,
        userId: userId,
        title: name,
        createdAt: DateTime.now().toIso8601String(),
      );
    }
    await LocalDatabase.saveCardSet(set);
    return set;
  }

  Future<void> deleteCardSet(String id, String userId) async {
    await LocalDatabase.deleteLocalCardSet(id);
    if (_connectivity.isOnline) {
      try {
        await ApiService.deleteCardSet(id, userId);
      } catch (_) {}
    }
  }

  // === Cards ===
  Future<List<CardItem>> getCards(String cardSetId) async {
    if (_connectivity.isOnline) {
      try {
        final cards = await ApiService.getCards(cardSetId);
        await LocalDatabase.saveCards(cards);
        return cards;
      } catch (_) {}
    }
    return LocalDatabase.getLocalCards(cardSetId);
  }

  Future<CardItem> createCard(String cardSetId, String word, String imagePath) async {
    if (_connectivity.isOnline) {
      // Cook API: 追加 word 到卡片集
      final cardId = int.tryParse(cardSetId) ?? 0;
      final detail = await ApiService.getCardDetail(cardId);
      final updatedWords = [...detail.words, word];
      await ApiService.updateCard(cardId, words: updatedWords);
      final card = CardItem(
        id: '${cardSetId}_${detail.words.length}',
        cardSetId: cardSetId,
        word: word,
        createdAt: DateTime.now().toIso8601String(),
      );
      await LocalDatabase.saveCard(card);
      return card;
    } else {
      final id = 'local_${DateTime.now().millisecondsSinceEpoch}';
      final card = CardItem(
        id: id,
        cardSetId: cardSetId,
        imageUrl: imagePath,
        word: word,
        createdAt: DateTime.now().toIso8601String(),
      );
      await LocalDatabase.saveCard(card);
      return card;
    }
  }

  Future<void> deleteCard(String id) async {
    await LocalDatabase.deleteLocalCard(id);
    if (_connectivity.isOnline) {
      try {
        await ApiService.deleteCard(int.parse(id));
      } catch (_) {}
    }
  }

  // === Game Records ===
  Future<void> recordShown(String cardId) async {
    // Always save locally for sync
    await LocalDatabase.addUnsyncedRecord(cardId, 0);
    if (_connectivity.isOnline) {
      try {
        await ApiService.recordShown(cardId);
        await LocalDatabase.markCardRecordSynced(cardId);
      } catch (_) {}
    }
  }

  Future<void> recordKnown(String cardId) async {
    // Always save locally for sync
    await LocalDatabase.addUnsyncedRecord(cardId, 1);
    if (_connectivity.isOnline) {
      try {
        await ApiService.recordKnown(cardId);
        await LocalDatabase.markCardRecordSynced(cardId);
      } catch (_) {}
    }
  }

  Future<List<GameRecordInfo>> getGameStats(String userId) async {
    if (_connectivity.isOnline) {
      try {
        final stats = await ApiService.getGameStats(userId);
        return stats;
      } catch (_) {}
    }
    return LocalDatabase.getLocalGameStats(userId);
  }

  // === Sync ===
  Future<void> _syncUnsentRecords() async {
    if (!_connectivity.isOnline) return;
    try {
      final unsynced = await LocalDatabase.getUnsyncedRecords();
      for (final record in unsynced) {
        if (record['correct'] == 1) {
          await ApiService.recordKnown(record['card_id'] as String);
        } else {
          await ApiService.recordShown(record['card_id'] as String);
        }
      }
      await LocalDatabase.markRecordsSynced();
    } catch (_) {}
  }

  /// Trigger a manual sync (e.g., when network recovers)
  Future<void> syncNow() async {
    if (!_connectivity.isOnline) return;
    await _syncUnsentRecords();
  }

  Future<bool> healthCheck() => ApiService.healthCheck();

  void dispose() {
    _syncTimer?.cancel();
    _connectivity.dispose();
  }
}
