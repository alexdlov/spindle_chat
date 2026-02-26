import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:spindle_chat/spindle_chat.dart';

void main() {
  final now = DateTime(2025, 1, 15, 12, 0);

  TextMessage makeMessage(String id, {DateTime? createdAt, String authorId = 'user-1'}) =>
      TextMessage(id: id, authorId: authorId, createdAt: createdAt ?? now, text: 'Message $id');

  group('InMemoryChatController', () {
    late InMemoryChatController controller;

    setUp(() {
      controller = InMemoryChatController();
    });

    tearDown(() {
      controller.dispose();
    });

    test('starts with empty messages', () {
      expect(controller.messages, isEmpty);
    });

    test('initialMessages are preserved', () {
      final m1 = makeMessage('1', createdAt: now);
      final m2 = makeMessage('2', createdAt: now.subtract(const Duration(hours: 1)));
      final ctrl = InMemoryChatController(initialMessages: [m1, m2]);
      addTearDown(ctrl.dispose);

      expect(ctrl.messages.length, 2);
      expect(ctrl.messages.first.id, '1');
      expect(ctrl.messages.last.id, '2');
    });

    group('insertMessage', () {
      test('inserts single message', () {
        final msg = makeMessage('1');
        controller.insertMessage(msg);
        expect(controller.messages.length, 1);
        expect(controller.messages.first.id, '1');
      });

      test('maintains descending order by createdAt', () {
        final oldest = makeMessage('old', createdAt: now.subtract(const Duration(hours: 2)));
        final middle = makeMessage('mid', createdAt: now.subtract(const Duration(hours: 1)));
        final newest = makeMessage('new', createdAt: now);

        // Insert out of order.
        controller
          ..insertMessage(middle)
          ..insertMessage(oldest)
          ..insertMessage(newest);

        expect(controller.messages.map((m) => m.id).toList(), ['new', 'mid', 'old']);
      });

      test('emits insert operation', () async {
        final msg = makeMessage('1');
        final ops = <ChatOperation>[];
        controller.operationsStream.listen(ops.add);

        controller.insertMessage(msg);
        await Future<void>.delayed(Duration.zero);

        expect(ops, hasLength(1));
        expect(ops.first, isA<ChatOperationInsert>());
        final insert = ops.first as ChatOperationInsert;
        expect(insert.message.id, '1');
        expect(insert.index, 0);
      });

      test('notifies listeners', () {
        var count = 0;
        controller
          ..addListener(() => count++)
          ..insertMessage(makeMessage('1'));
        expect(count, 1);
      });
    });

    group('insertAllMessages', () {
      test('inserts multiple messages', () {
        final messages = [
          makeMessage('1', createdAt: now),
          makeMessage('2', createdAt: now.subtract(const Duration(hours: 1))),
        ];
        controller.insertAllMessages(messages);
        expect(controller.messages.length, 2);
      });

      test('does nothing for empty list', () async {
        final ops = <ChatOperation>[];
        controller.operationsStream.listen(ops.add);

        controller.insertAllMessages([]);
        await Future<void>.delayed(Duration.zero);

        expect(controller.messages, isEmpty);
        expect(ops, isEmpty);
      });

      test('emits set operation', () async {
        final ops = <ChatOperation>[];
        controller.operationsStream.listen(ops.add);

        controller.insertAllMessages([makeMessage('1')]);
        await Future<void>.delayed(Duration.zero);

        expect(ops, hasLength(1));
        expect(ops.first, isA<ChatOperationSet>());
      });

      test('sorts messages correctly', () {
        final oldest = makeMessage('old', createdAt: now.subtract(const Duration(hours: 2)));
        final newest = makeMessage('new', createdAt: now);

        controller.insertAllMessages([oldest, newest]);
        expect(controller.messages.first.id, 'new');
        expect(controller.messages.last.id, 'old');
      });
    });

    group('updateMessage', () {
      test('replaces message by id', () {
        final original = makeMessage('1');
        controller.insertMessage(original);

        final updated = original.copyWith(text: 'Updated');
        controller.updateMessage(original, updated);

        expect(controller.messages.length, 1);
        expect((controller.messages.first as TextMessage).text, 'Updated');
      });

      test('emits update operation', () async {
        final msg = makeMessage('1');
        controller.insertMessage(msg);

        final ops = <ChatOperation>[];
        controller.operationsStream.listen(ops.add);

        final updated = msg.copyWith(text: 'Updated');
        controller.updateMessage(msg, updated);
        await Future<void>.delayed(Duration.zero);

        expect(ops, hasLength(1));
        expect(ops.first, isA<ChatOperationUpdate>());
        final update = ops.first as ChatOperationUpdate;
        expect(update.oldMessage.id, '1');
        expect((update.newMessage as TextMessage).text, 'Updated');
      });

      test('does nothing for non-existent message', () async {
        final ops = <ChatOperation>[];
        controller.operationsStream.listen(ops.add);

        final msg = makeMessage('nonexistent');
        controller.updateMessage(msg, msg.copyWith(text: 'Updated'));
        await Future<void>.delayed(Duration.zero);

        expect(ops, isEmpty);
      });
    });

    group('removeMessage', () {
      test('removes message by id', () {
        final msg = makeMessage('1');
        controller.insertMessage(msg);
        expect(controller.messages.length, 1);

        controller.removeMessage(msg);
        expect(controller.messages, isEmpty);
      });

      test('emits remove operation', () async {
        final msg = makeMessage('1');
        controller.insertMessage(msg);

        final ops = <ChatOperation>[];
        controller.operationsStream.listen(ops.add);

        controller.removeMessage(msg);
        await Future<void>.delayed(Duration.zero);

        expect(ops, hasLength(1));
        expect(ops.first, isA<ChatOperationRemove>());
        final remove = ops.first as ChatOperationRemove;
        expect(remove.message.id, '1');
        expect(remove.index, 0);
      });

      test('does nothing for non-existent message', () async {
        final ops = <ChatOperation>[];
        controller.operationsStream.listen(ops.add);

        controller.removeMessage(makeMessage('nonexistent'));
        await Future<void>.delayed(Duration.zero);

        expect(ops, isEmpty);
      });
    });

    group('setMessages', () {
      test('replaces entire message list', () {
        controller.insertMessage(makeMessage('old'));
        expect(controller.messages.length, 1);

        controller.setMessages([makeMessage('new-1'), makeMessage('new-2')]);
        expect(controller.messages.length, 2);
        expect(controller.messages.any((m) => m.id == 'old'), isFalse);
      });

      test('emits set operation', () async {
        final ops = <ChatOperation>[];
        controller.operationsStream.listen(ops.add);

        controller.setMessages([makeMessage('1')]);
        await Future<void>.delayed(Duration.zero);

        expect(ops, hasLength(1));
        expect(ops.first, isA<ChatOperationSet>());
        final set = ops.first as ChatOperationSet;
        expect(set.messages.length, 1);
      });
    });

    group('messages list', () {
      test('returns unmodifiable view', () {
        controller.insertMessage(makeMessage('1'));
        expect(() => (controller.messages as List).add(makeMessage('2')), throwsA(isA<UnsupportedError>()));
      });

      test('caches unmodifiable view', () {
        controller.insertMessage(makeMessage('1'));
        final view1 = controller.messages;
        final view2 = controller.messages;
        expect(identical(view1, view2), isTrue);
      });

      test('invalidates cache on mutation', () {
        controller.insertMessage(makeMessage('1'));
        final view1 = controller.messages;
        controller.insertMessage(makeMessage('2', createdAt: now.add(const Duration(hours: 1))));
        final view2 = controller.messages;
        expect(identical(view1, view2), isFalse);
      });
    });

    group('dispose', () {
      test('closes operations stream', () async {
        // Create a separate controller so tearDown does not double-dispose.
        final ctrl = InMemoryChatController();
        final completer = Completer<void>();
        ctrl.operationsStream.listen(null, onDone: completer.complete);

        ctrl.dispose();

        await completer.future;
        // If we reach here, the stream was closed.
      });
    });

    group('operationsStream', () {
      test('is broadcast stream', () {
        final sub1 = controller.operationsStream.listen((_) {});
        final sub2 = controller.operationsStream.listen((_) {});
        addTearDown(() {
          sub1.cancel();
          sub2.cancel();
        });
        // Both subscriptions can coexist.
      });

      test('delivers operations in order', () async {
        final ops = <ChatOperation>[];
        controller.operationsStream.listen(ops.add);

        final m1 = makeMessage('1', createdAt: now);
        final m2 = makeMessage('2', createdAt: now.add(const Duration(hours: 1)));

        controller
          ..insertMessage(m1)
          ..insertMessage(m2)
          ..removeMessage(m1);

        await Future<void>.delayed(Duration.zero);

        expect(ops.length, 3);
        expect(ops[0], isA<ChatOperationInsert>());
        expect(ops[1], isA<ChatOperationInsert>());
        expect(ops[2], isA<ChatOperationRemove>());
      });
    });
  });
}
