import 'package:meta/meta.dart';

import 'chat_message.dart';

/// {@template chat_operation}
/// Represents a single operation on the message list.
///
/// Used to propagate fine-grained changes to the UI layer
/// (e.g. for animated list insertions / removals).
/// {@endtemplate}
@immutable
sealed class ChatOperation {
  const ChatOperation._();

  /// A message was inserted at [index].
  const factory ChatOperation.insert({
    required ChatMessage message,
    required int index,
  }) = ChatOperationInsert;

  /// A message was removed from [index].
  const factory ChatOperation.remove({
    required ChatMessage message,
    required int index,
  }) = ChatOperationRemove;

  /// A message was updated at [index].
  const factory ChatOperation.update({
    required ChatMessage oldMessage,
    required ChatMessage newMessage,
    required int index,
  }) = ChatOperationUpdate;

  /// The entire message list was replaced.
  const factory ChatOperation.set({required List<ChatMessage> messages}) =
      ChatOperationSet;
}

/// {@macro chat_operation}
final class ChatOperationInsert extends ChatOperation {
  const ChatOperationInsert({required this.message, required this.index})
    : super._();

  final ChatMessage message;
  final int index;

  @override
  String toString() => 'ChatOperation.insert(index: $index, id: ${message.id})';
}

/// {@macro chat_operation}
final class ChatOperationRemove extends ChatOperation {
  const ChatOperationRemove({required this.message, required this.index})
    : super._();

  final ChatMessage message;
  final int index;

  @override
  String toString() => 'ChatOperation.remove(index: $index, id: ${message.id})';
}

/// {@macro chat_operation}
final class ChatOperationUpdate extends ChatOperation {
  const ChatOperationUpdate({
    required this.oldMessage,
    required this.newMessage,
    required this.index,
  }) : super._();

  final ChatMessage oldMessage;
  final ChatMessage newMessage;
  final int index;

  @override
  String toString() =>
      'ChatOperation.update(index: $index, id: ${oldMessage.id})';
}

/// {@macro chat_operation}
final class ChatOperationSet extends ChatOperation {
  const ChatOperationSet({required this.messages}) : super._();

  final List<ChatMessage> messages;

  @override
  String toString() => 'ChatOperation.set(count: ${messages.length})';
}
