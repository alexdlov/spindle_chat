import 'package:flutter_test/flutter_test.dart';
import 'package:spindle_chat/spindle_chat.dart';

void main() {
  final now = DateTime(2025, 1, 15, 12, 0);

  TextMessage makeMessage(String id, {DateTime? createdAt}) =>
      TextMessage(id: id, authorId: 'user-1', createdAt: createdAt ?? now, text: 'Message $id');

  group('ChatOperation', () {
    test('insert carries message and index', () {
      final msg = makeMessage('1');
      final op = ChatOperation.insert(message: msg, index: 0);
      expect(op, isA<ChatOperationInsert>());
      final insert = op as ChatOperationInsert;
      expect(insert.index, 0);
      expect(insert.message.id, '1');
      expect(insert.toString(), contains('insert'));
    });

    test('remove carries message and index', () {
      final msg = makeMessage('1');
      final op = ChatOperation.remove(message: msg, index: 2);
      expect(op, isA<ChatOperationRemove>());
      final remove = op as ChatOperationRemove;
      expect(remove.index, 2);
      expect(remove.message.id, '1');
      expect(remove.toString(), contains('remove'));
    });

    test('update carries old/new message and index', () {
      final old = makeMessage('1');
      final updated = old.copyWith(text: 'Updated');
      final op = ChatOperation.update(oldMessage: old, newMessage: updated, index: 1);
      expect(op, isA<ChatOperationUpdate>());
      final update = op as ChatOperationUpdate;
      expect(update.oldMessage.id, '1');
      expect((update.newMessage as TextMessage).text, 'Updated');
      expect(update.index, 1);
      expect(update.toString(), contains('update'));
    });

    test('set carries message list', () {
      final messages = [makeMessage('1'), makeMessage('2')];
      final op = ChatOperation.set(messages: messages);
      expect(op, isA<ChatOperationSet>());
      final set = op as ChatOperationSet;
      expect(set.messages.length, 2);
      expect(set.toString(), contains('set'));
      expect(set.toString(), contains('2'));
    });

    test('exhaustive switch on ChatOperation', () {
      final msg = makeMessage('1');
      final op = ChatOperation.insert(message: msg, index: 0);

      final description = switch (op) {
        ChatOperationInsert(:final index) => 'insert at $index',
        ChatOperationRemove(:final index) => 'remove at $index',
        ChatOperationUpdate(:final index) => 'update at $index',
        ChatOperationSet(:final messages) => 'set ${messages.length}',
      };
      expect(description, 'insert at 0');
    });
  });

  group('MessageGroupStatus', () {
    test('single shows author and tail', () {
      const status = MessageGroupStatus.single();
      expect(status.showAuthor, isTrue);
      expect(status.showTail, isTrue);
      expect(status.toString(), contains('single'));
    });

    test('first shows author, no tail', () {
      const status = MessageGroupStatus.first();
      expect(status.showAuthor, isTrue);
      expect(status.showTail, isFalse);
      expect(status.toString(), contains('first'));
    });

    test('middle hides author and tail', () {
      const status = MessageGroupStatus.middle();
      expect(status.showAuthor, isFalse);
      expect(status.showTail, isFalse);
      expect(status.toString(), contains('middle'));
    });

    test('last hides author, shows tail', () {
      const status = MessageGroupStatus.last();
      expect(status.showAuthor, isFalse);
      expect(status.showTail, isTrue);
      expect(status.toString(), contains('last'));
    });
  });
}
