import 'package:flutter_test/flutter_test.dart';
import 'package:spindle_chat/spindle_chat.dart';

void main() {
  group('ChatAuthor', () {
    test('creates with required fields', () {
      const author = ChatAuthor(id: 'user-1');
      expect(author.id, 'user-1');
      expect(author.displayName, isNull);
      expect(author.avatarUrl, isNull);
    });

    test('creates with all fields', () {
      const author = ChatAuthor(id: 'user-1', displayName: 'Alice', avatarUrl: 'https://example.com/avatar.png');
      expect(author.displayName, 'Alice');
      expect(author.avatarUrl, 'https://example.com/avatar.png');
    });

    test('effectiveName returns displayName when set', () {
      const author = ChatAuthor(id: 'user-1', displayName: 'Alice');
      expect(author.effectiveName, 'Alice');
    });

    test('effectiveName falls back to id', () {
      const author = ChatAuthor(id: 'user-1');
      expect(author.effectiveName, 'user-1');
    });

    test('copyWith replaces specified fields', () {
      const author = ChatAuthor(id: 'user-1', displayName: 'Alice');
      final copy = author.copyWith(displayName: 'Bob');
      expect(copy.id, 'user-1');
      expect(copy.displayName, 'Bob');
    });

    test('copyWith replaces id', () {
      const author = ChatAuthor(id: 'user-1', displayName: 'Alice');
      final copy = author.copyWith(id: 'user-2');
      expect(copy.id, 'user-2');
      expect(copy.displayName, 'Alice');
    });

    test('equality is based on id', () {
      const a = ChatAuthor(id: 'user-1', displayName: 'Alice');
      const b = ChatAuthor(id: 'user-1', displayName: 'Bob');
      expect(a, equals(b));
    });

    test('inequality when ids differ', () {
      const a = ChatAuthor(id: 'user-1');
      const b = ChatAuthor(id: 'user-2');
      expect(a, isNot(equals(b)));
    });

    test('hashCode is consistent with equality', () {
      const a = ChatAuthor(id: 'user-1');
      const b = ChatAuthor(id: 'user-1');
      expect(a.hashCode, b.hashCode);
    });

    test('toJson produces correct map', () {
      const author = ChatAuthor(id: 'user-1', displayName: 'Alice', avatarUrl: 'https://example.com/avatar.png');
      final json = author.toJson();
      expect(json['id'], 'user-1');
      expect(json['displayName'], 'Alice');
      expect(json['avatarUrl'], 'https://example.com/avatar.png');
    });

    test('fromJson creates correct author', () {
      final author = ChatAuthor.fromJson(const {
        'id': 'user-1',
        'displayName': 'Alice',
        'avatarUrl': 'https://example.com/avatar.png',
      });
      expect(author.id, 'user-1');
      expect(author.displayName, 'Alice');
      expect(author.avatarUrl, 'https://example.com/avatar.png');
    });

    test('fromJson handles missing optional fields', () {
      final author = ChatAuthor.fromJson(const {'id': 'user-1'});
      expect(author.id, 'user-1');
      expect(author.displayName, isNull);
      expect(author.avatarUrl, isNull);
    });

    test('toJson/fromJson roundtrip', () {
      const original = ChatAuthor(id: 'user-1', displayName: 'Alice', avatarUrl: 'https://example.com/avatar.png');
      final restored = ChatAuthor.fromJson(original.toJson());
      expect(restored, equals(original));
    });

    test('toString includes name', () {
      const author = ChatAuthor(id: 'user-1', displayName: 'Alice');
      expect(author.toString(), contains('Alice'));
    });
  });
}
