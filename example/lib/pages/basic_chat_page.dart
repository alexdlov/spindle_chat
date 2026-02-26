import 'dart:math';

import 'package:flutter/material.dart';
import 'package:spindle_chat/spindle_chat.dart';

/// Basic two-user chat with simulated auto-replies and delivery statuses.
///
/// Demonstrates:
/// - [InMemoryChatController] with initial messages
/// - Message insertion with animated transitions
/// - Delivery status progression: sending → delivered → seen
/// - Auto-reply simulation
/// - Message grouping (consecutive same-author messages)
/// - Date separators
class BasicChatPage extends StatefulWidget {
  const BasicChatPage({super.key});

  @override
  State<BasicChatPage> createState() => _BasicChatPageState();
}

class _BasicChatPageState extends State<BasicChatPage> {
  static const _currentUserId = 'user-1';
  static const _otherUserId = 'user-2';

  final _controller = InMemoryChatController();
  int _messageCounter = 100;

  final _authors = <String, ChatAuthor>{
    'user-1': const ChatAuthor(id: 'user-1', displayName: 'You'),
    'user-2': const ChatAuthor(
      id: 'user-2',
      displayName: 'Alice',
      avatarUrl: 'https://i.pravatar.cc/150?u=alice',
    ),
  };

  @override
  void initState() {
    super.initState();
    _seedConversation();
  }

  /// Pre-populate a realistic conversation history.
  void _seedConversation() {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));

    _controller.setMessages([
      // Yesterday's messages
      TextMessage(
        id: 'seed-1',
        authorId: _otherUserId,
        createdAt: yesterday.copyWith(hour: 14, minute: 30),
        text: 'Hey! Have you seen the new spindle_chat package?',
        status: ChatMessageStatus.seen,
      ),
      TextMessage(
        id: 'seed-2',
        authorId: _currentUserId,
        createdAt: yesterday.copyWith(hour: 14, minute: 31),
        text: 'Not yet, what is it? 🤔',
        status: ChatMessageStatus.seen,
      ),
      TextMessage(
        id: 'seed-3',
        authorId: _otherUserId,
        createdAt: yesterday.copyWith(hour: 14, minute: 32),
        text:
            'A composable chat UI for Flutter — sealed message types, '
            'animated list, theming, the works!',
        status: ChatMessageStatus.seen,
      ),
      TextMessage(
        id: 'seed-4',
        authorId: _otherUserId,
        createdAt: yesterday.copyWith(hour: 14, minute: 32, second: 30),
        text: 'No codegen, no heavy deps 💪',
        status: ChatMessageStatus.seen,
      ),
      TextMessage(
        id: 'seed-5',
        authorId: _currentUserId,
        createdAt: yesterday.copyWith(hour: 14, minute: 34),
        text: 'That sounds great! I\'ll check it out.',
        status: ChatMessageStatus.seen,
      ),

      // Today's messages
      TextMessage(
        id: 'seed-6',
        authorId: _currentUserId,
        createdAt: now.subtract(const Duration(minutes: 10)),
        text: 'Just integrated it into my project — really clean API! 🎉',
        status: ChatMessageStatus.seen,
      ),
      TextMessage(
        id: 'seed-7',
        authorId: _otherUserId,
        createdAt: now.subtract(const Duration(minutes: 8)),
        text: 'Right? The theming is my favorite part.',
      ),
      TextMessage(
        id: 'seed-8',
        authorId: _otherUserId,
        createdAt: now.subtract(const Duration(minutes: 7, seconds: 30)),
        text: 'Try ChatTheme.fromThemeData() to match your app automatically.',
      ),
      TextMessage(
        id: 'seed-9',
        authorId: _currentUserId,
        createdAt: now.subtract(const Duration(minutes: 5)),
        text: 'Will do! Also love the exhaustive switch on message types.',
        status: ChatMessageStatus.delivered,
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

    // Simulate delivery status progression.
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      _controller.updateMessage(
        message,
        message.copyWith(status: ChatMessageStatus.sent),
      );
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      _controller.updateMessage(
        message,
        message.copyWith(status: ChatMessageStatus.delivered),
      );
    });

    // Auto-reply from Alice.
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      _controller.insertMessage(
        TextMessage(
          id: 'reply-${Random().nextInt(999999)}',
          authorId: _otherUserId,
          createdAt: DateTime.now(),
          text: _randomReply(),
        ),
      );

      // Mark our message as seen after Alice "reads" it.
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        _controller.updateMessage(
          message,
          message.copyWith(status: ChatMessageStatus.seen),
        );
      });
    });
  }

  String _randomReply() {
    const replies = [
      'Interesting! Tell me more. 😊',
      'Got it 👍',
      'That makes sense.',
      'Let me think about that…',
      'Nice one! 🎯',
      '🚀',
      'Absolutely, I agree!',
      'Good point, I hadn\'t thought of that.',
      'Ha, that\'s cool!',
      'Love it! Keep going.',
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
    appBar: AppBar(
      title: Row(
        children: [
          const CircleAvatar(
            radius: 16,
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=alice'),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Alice', style: Theme.of(context).textTheme.titleMedium),
              Text(
                'online',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.green),
              ),
            ],
          ),
        ],
      ),
    ),
    body: ChatView(
      controller: _controller,
      currentUserId: _currentUserId,
      resolveAuthor: (id) => _authors[id],
      onSend: _handleSend,
      onAttachmentTap: () => _showAttachmentSheet(context),
      l10n: const ChatL10n(
        inputHint: 'Type a message…',
        emptyStateText: 'No messages yet',
        today: 'Today',
        yesterday: 'Yesterday',
      ),
    ),
  );

  void _showAttachmentSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder:
          (ctx) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.photo)),
                  title: const Text('Photo'),
                  subtitle: const Text('Send an image'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _sendDemoImage();
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.insert_drive_file),
                  ),
                  title: const Text('File'),
                  subtitle: const Text('Send a document'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _sendDemoFile();
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _sendDemoImage() {
    final id = 'img-${++_messageCounter}';
    _controller.insertMessage(
      ImageMessage(
        id: id,
        authorId: _currentUserId,
        createdAt: DateTime.now(),
        imageUrl: 'https://picsum.photos/seed/$id/400/300',
        caption: 'Sent from the attachment picker',
        status: ChatMessageStatus.sending,
      ),
    );
  }

  void _sendDemoFile() {
    _controller.insertMessage(
      FileMessage(
        id: 'file-${++_messageCounter}',
        authorId: _currentUserId,
        createdAt: DateTime.now(),
        fileUrl: 'https://example.com/document.pdf',
        fileName: 'report_${DateTime.now().millisecondsSinceEpoch}.pdf',
        fileSize: 1048576 + Random().nextInt(4194304),
        mimeType: 'application/pdf',
        status: ChatMessageStatus.sending,
      ),
    );
  }
}
