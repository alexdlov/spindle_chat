import 'dart:math';

import 'package:flutter/material.dart';
import 'package:spindle_chat/spindle_chat.dart';

void main() => runApp(const SpindleChatExampleApp());

/// Example app showcasing the spindle_chat package.
class SpindleChatExampleApp extends StatelessWidget {
  const SpindleChatExampleApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'spindle_chat Example',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(colorSchemeSeed: Colors.indigo, brightness: Brightness.light, useMaterial3: true),
    darkTheme: ThemeData(colorSchemeSeed: Colors.indigo, brightness: Brightness.dark, useMaterial3: true),
    home: const ChatExamplePage(),
  );
}

class ChatExamplePage extends StatefulWidget {
  const ChatExamplePage({super.key});

  @override
  State<ChatExamplePage> createState() => _ChatExamplePageState();
}

class _ChatExamplePageState extends State<ChatExamplePage> {
  static const _currentUserId = 'user-1';
  static const _otherUserId = 'user-2';

  final _controller = InMemoryChatController();
  int _messageCounter = 0;

  final _authors = <String, ChatAuthor>{
    'user-1': const ChatAuthor(id: 'user-1', displayName: 'You'),
    'user-2': const ChatAuthor(id: 'user-2', displayName: 'Alice', avatarUrl: 'https://i.pravatar.cc/150?u=alice'),
  };

  @override
  void initState() {
    super.initState();
    _loadInitialMessages();
  }

  void _loadInitialMessages() {
    final now = DateTime.now();
    _controller.setMessages([
      TextMessage(
        id: 'msg-1',
        authorId: _otherUserId,
        createdAt: now.subtract(const Duration(minutes: 5)),
        text: 'Hey! Have you tried spindle_chat yet?',
      ),
      TextMessage(
        id: 'msg-2',
        authorId: _currentUserId,
        createdAt: now.subtract(const Duration(minutes: 4)),
        text: 'Just setting it up now — looks great! 🎉',
        status: ChatMessageStatus.seen,
      ),
      TextMessage(
        id: 'msg-3',
        authorId: _otherUserId,
        createdAt: now.subtract(const Duration(minutes: 3)),
        text:
            'The theming support is really nice. '
            'Try ChatTheme.fromThemeData() to match your app.',
      ),
    ]);
  }

  void _handleSend(String text) {
    final message = TextMessage(
      id: 'msg-${++_messageCounter}',
      authorId: _currentUserId,
      createdAt: DateTime.now(),
      text: text,
      status: ChatMessageStatus.sending,
    );
    _controller.insertMessage(message);

    // Simulate delivery after a short delay.
    Future.delayed(const Duration(seconds: 1), () {
      _controller.updateMessage(message, message.copyWith(status: ChatMessageStatus.delivered));
    });

    // Simulate a reply from the other user.
    Future.delayed(const Duration(seconds: 2), () {
      _controller.insertMessage(
        TextMessage(
          id: 'reply-${Random().nextInt(100000)}',
          authorId: _otherUserId,
          createdAt: DateTime.now(),
          text: _randomReply(),
        ),
      );
    });
  }

  String _randomReply() {
    const replies = [
      'Interesting! Tell me more.',
      'Got it 👍',
      'That makes sense.',
      'Let me think about that…',
      'Nice one!',
      '🚀',
    ];
    return replies[Random().nextInt(replies.length)];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('spindle_chat Example')),
    body: ChatView(
      controller: _controller,
      currentUserId: _currentUserId,
      resolveAuthor: (id) => _authors[id],
      onSend: _handleSend,
      l10n: const ChatL10n(
        inputHint: 'Type a message…',
        emptyStateText: 'No messages yet',
        today: 'Today',
        yesterday: 'Yesterday',
      ),
    ),
  );
}
