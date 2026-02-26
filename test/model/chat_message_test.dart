import 'package:flutter_test/flutter_test.dart';
import 'package:spindle_chat/spindle_chat.dart';

void main() {
  final now = DateTime(2025, 1, 15, 12, 0);

  group('ChatMessageStatus', () {
    test('isDelivered returns true for delivered and seen', () {
      expect(ChatMessageStatus.delivered.isDelivered, isTrue);
      expect(ChatMessageStatus.seen.isDelivered, isTrue);
    });

    test('isDelivered returns false for sending, sent, error', () {
      expect(ChatMessageStatus.sending.isDelivered, isFalse);
      expect(ChatMessageStatus.sent.isDelivered, isFalse);
      expect(ChatMessageStatus.error.isDelivered, isFalse);
    });
  });

  group('TextMessage', () {
    late TextMessage message;

    setUp(() {
      message = TextMessage(id: 'msg-1', authorId: 'user-1', createdAt: now, text: 'Hello, World!');
    });

    test('has correct default status', () {
      expect(message.status, ChatMessageStatus.sent);
    });

    test('isText returns true', () {
      expect(message.isText, isTrue);
    });

    test('isSystem returns false', () {
      expect(message.isSystem, isFalse);
    });

    test('isEdited returns false when no updatedAt', () {
      expect(message.isEdited, isFalse);
    });

    test('isEdited returns true when updatedAt is set', () {
      final edited = message.copyWith(updatedAt: now.add(const Duration(minutes: 5)));
      expect(edited.isEdited, isTrue);
    });

    test('copyWith replaces only specified fields', () {
      final copy = message.copyWith(text: 'Updated text', status: ChatMessageStatus.delivered);
      expect(copy.id, 'msg-1');
      expect(copy.authorId, 'user-1');
      expect(copy.text, 'Updated text');
      expect(copy.status, ChatMessageStatus.delivered);
      expect(copy.createdAt, now);
    });

    test('equality is based on id', () {
      final other = TextMessage(
        id: 'msg-1',
        authorId: 'user-2',
        createdAt: now.add(const Duration(hours: 1)),
        text: 'Different text',
      );
      expect(message, equals(other));
    });

    test('inequality when ids differ', () {
      final other = TextMessage(id: 'msg-2', authorId: 'user-1', createdAt: now, text: 'Hello, World!');
      expect(message, isNot(equals(other)));
    });

    test('toJson produces correct map', () {
      final json = message.toJson();
      expect(json['type'], 'text');
      expect(json['id'], 'msg-1');
      expect(json['authorId'], 'user-1');
      expect(json['text'], 'Hello, World!');
      expect(json['status'], 'sent');
      expect(json['replyToMessageId'], isNull);
    });

    test('fromJson roundtrip preserves data', () {
      final json = message.toJson();
      final restored = ChatMessage.fromJson(json);
      expect(restored, isA<TextMessage>());
      final tm = restored as TextMessage;
      expect(tm.id, message.id);
      expect(tm.authorId, message.authorId);
      expect(tm.text, message.text);
      expect(tm.status, message.status);
    });

    test('toString truncates long text', () {
      final long = TextMessage(id: 'long', authorId: 'u1', createdAt: now, text: 'A' * 50);
      expect(long.toString(), contains('...'));
    });

    test('toString does not truncate short text', () {
      expect(message.toString(), contains('Hello, World!'));
      expect(message.toString(), isNot(contains('...')));
    });
  });

  group('ImageMessage', () {
    late ImageMessage message;

    setUp(() {
      message = ImageMessage(
        id: 'img-1',
        authorId: 'user-1',
        createdAt: now,
        imageUrl: 'https://example.com/image.png',
        caption: 'Nice photo',
        width: 640,
        height: 480,
        thumbUrl: 'https://example.com/thumb.png',
      );
    });

    test('has correct fields', () {
      expect(message.imageUrl, 'https://example.com/image.png');
      expect(message.caption, 'Nice photo');
      expect(message.width, 640);
      expect(message.height, 480);
      expect(message.thumbUrl, 'https://example.com/thumb.png');
    });

    test('copyWith replaces specific fields', () {
      final copy = message.copyWith(caption: 'New caption');
      expect(copy.caption, 'New caption');
      expect(copy.imageUrl, message.imageUrl);
    });

    test('toJson/fromJson roundtrip', () {
      final json = message.toJson();
      expect(json['type'], 'image');
      final restored = ChatMessage.fromJson(json) as ImageMessage;
      expect(restored.imageUrl, message.imageUrl);
      expect(restored.caption, message.caption);
      expect(restored.width, message.width);
      expect(restored.height, message.height);
    });
  });

  group('FileMessage', () {
    late FileMessage message;

    setUp(() {
      message = FileMessage(
        id: 'file-1',
        authorId: 'user-1',
        createdAt: now,
        fileUrl: 'https://example.com/doc.pdf',
        fileName: 'doc.pdf',
        fileSize: 1024 * 1024,
        mimeType: 'application/pdf',
      );
    });

    test('has correct fields', () {
      expect(message.fileUrl, 'https://example.com/doc.pdf');
      expect(message.fileName, 'doc.pdf');
      expect(message.fileSize, 1024 * 1024);
      expect(message.mimeType, 'application/pdf');
    });

    test('copyWith replaces specific fields', () {
      final copy = message.copyWith(fileName: 'new.pdf');
      expect(copy.fileName, 'new.pdf');
      expect(copy.fileUrl, message.fileUrl);
    });

    test('toJson/fromJson roundtrip', () {
      final json = message.toJson();
      expect(json['type'], 'file');
      final restored = ChatMessage.fromJson(json) as FileMessage;
      expect(restored.fileUrl, message.fileUrl);
      expect(restored.fileName, message.fileName);
      expect(restored.fileSize, message.fileSize);
      expect(restored.mimeType, message.mimeType);
    });
  });

  group('SystemMessage', () {
    late SystemMessage message;

    setUp(() {
      message = SystemMessage(id: 'sys-1', createdAt: now, text: 'User joined the chat');
    });

    test('authorId is empty string', () {
      expect(message.authorId, '');
    });

    test('isSystem returns true', () {
      expect(message.isSystem, isTrue);
    });

    test('isText returns false', () {
      expect(message.isText, isFalse);
    });

    test('copyWith replaces text', () {
      final copy = message.copyWith(text: 'User left');
      expect(copy.text, 'User left');
      expect(copy.id, 'sys-1');
    });

    test('toJson/fromJson roundtrip', () {
      final json = message.toJson();
      expect(json['type'], 'system');
      expect(json['authorId'], '');
      final restored = ChatMessage.fromJson(json) as SystemMessage;
      expect(restored.text, 'User joined the chat');
    });
  });

  group('CustomMessage', () {
    late CustomMessage message;

    setUp(() {
      message = CustomMessage(
        id: 'custom-1',
        authorId: 'user-1',
        createdAt: now,
        metadata: const {'type': 'poll', 'question': 'Favorite color?'},
      );
    });

    test('has metadata', () {
      expect(message.metadata, isNotNull);
      expect(message.metadata!['type'], 'poll');
    });

    test('copyWith replaces metadata', () {
      final copy = message.copyWith(metadata: const {'type': 'sticker'});
      expect(copy.metadata!['type'], 'sticker');
      expect(copy.id, 'custom-1');
    });

    test('toJson/fromJson roundtrip', () {
      final json = message.toJson();
      expect(json['type'], 'custom');
      final restored = ChatMessage.fromJson(json) as CustomMessage;
      expect(restored.metadata, isNotNull);
    });
  });

  group('ChatMessage.fromJson', () {
    test('throws FormatException for unknown type', () {
      expect(() => ChatMessage.fromJson(const {'type': 'unknown'}), throwsA(isA<FormatException>()));
    });

    test('throws FormatException for null type', () {
      expect(() => ChatMessage.fromJson(const {}), throwsA(isA<FormatException>()));
    });
  });

  group('ChatMessage with metadata and replyToMessageId', () {
    test('TextMessage preserves replyToMessageId in JSON', () {
      final msg = TextMessage(
        id: 'r1',
        authorId: 'u1',
        createdAt: now,
        text: 'Reply',
        replyToMessageId: 'original-123',
        metadata: const {'priority': 'high'},
      );
      final json = msg.toJson();
      expect(json['replyToMessageId'], 'original-123');
      expect(json['metadata'], const {'priority': 'high'});

      final restored = ChatMessage.fromJson(json) as TextMessage;
      expect(restored.replyToMessageId, 'original-123');
    });

    test('updatedAt roundtrips through JSON', () {
      final updated = now.add(const Duration(hours: 1));
      final msg = TextMessage(id: 'u1', authorId: 'a1', createdAt: now, text: 'Edited', updatedAt: updated);
      final json = msg.toJson();
      final restored = ChatMessage.fromJson(json) as TextMessage;
      expect(restored.updatedAt, updated);
      expect(restored.isEdited, isTrue);
    });
  });
}
