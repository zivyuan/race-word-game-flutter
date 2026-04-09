import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class ApiService {
  // TODO: 替换为你的服务器地址
  static String baseUrl = 'http://10.0.2.2:3000'; // Android 模拟器访问本机

  // 后端使用 /api/v1 路由前缀
  static String get _v1 => '$baseUrl/api/v1';

  static final Map<String, String> _headers = {
    'Content-Type': 'application/json',
  };

  // === User ===
  static Future<UserProfile> createUser(String nickname, String avatarUrl) async {
    final res = await http.post(
      Uri.parse('$_v1/user'),
      headers: _headers,
      body: jsonEncode({'nickname': nickname, 'avatarUrl': avatarUrl}),
    );
    final data = _parseResponse(res);
    return UserProfile.fromJson(data['data']);
  }

  static Future<UserProfile?> getUser(String id) async {
    final res = await http.get(
      Uri.parse('$_v1/user/$id'),
      headers: _headers,
    );
    if (res.statusCode == 404) return null;
    final data = _parseResponse(res);
    return UserProfile.fromJson(data['data']);
  }

  // === Card Sets ===
  static Future<List<CardSetInfo>> getCardSets(String userId) async {
    final res = await http.get(
      Uri.parse('$_v1/cardsets?userId=$userId'),
      headers: _headers,
    );
    final data = _parseResponse(res);
    return (data['data'] as List).map((e) => CardSetInfo.fromJson(e)).toList();
  }

  static Future<CardSetInfo> createCardSet(String userId, String name) async {
    final res = await http.post(
      Uri.parse('$_v1/cardsets'),
      headers: _headers,
      body: jsonEncode({'userId': userId, 'name': name}),
    );
    final data = _parseResponse(res);
    return CardSetInfo.fromJson(data['data']);
  }

  static Future<void> deleteCardSet(String id, String userId) async {
    await http.delete(
      Uri.parse('$_v1/cardsets/$id?userId=$userId'),
      headers: _headers,
    );
  }

  // === Cards ===
  static Future<List<CardItem>> getCards(String cardSetId) async {
    final res = await http.get(
      Uri.parse('$_v1/cards?cardSetId=$cardSetId'),
      headers: _headers,
    );
    final data = _parseResponse(res);
    return (data['data'] as List).map((e) => CardItem.fromJson(e)).toList();
  }

  static Future<CardItem> createCard(String cardSetId, String word, String imagePath) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$_v1/cards'),
    );
    request.fields['cardSetId'] = cardSetId;
    request.fields['word'] = word;
    request.files.add(await http.MultipartFile.fromPath('image', imagePath));
    final streamRes = await request.send();
    final res = await http.Response.fromStream(streamRes);
    final data = jsonDecode(res.body);
    if (data['success'] != true) {
      throw Exception(data['error'] ?? '创建卡片失败');
    }
    return CardItem.fromJson(data['data']);
  }

  static Future<void> deleteCard(String id) async {
    await http.delete(
      Uri.parse('$_v1/cards/$id'),
      headers: _headers,
    );
  }

  // === Game ===
  static Future<void> recordShown(String cardId) async {
    await http.post(
      Uri.parse('$_v1/game/record-shown'),
      headers: _headers,
      body: jsonEncode({'cardId': cardId}),
    );
  }

  static Future<void> recordKnown(String cardId) async {
    await http.post(
      Uri.parse('$_v1/game/record-known'),
      headers: _headers,
      body: jsonEncode({'cardId': cardId}),
    );
  }

  static Future<List<GameRecordInfo>> getGameStats(String cardSetId) async {
    final res = await http.get(
      Uri.parse('$_v1/game/stats/$cardSetId'),
      headers: _headers,
    );
    final data = _parseResponse(res);
    return (data['data'] as List).map((e) => GameRecordInfo.fromJson(e)).toList();
  }

  // === Health ===
  static Future<bool> healthCheck() async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/api/health'),
        headers: _headers,
      ).timeout(const Duration(seconds: 3));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Map<String, dynamic> _parseResponse(http.Response res) {
    final data = jsonDecode(res.body);
    if (data['success'] != true) {
      throw Exception(data['error'] ?? '请求失败');
    }
    return data;
  }

  // ========== 成就相关方法 ==========

  static Future<List<AchievementModel>> getAchievements() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/api/achievements'));
      final data = _parseResponse(res);
      return (data['data'] as List)
          .map((json) => AchievementModel.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  static Future<List<UserAchievementModel>> getUserAchievements(String userId) async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/api/achievements/user/$userId'),
      );
      final data = _parseResponse(res);
      return (data['data'] as List)
          .map((json) => UserAchievementModel.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  static Future<bool> unlockAchievement(String userId, String achievementId, {Map<String, dynamic>? progress}) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/api/achievements/unlock'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'achievementId': achievementId,
          'progress': progress ?? {},
        }),
      );
      final data = _parseResponse(res);
      return data['data']['unlocked'] ?? false;
    } catch (e) {
      return false;
    }
  }

  // ========== 语音评分方法 ==========

  static Future<Map<String, dynamic>> voiceScore(String word, String userId, {String? audioData}) async {
    try {
      final res = await http.post(
        Uri.parse('$_v1/voice-score'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'word': word,
          'userId': userId,
          'audioData': audioData ?? '',
        }),
      );
      final data = _parseResponse(res);
      return data['data'] as Map<String, dynamic>;
    } catch (e) {
      return {
        'score': 70,
        'feedback': '继续加油！💪',
        'word': word,
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }
}
