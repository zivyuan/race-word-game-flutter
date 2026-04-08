import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
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
      set = await ApiService.createCardSet(userId, name);
    } else {
      // Generate local ID
      final id = 'local_${DateTime.now().millisecondsSinceEpoch}';
      set = CardSetInfo(
        id: id,
        userId: userId,
        name: name,
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
      final card = await ApiService.createCard(cardSetId, word, imagePath);
      await LocalDatabase.saveCard(card);
      return card;
    } else {
      final id = 'local_${DateTime.now().millisecondsSinceEpoch}';
      final card = CardItem(
        id: id,
        cardSetId: cardSetId,
        imageUrl: imagePath, // local path
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
        await ApiService.deleteCard(id);
      } catch (_) {}
    }
  }

  // === Game Records ===
  Future<void> recordShown(String cardId) async {
    if (_connectivity.isOnline) {
      try {
        await ApiService.recordShown(cardId);
      } catch (_) {}
    }
  }

  Future<void> recordKnown(String cardId) async {
    if (_connectivity.isOnline) {
      try {
        await ApiService.recordKnown(cardId);
      } catch (_) {}
    }
  }

  Future<List<GameRecordInfo>> getGameStats(String cardSetId) async {
    if (_connectivity.isOnline) {
      try {
        final stats = await ApiService.getGameStats(cardSetId);
        return stats;
      } catch (_) {}
    }
    return LocalDatabase.getLocalGameStats(cardSetId);
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

  Future<bool> healthCheck() => ApiService.healthCheck();

  void dispose() {
    _syncTimer?.cancel();
    _connectivity.dispose();
  }
}
