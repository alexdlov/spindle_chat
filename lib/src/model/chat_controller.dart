import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:spindle_chat/src/model/chat_message.dart';
import 'package:spindle_chat/src/model/chat_operation.dart';

/// {@template chat_controller}
/// Interface for managing a list of chat messages.
///
/// Provides reactive access to the message list and a stream of
/// [ChatOperation] events for fine-grained UI updates.
///
/// Implementations must maintain the list sorted by [ChatMessage.createdAt]
/// in descending order (newest first), matching reverse-scrolled lists.
/// {@endtemplate}
abstract interface class ChatController implements Listenable {
  /// Current list of messages (newest first).
  List<ChatMessage> get messages;

  /// Stream of operations for animated list synchronization.
  Stream<ChatOperation> get operationsStream;

  /// Insert a single message at the appropriate sorted position.
  void insertMessage(ChatMessage message);

  /// Insert multiple messages (e.g. pagination batch).
  void insertAllMessages(List<ChatMessage> messages);

  /// Replace [oldMessage] with [newMessage] (matched by id).
  void updateMessage(ChatMessage oldMessage, ChatMessage newMessage);

  /// Remove a message (matched by id).
  void removeMessage(ChatMessage message);

  /// Replace the entire list.
  void setMessages(List<ChatMessage> messages);

  /// Release resources.
  void dispose();
}

/// {@template in_memory_chat_controller}
/// Default in-memory [ChatController] backed by [ChangeNotifier].
///
/// Maintains a sorted list (newest first), emits [ChatOperation] events
/// on mutations, and caches the public unmodifiable view for performance.
/// {@endtemplate}
class InMemoryChatController extends ChangeNotifier implements ChatController {
  /// {@macro in_memory_chat_controller}
  InMemoryChatController({List<ChatMessage>? initialMessages})
    : _messages = List<ChatMessage>.of(initialMessages ?? const <ChatMessage>[]);

  final List<ChatMessage> _messages;
  final StreamController<ChatOperation> _operationsController = StreamController<ChatOperation>.broadcast();

  /// Cached unmodifiable view, invalidated on mutation.
  List<ChatMessage>? _cachedView;
  bool _disposed = false;

  @override
  @nonVirtual
  List<ChatMessage> get messages => _cachedView ??= List<ChatMessage>.unmodifiable(_messages);

  @override
  @nonVirtual
  Stream<ChatOperation> get operationsStream => _operationsController.stream;

  void _invalidateCache() => _cachedView = null;

  void _emit(ChatOperation op) {
    if (_disposed) return;
    _invalidateCache();
    _operationsController.add(op);
    notifyListeners();
  }

  @override
  void insertMessage(ChatMessage message) {
    // Binary-search style insert into descending-sorted list.
    var index = 0;
    for (; index < _messages.length; index++) {
      if (message.createdAt.isAfter(_messages[index].createdAt)) break;
    }
    _messages.insert(index, message);
    _emit(ChatOperation.insert(message: message, index: index));
  }

  @override
  void insertAllMessages(List<ChatMessage> messages) {
    if (messages.isEmpty) return;
    for (final message in messages) {
      var index = 0;
      for (; index < _messages.length; index++) {
        if (message.createdAt.isAfter(_messages[index].createdAt)) break;
      }
      _messages.insert(index, message);
    }
    _emit(ChatOperation.set(messages: List<ChatMessage>.unmodifiable(_messages)));
  }

  @override
  void updateMessage(ChatMessage oldMessage, ChatMessage newMessage) {
    final index = _messages.indexWhere((m) => m.id == oldMessage.id);
    if (index == -1) return;
    _messages[index] = newMessage;
    _emit(ChatOperation.update(oldMessage: oldMessage, newMessage: newMessage, index: index));
  }

  @override
  void removeMessage(ChatMessage message) {
    final index = _messages.indexWhere((m) => m.id == message.id);
    if (index == -1) return;
    _messages.removeAt(index);
    _emit(ChatOperation.remove(message: message, index: index));
  }

  @override
  void setMessages(List<ChatMessage> messages) {
    _messages
      ..clear()
      ..addAll(messages);
    _emit(ChatOperation.set(messages: List<ChatMessage>.unmodifiable(_messages)));
  }

  @override
  void dispose() {
    _disposed = true;
    _operationsController.close();
    super.dispose();
  }
}
