import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

/// API 服务层 — 对齐 Cook 后端 API (Boss 规范)
///
/// Base URL: http://<host>:8000
/// 认证: JWT Bearer Token
/// 路由: /api/v1/auth/*, /api/v1/users/*, /api/v1/cards/*
class ApiService {
  // === 配置 ===
  static String baseUrl = 'http://10.0.2.2:8000'; // Android 模拟器访问本机
  static const Duration _defaultTimeout = Duration(seconds: 10);

  // === JWT Token 管理 ===
  static String? _token;
  static const _tokenKey = 'jwt_token';

  /// 从本地存储恢复 token
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
  }

  /// 保存认证 token
  static Future<void> _saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  /// 清除 token (登出)
  static Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  /// 当前是否已登录
  static bool get isLoggedIn => _token != null;

  // === 请求头 ===
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  // === 带超时和重试的请求封装 ===
  static Future<http.Response> _requestWithRetry(
    Future<http.Response> Function() request, {
    int maxRetries = 2,
    Duration timeout = _defaultTimeout,
  }) async {
    int attempt = 0;
    while (true) {
      try {
        final response = await request().timeout(timeout);
        return response;
      } on TimeoutException {
        attempt++;
        if (attempt >= maxRetries) {
          throw TimeoutException('请求超时，请检查网络连接');
        }
        await Future.delayed(Duration(seconds: attempt));
      } on SocketException {
        attempt++;
        if (attempt >= maxRetries) {
          throw Exception('网络连接失败，请检查网络');
        }
        await Future.delayed(Duration(seconds: attempt));
      }
    }
  }

  // === 解析响应 ===
  static Map<String, dynamic> _parseJson(http.Response res) {
    if (res.statusCode == 401) {
      clearToken();
      throw Exception('认证已过期，请重新登录');
    }
    if (res.statusCode == 404) {
      throw Exception('资源不存在');
    }
    if (res.statusCode >= 400) {
      try {
        final data = jsonDecode(res.body);
        throw Exception(data['detail'] ?? '请求失败 (${res.statusCode})');
      } catch (e) {
        if (e is Exception && e.toString().startsWith('Exception: ')) rethrow;
        throw Exception('请求失败 (${res.statusCode})');
      }
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  static List<dynamic> _parseJsonList(http.Response res) {
    if (res.statusCode == 401) {
      clearToken();
      throw Exception('认证已过期，请重新登录');
    }
    if (res.statusCode >= 400) {
      try {
        final data = jsonDecode(res.body);
        throw Exception(data['detail'] ?? '请求失败 (${res.statusCode})');
      } catch (e) {
        if (e is Exception && e.toString().startsWith('Exception: ')) rethrow;
        throw Exception('请求失败 (${res.statusCode})');
      }
    }
    return jsonDecode(res.body) as List<dynamic>;
  }

  // ================================================================
  // 1. 认证模块 /api/auth
  // ================================================================

  /// 注册
  static Future<UserProfile> register({
    required String username,
    required String password,
    required String nickname,
  }) async {
    final res = await _requestWithRetry(
      () => http.post(
        Uri.parse('$baseUrl/api/v1/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
          'nickname': nickname,
        }),
      ),
    );
    final data = _parseJson(res);
    return UserProfile.fromJson(data);
  }

  /// 登录 → 拿到 JWT token → 自动保存
  static Future<String> login({
    required String username,
    required String password,
  }) async {
    final res = await _requestWithRetry(
      () => http.post(
        Uri.parse('$baseUrl/api/v1/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      ),
    );
    final data = _parseJson(res);
    final token = data['access_token'] as String;
    await _saveToken(token);
    return token;
  }

  /// 注册并自动登录
  static Future<UserProfile> registerAndLogin({
    required String username,
    required String password,
    required String nickname,
  }) async {
    final user = await register(
      username: username,
      password: password,
      nickname: nickname,
    );
    await login(username: username, password: password);
    return user;
  }

  // ================================================================
  // 2. 用户模块 /api/users
  // ================================================================

  /// 获取当前用户信息
  static Future<UserProfile> getMe() async {
    final res = await _requestWithRetry(
      () => http.get(
        Uri.parse('$baseUrl/api/v1/users/me'),
        headers: _headers,
      ),
    );
    return UserProfile.fromJson(_parseJson(res));
  }

  /// 更新当前用户信息
  static Future<UserProfile> updateMe({
    String? nickname,
    String? avatar,
  }) async {
    final body = <String, dynamic>{};
    if (nickname != null) body['nickname'] = nickname;
    if (avatar != null) body['avatar'] = avatar;

    final res = await _requestWithRetry(
      () => http.patch(
        Uri.parse('$baseUrl/api/v1/users/me'),
        headers: _headers,
        body: jsonEncode(body),
      ),
    );
    return UserProfile.fromJson(_parseJson(res));
  }

  /// 查看他人信息（通过 int id）
  static Future<UserProfile> getUserById(int userId) async {
    final res = await _requestWithRetry(
      () => http.get(
        Uri.parse('$baseUrl/api/v1/users/$userId'),
        headers: _headers,
      ),
    );
    return UserProfile.fromJson(_parseJson(res));
  }

  // ================================================================
  // 3. 卡片模块 /api/cards
  // ================================================================

  /// 创建卡片
  static Future<CardDetail> createCard({
    required String title,
    String description = '',
    CardCategory category = CardCategory.general,
    int difficulty = 1,
    bool isPublic = true,
    required List<String> words,
  }) async {
    final res = await _requestWithRetry(
      () => http.post(
        Uri.parse('$baseUrl/api/v1/cards'),
        headers: _headers,
        body: jsonEncode({
          'title': title,
          'description': description,
          'category': category.name,
          'difficulty': difficulty,
          'is_public': isPublic,
          'words': words,
        }),
      ),
    );
    return CardDetail.fromJson(_parseJson(res));
  }

  /// 浏览公开卡片（支持筛选）
  static Future<List<CardListItem>> getPublicCards({
    CardCategory? category,
    int? difficulty,
    int? ownerId,
    int skip = 0,
    int limit = 20,
  }) async {
    final params = <String, String>{
      'skip': skip.toString(),
      'limit': limit.toString(),
    };
    if (category != null) params['category'] = category.name;
    if (difficulty != null) params['difficulty'] = difficulty.toString();
    if (ownerId != null) params['owner_id'] = ownerId.toString();

    final uri = Uri.parse('$baseUrl/api/v1/cards').replace(queryParameters: params);
    final res = await _requestWithRetry(
      () => http.get(uri, headers: _headers),
    );
    final list = _parseJsonList(res);
    return list.map((e) => CardListItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// 获取我的卡片
  static Future<List<CardListItem>> getMyCards({
    int skip = 0,
    int limit = 20,
  }) async {
    final uri = Uri.parse('$baseUrl/api/v1/cards/mine').replace(
      queryParameters: {'skip': skip.toString(), 'limit': limit.toString()},
    );
    final res = await _requestWithRetry(
      () => http.get(uri, headers: _headers),
    );
    final list = _parseJsonList(res);
    return list.map((e) => CardListItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// 获取卡片详情（含 words）
  static Future<CardDetail> getCardDetail(int cardId) async {
    final res = await _requestWithRetry(
      () => http.get(
        Uri.parse('$baseUrl/api/v1/cards/$cardId'),
        headers: _headers,
      ),
    );
    return CardDetail.fromJson(_parseJson(res));
  }

  /// 更新卡片
  static Future<CardDetail> updateCard(
    int cardId, {
    String? title,
    String? description,
    CardCategory? category,
    int? difficulty,
    bool? isPublic,
    List<String>? words,
  }) async {
    final body = <String, dynamic>{};
    if (title != null) body['title'] = title;
    if (description != null) body['description'] = description;
    if (category != null) body['category'] = category.name;
    if (difficulty != null) body['difficulty'] = difficulty;
    if (isPublic != null) body['is_public'] = isPublic;
    if (words != null) body['words'] = words;

    final res = await _requestWithRetry(
      () => http.patch(
        Uri.parse('$baseUrl/api/v1/cards/$cardId'),
        headers: _headers,
        body: jsonEncode(body),
      ),
    );
    return CardDetail.fromJson(_parseJson(res));
  }

  /// 删除卡片
  static Future<void> deleteCard(int cardId) async {
    await _requestWithRetry(
      () => http.delete(
        Uri.parse('$baseUrl/api/v1/cards/$cardId'),
        headers: _headers,
      ),
    );
  }

  /// 获取所有可用分类
  static Future<List<String>> getCategories() async {
    final res = await _requestWithRetry(
      () => http.get(
        Uri.parse('$baseUrl/api/v1/cards/categories/list'),
        headers: _headers,
      ),
    );
    final list = _parseJsonList(res);
    return list.map((e) => e.toString()).toList();
  }

  // ================================================================
  // 4. 健康检查
  // ================================================================

  static Future<bool> healthCheck() async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/health'),
      ).timeout(const Duration(seconds: 3));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ================================================================
  // 5. 成就相关 (后端暂无对应接口，本地处理)
  // ================================================================

  static Future<List<AchievementModel>> getAchievements() async {
    // TODO: 等 Cook 加成就接口后对接
    return [];
  }

  static Future<List<UserAchievementModel>> getUserAchievements(String userId) async {
    // TODO: 等 Cook 加成就接口后对接
    return [];
  }

  static Future<bool> unlockAchievement(
    String userId,
    String achievementId, {
    Map<String, dynamic>? progress,
  }) async {
    // TODO: 等 Cook 加成就接口后对接
    return false;
  }

  static Future<Map<String, dynamic>> getAchievementStats(String userId) async {
    // TODO: 等 Cook 加成就接口后对接
    return {'total': 0, 'unlocked': 0, 'locked': 0};
  }

  // ================================================================
  // 6. 语音评分 (后端暂无对应接口，本地 mock)
  // ================================================================

  static Future<Map<String, dynamic>> voiceScore(
    String word,
    String userId, {
    String? audioData,
  }) async {
    // TODO: 等 Cook 加语音评分接口后对接
    return {
      'score': 70,
      'feedback': '继续加油！💪',
      'word': word,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  // ================================================================
  // 7. 兼容旧接口 (逐步迁移 screens 后移除)
  // ================================================================

  /// @deprecated 使用 register() + login() 代替
  static Future<UserProfile> createUser(String nickname, String avatarUrl) async {
    return register(
      username: 'user_${DateTime.now().millisecondsSinceEpoch}',
      password: '123456',
      nickname: nickname,
    );
  }

  /// @deprecated 使用 getUserById() 或 getMe() 代替
  static Future<UserProfile?> getUser(String id) async {
    try {
      return getUserById(int.parse(id));
    } catch (_) {
      return null;
    }
  }

  /// @deprecated 使用 updateMe() 代替
  static Future<UserProfile> updateUserProfile(
    String userId, {
    String? nickname,
    String? avatarUrl,
  }) async {
    return updateMe(nickname: nickname, avatar: avatarUrl);
  }

  /// @deprecated 使用 getMyCards() 代替
  static Future<List<CardListItem>> getCardSets(String userId) async {
    return getMyCards();
  }

  /// @deprecated 使用 createCard() 代替
  static Future<CardDetail> createCardSet(String userId, String name) async {
    return createCard(title: name, words: []);
  }

  /// @deprecated 使用 deleteCard() 代替
  static Future<void> deleteCardSet(String id, String userId) async {
    await deleteCard(int.parse(id));
  }

  /// @deprecated 使用 getCardDetail() 获取 words 代替
  static Future<List<CardItem>> getCards(String cardSetId) async {
    try {
      final detail = await getCardDetail(int.parse(cardSetId));
      return detail.words.asMap().entries.map((e) => CardItem(
        id: '${detail.id}_${e.key}',
        cardSetId: detail.id.toString(),
        word: e.value,
        createdAt: detail.createdAt,
      )).toList();
    } catch (_) {
      return [];
    }
  }

  /// @deprecated 游戏 API 暂未实现
  static Future<void> recordShown(String cardId) async {}
  static Future<void> recordKnown(String cardId) async {}
  static Future<List<GameRecordInfo>> getGameStats(String cardSetId) async => [];
  static Future<List<Map<String, dynamic>>> getGameHistory(
    String userId, {int limit = 20}
  ) async => [];
}
