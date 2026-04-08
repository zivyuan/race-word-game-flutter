import 'package:flutter_test/flutter_test.dart';
import 'package:race_word_game/models/models.dart';

void main() {
  group('UserProfile', () {
    test('fromJson with all fields', () {
      final json = {
        'id': 'user-001',
        'nickname': 'Alice',
        'avatarUrl': '🐶',
      };
      final user = UserProfile.fromJson(json);
      expect(user.id, 'user-001');
      expect(user.nickname, 'Alice');
      expect(user.avatarUrl, '🐶');
    });

    test('fromJson with null avatarUrl defaults to 🐶', () {
      final json = {
        'id': 'user-002',
        'nickname': 'Bob',
        'avatarUrl': null,
      };
      final user = UserProfile.fromJson(json);
      expect(user.avatarUrl, '🐶');
    });

    test('fromJson without avatarUrl key defaults to 🐶', () {
      final json = {
        'id': 'user-003',
        'nickname': 'Charlie',
      };
      final user = UserProfile.fromJson(json);
      expect(user.avatarUrl, '🐶');
    });

    test('toJson roundtrip', () {
      final user = UserProfile(id: 'u1', nickname: 'Test', avatarUrl: '🐱');
      final json = user.toJson();
      expect(json['id'], 'u1');
      expect(json['nickname'], 'Test');
      expect(json['avatarUrl'], '🐱');
    });
  });

  group('CardSetInfo', () {
    test('fromJson with all fields', () {
      final json = {
        'id': 'cs-001',
        'userId': 'u-001',
        'name': '动物单词',
        'createdAt': '2026-01-01T00:00:00Z',
      };
      final cs = CardSetInfo.fromJson(json);
      expect(cs.id, 'cs-001');
      expect(cs.userId, 'u-001');
      expect(cs.name, '动物单词');
      expect(cs.createdAt, '2026-01-01T00:00:00Z');
    });

    test('fromJson with null createdAt defaults to empty string', () {
      final json = {
        'id': 'cs-002',
        'userId': 'u-002',
        'name': '水果',
        'createdAt': null,
      };
      final cs = CardSetInfo.fromJson(json);
      expect(cs.createdAt, '');
    });
  });

  group('CardItem', () {
    test('fromJson with all fields', () {
      final json = {
        'id': 'c-001',
        'cardSetId': 'cs-001',
        'imageUrl': '/uploads/cards/test.png',
        'word': 'apple',
        'createdAt': '2026-01-01T00:00:00Z',
      };
      final card = CardItem.fromJson(json);
      expect(card.id, 'c-001');
      expect(card.cardSetId, 'cs-001');
      expect(card.imageUrl, '/uploads/cards/test.png');
      expect(card.word, 'apple');
      expect(card.createdAt, '2026-01-01T00:00:00Z');
    });

    test('fromJson with null createdAt defaults to empty string', () {
      final json = {
        'id': 'c-002',
        'cardSetId': 'cs-001',
        'imageUrl': '/uploads/cards/test2.png',
        'word': 'banana',
        'createdAt': null,
      };
      final card = CardItem.fromJson(json);
      expect(card.createdAt, '');
    });
  });

  group('GameRecordInfo', () {
    test('fromJson with all fields', () {
      final json = {
        'card': {
          'id': 'c-001',
          'cardSetId': 'cs-001',
          'imageUrl': '/uploads/cards/test.png',
          'word': 'apple',
          'createdAt': '2026-01-01T00:00:00Z',
        },
        'timesShown': 10,
        'timesKnown': 5,
        'lastPlayedAt': '2026-01-02T00:00:00Z',
        'masteryLevel': 'learning',
      };
      final record = GameRecordInfo.fromJson(json);
      expect(record.card.id, 'c-001');
      expect(record.card.word, 'apple');
      expect(record.timesShown, 10);
      expect(record.timesKnown, 5);
      expect(record.lastPlayedAt, '2026-01-02T00:00:00Z');
      expect(record.masteryLevel, 'learning');
    });

    test('fromJson with null fields uses defaults', () {
      final json = {
        'card': {
          'id': 'c-001',
          'cardSetId': 'cs-001',
          'imageUrl': '/uploads/cards/test.png',
          'word': 'cat',
          'createdAt': '2026-01-01T00:00:00Z',
        },
        'timesShown': null,
        'timesKnown': null,
        'lastPlayedAt': null,
        'masteryLevel': null,
      };
      final record = GameRecordInfo.fromJson(json);
      expect(record.timesShown, 0);
      expect(record.timesKnown, 0);
      expect(record.lastPlayedAt, null);
      expect(record.masteryLevel, 'new');
    });

    test('mastery levels: new, learning, mastered', () {
      for (final level in ['new', 'learning', 'mastered']) {
        final json = {
          'card': {
            'id': 'c-001',
            'cardSetId': 'cs-001',
            'imageUrl': '/uploads/cards/test.png',
            'word': 'dog',
            'createdAt': '2026-01-01T00:00:00Z',
          },
          'timesShown': 0,
          'timesKnown': 0,
          'lastPlayedAt': null,
          'masteryLevel': level,
        };
        final record = GameRecordInfo.fromJson(json);
        expect(record.masteryLevel, level);
      }
    });
  });
}
