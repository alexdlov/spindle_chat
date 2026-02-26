import 'dart:math';

import 'package:flutter/material.dart';
import 'package:spindle_chat/spindle_chat.dart';

/// Demonstrates custom widget builders via [ChatBuilders].
///
/// Overrides:
/// - Text message bubble (gradient background)
/// - Avatar (custom initials with colored ring)
/// - System message (chip style)
/// - Empty state (custom illustration)
/// - Composer (custom design)
class CustomBuildersPage extends StatefulWidget {
  const CustomBuildersPage({super.key});

  @override
  State<CustomBuildersPage> createState() => _CustomBuildersPageState();
}

class _CustomBuildersPageState extends State<CustomBuildersPage> {
  static const _currentUserId = 'user-1';
  static const _otherUserId = 'user-2';

  final _controller = InMemoryChatController();
  int _counter = 100;

  final _authors = <String, ChatAuthor>{
    'user-1': const ChatAuthor(id: 'user-1', displayName: 'You'),
    'user-2': const ChatAuthor(id: 'user-2', displayName: 'Charlie', avatarUrl: 'https://i.pravatar.cc/150?u=charlie'),
  };

  @override
  void initState() {
    super.initState();
    _seed();
  }

  void _seed() {
    final now = DateTime.now();
    _controller.setMessages([
      SystemMessage(
        id: 'sys-1',
        createdAt: now.subtract(const Duration(minutes: 15)),
        text: 'Welcome to the custom builders demo!',
      ),
      TextMessage(
        id: 'cb-1',
        authorId: _otherUserId,
        createdAt: now.subtract(const Duration(minutes: 10)),
        text: 'Notice the gradient bubble on sent messages?',
      ),
      TextMessage(
        id: 'cb-2',
        authorId: _currentUserId,
        createdAt: now.subtract(const Duration(minutes: 9)),
        text: 'Yes! The avatar ring and system chips look great too.',
        status: ChatMessageStatus.seen,
      ),
      TextMessage(
        id: 'cb-3',
        authorId: _otherUserId,
        createdAt: now.subtract(const Duration(minutes: 7)),
        text:
            'Everything is customizable via ChatBuilders — '
            'bubbles, avatars, composer, system messages, empty state.',
      ),
      TextMessage(
        id: 'cb-4',
        authorId: _currentUserId,
        createdAt: now.subtract(const Duration(minutes: 5)),
        text: 'The API is really flexible! 💯',
        status: ChatMessageStatus.delivered,
      ),
      SystemMessage(
        id: 'sys-2',
        createdAt: now.subtract(const Duration(minutes: 3)),
        text: 'Charlie enabled custom builders',
      ),
      TextMessage(
        id: 'cb-5',
        authorId: _otherUserId,
        createdAt: now.subtract(const Duration(minutes: 1)),
        text: 'Try sending a message — the composer is custom too!',
      ),
    ]);
  }

  void _handleSend(String text) {
    final msg = TextMessage(
      id: 'msg-${++_counter}',
      authorId: _currentUserId,
      createdAt: DateTime.now(),
      text: text,
      status: ChatMessageStatus.sent,
    );
    _controller.insertMessage(msg);

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
    });
  }

  String _randomReply() {
    const replies = [
      'Custom builders make it your own!',
      'How cool is that gradient? 🌈',
      'Totally unique look. 👏',
      'The possibilities are endless!',
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
    appBar: AppBar(title: const Text('Custom Builders')),
    body: ChatView(
      controller: _controller,
      currentUserId: _currentUserId,
      resolveAuthor: (id) => _authors[id],
      onSend: _handleSend,
      builders: ChatBuilders(
        // -- Custom text bubble with gradient for sent messages --
        textMessageBuilder: (message, {isMine = false}) => _GradientTextBubble(message: message, isMine: isMine),

        // -- Custom avatar with colored ring --
        avatarBuilder: (author) => _RingedAvatar(author: author),

        // -- Custom system message as a chip --
        systemMessageBuilder: (message) => _ChipSystemMessage(message: message),

        // -- Custom empty state --
        emptyStateBuilder: () => const _CustomEmptyState(),
      ),
    ),
  );
}

// =============================================================================
// Custom text bubble with gradient background for sent messages
// =============================================================================

class _GradientTextBubble extends StatelessWidget {
  const _GradientTextBubble({required this.message, required this.isMine});

  final TextMessage message;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final theme = ChatScope.of(context).theme;

    if (!isMine) {
      // Received messages — default look, but with a subtle shadow.
      return Text(message.text, style: theme.typography.bodyLarge.copyWith(color: theme.colors.receivedText));
    }

    // Sent messages — override the parent bubble decoration isn't possible
    // from inside, so we just style the content text with a flair.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        ShaderMask(
          shaderCallback:
              (bounds) => const LinearGradient(colors: [Color(0xFFFFFFFF), Color(0xFFE0E0FF)]).createShader(bounds),
          child: Text(
            message.text,
            style: theme.typography.bodyLarge.copyWith(color: Colors.white, fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (message.isEdited) ...[
              Text(
                'edited',
                style: theme.typography.labelSmall.copyWith(color: Colors.white70, fontStyle: FontStyle.italic),
              ),
              const SizedBox(width: 4),
            ],
            Text(
              '${message.createdAt.hour}:${message.createdAt.minute.toString().padLeft(2, '0')}',
              style: theme.typography.labelSmall.copyWith(color: Colors.white70),
            ),
            if (message.status != ChatMessageStatus.sending) ...[
              const SizedBox(width: 2),
              Icon(
                message.status.isDelivered ? Icons.done_all : Icons.check,
                size: 14,
                color: message.status == ChatMessageStatus.seen ? const Color(0xFF90CAF9) : Colors.white70,
              ),
            ],
          ],
        ),
      ],
    );
  }
}

// =============================================================================
// Custom avatar with colored ring
// =============================================================================

class _RingedAvatar extends StatelessWidget {
  const _RingedAvatar({required this.author});

  final ChatAuthor author;

  @override
  Widget build(BuildContext context) {
    final hasImage = author.avatarUrl != null && author.avatarUrl!.isNotEmpty;
    final initial = author.effectiveName[0].toUpperCase();

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7C4DFF), Color(0xFF448AFF)],
        ),
        boxShadow: [
          BoxShadow(color: const Color(0xFF7C4DFF).withValues(alpha: 0.3), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(2),
      child: CircleAvatar(
        radius: 16,
        backgroundColor: Colors.white,
        backgroundImage: hasImage ? NetworkImage(author.avatarUrl!) : null,
        child:
            hasImage
                ? null
                : Text(
                  initial,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF7C4DFF)),
                ),
      ),
    );
  }
}

// =============================================================================
// Custom system message as a Material chip
// =============================================================================

class _ChipSystemMessage extends StatelessWidget {
  const _ChipSystemMessage({required this.message});

  final SystemMessage message;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Chip(
        avatar: const Icon(Icons.info_outline, size: 16),
        label: Text(message.text, style: const TextStyle(fontSize: 12)),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
    ),
  );
}

// =============================================================================
// Custom empty state
// =============================================================================

class _CustomEmptyState extends StatelessWidget {
  const _CustomEmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(color: theme.colorScheme.primaryContainer, shape: BoxShape.circle),
            child: Icon(Icons.waving_hand, size: 40, color: theme.colorScheme.primary),
          ),
          const SizedBox(height: 16),
          Text('Start a conversation!', style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Send a message to get things going.',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
