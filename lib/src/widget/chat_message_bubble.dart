import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../model/chat_message.dart';
import '../model/message_group_status.dart';
import 'chat_scope.dart';

/// {@template chat_message_bubble}
/// A single message bubble with avatar, username, content, and timestamp.
///
/// Adapts appearance based on ownership and [groupStatus].
/// {@endtemplate}
class ChatMessageBubble extends StatelessWidget {
  /// {@macro chat_message_bubble}
  const ChatMessageBubble({
    required this.message,
    required this.groupStatus,
    super.key,
  });

  /// The message data to display.
  final ChatMessage message;

  /// Position within a message group (affects corners, avatar, spacing).
  final MessageGroupStatus groupStatus;

  @override
  Widget build(BuildContext context) {
    final scope = ChatScope.of(context);
    final isMine = message.authorId == scope.currentUserId;

    // System messages have their own layout.
    if (message case final SystemMessage sys) {
      return _buildSystemMessage(scope, sys);
    }

    final content = _buildBubbleContent(scope, isMine);
    final wrapped =
        scope.builders.messageWrapperBuilder?.call(message, isMine, content) ??
        content;

    return Semantics(
      label: _semanticLabel(scope, isMine),
      child: Padding(
        padding: EdgeInsets.only(
          top: groupStatus.showAuthor ? 8 : 2,
          bottom: 2,
          left: isMine ? 48 : 8,
          right: isMine ? 8 : 48,
        ),
        child: Row(
          mainAxisAlignment:
              isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isMine && groupStatus.showTail) ...[
              _buildAvatar(scope),
              const SizedBox(width: 6),
            ] else if (!isMine) ...[
              const SizedBox(width: 38),
            ],
            Flexible(
              child: Column(
                crossAxisAlignment:
                    isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  if (!isMine && groupStatus.showAuthor) _buildUsername(scope),
                  // Tap / long-press handlers
                  GestureDetector(
                    onTap:
                        scope.onMessageTap != null
                            ? () => scope.onMessageTap!(message)
                            : null,
                    onLongPress:
                        scope.onMessageLongPress != null
                            ? () => scope.onMessageLongPress!(message)
                            : null,
                    child: wrapped,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // System message
  // ---------------------------------------------------------------------------

  Widget _buildSystemMessage(ChatScope scope, SystemMessage sys) {
    final builder = scope.builders.systemMessageBuilder;
    if (builder != null) return builder(sys);

    return Semantics(
      label: sys.text,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Text(
            sys.text,
            textAlign: TextAlign.center,
            style: scope.theme.typography.bodySmall.copyWith(
              color: scope.theme.colors.system,
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Bubble content
  // ---------------------------------------------------------------------------

  Widget _buildBubbleContent(ChatScope scope, bool isMine) {
    final theme = scope.theme;

    final child = switch (message) {
      final TextMessage m =>
        scope.builders.textMessageBuilder?.call(m, isMine) ??
            _DefaultTextContent(message: m, isMine: isMine),
      final ImageMessage m =>
        scope.builders.imageMessageBuilder?.call(m, isMine) ??
            _DefaultImageContent(message: m, isMine: isMine),
      final FileMessage m =>
        scope.builders.fileMessageBuilder?.call(m, isMine) ??
            _DefaultFileContent(message: m, isMine: isMine),
      final CustomMessage m =>
        scope.builders.customMessageBuilder?.call(m, isMine) ??
            const SizedBox.shrink(),
      SystemMessage() => const SizedBox.shrink(), // handled above
    };

    final bgColor =
        isMine ? theme.colors.sentBubble : theme.colors.receivedBubble;

    return DecoratedBox(
      decoration: ShapeDecoration(color: bgColor, shape: _bubbleShape(isMine)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: child,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Bubble shape — adaptive corners based on group status
  // ---------------------------------------------------------------------------

  RoundedRectangleBorder _bubbleShape(bool isMine) {
    const r = Radius.circular(16);
    const s = Radius.circular(4);

    // (isMine, isFirst/single, isLast/single)
    final (tl, tr, bl, br) = switch ((
      isMine,
      groupStatus.showAuthor,
      groupStatus.showTail,
    )) {
      // Sent messages — tail = bottom-right
      (true, true, true) => (r, r, r, s), // single
      (true, true, false) => (r, r, r, s), // first
      (true, false, false) => (r, s, r, s), // middle
      (true, false, true) => (r, s, r, s), // last
      // Received messages — tail = bottom-left
      (false, true, true) => (r, r, s, r), // single
      (false, true, false) => (r, r, s, r), // first
      (false, false, false) => (s, r, s, r), // middle
      (false, false, true) => (s, r, s, r), // last
    };

    return RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: tl,
        topRight: tr,
        bottomLeft: bl,
        bottomRight: br,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Avatar
  // ---------------------------------------------------------------------------

  Widget _buildAvatar(ChatScope scope) {
    final author = scope.resolveAuthor?.call(message.authorId);
    if (scope.builders.avatarBuilder != null && author != null) {
      return scope.builders.avatarBuilder!(author);
    }

    final theme = scope.theme;
    final avatarUrl = author?.avatarUrl;
    final hasAvatar = avatarUrl != null && avatarUrl.isNotEmpty;
    final initial = (author?.effectiveName ?? '?')[0].toUpperCase();

    return SizedBox(
      width: 32,
      height: 32,
      child: CircleAvatar(
        backgroundColor: theme.colors.receivedBubble,
        backgroundImage: hasAvatar ? NetworkImage(avatarUrl) : null,
        child:
            hasAvatar
                ? null
                : Text(
                  initial,
                  style: theme.typography.bodySmall.copyWith(
                    color: theme.colors.onSurface,
                  ),
                ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Username
  // ---------------------------------------------------------------------------

  Widget _buildUsername(ChatScope scope) {
    final author = scope.resolveAuthor?.call(message.authorId);
    if (author == null) return const SizedBox.shrink();
    if (scope.builders.usernameBuilder != null) {
      return scope.builders.usernameBuilder!(author);
    }

    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 2),
      child: Text(
        author.effectiveName,
        style: scope.theme.typography.bodySmall.copyWith(
          color: scope.theme.colors.timestamp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Semantics helper
  // ---------------------------------------------------------------------------

  String _semanticLabel(ChatScope scope, bool isMine) {
    final author = scope.resolveAuthor?.call(message.authorId);
    final who = isMine ? 'You' : (author?.effectiveName ?? 'Unknown');
    final body = switch (message) {
      TextMessage(:final text) => text,
      ImageMessage(:final caption) => caption ?? 'Image',
      FileMessage(:final fileName) => 'File: $fileName',
      SystemMessage(:final text) => text,
      CustomMessage() => 'Custom message',
    };
    return '$who: $body';
  }
}

// =============================================================================
// Default message content widgets
// =============================================================================

class _DefaultTextContent extends StatelessWidget {
  const _DefaultTextContent({required this.message, required this.isMine});

  final TextMessage message;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final theme = ChatScope.of(context).theme;
    final textColor =
        isMine ? theme.colors.sentText : theme.colors.receivedText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          message.text,
          style: theme.typography.bodyLarge.copyWith(color: textColor),
        ),
        const SizedBox(height: 2),
        _MessageTimestamp(
          time: message.createdAt,
          color: textColor.withValues(alpha: 0.6),
          status: isMine ? message.status : null,
          isEdited: message.isEdited,
        ),
      ],
    );
  }
}

class _DefaultImageContent extends StatelessWidget {
  const _DefaultImageContent({required this.message, required this.isMine});

  final ImageMessage message;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final theme = ChatScope.of(context).theme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 200, maxWidth: 250),
            child: Image.network(
              message.imageUrl,
              fit: BoxFit.cover,
              errorBuilder:
                  (_, __, ___) => Container(
                    height: 100,
                    color: theme.colors.divider,
                    child: Icon(
                      Icons.broken_image,
                      color: theme.colors.timestamp,
                    ),
                  ),
            ),
          ),
        ),
        if (message.caption case final String caption) ...[
          const SizedBox(height: 4),
          Text(
            caption,
            style: theme.typography.bodyMedium.copyWith(
              color: isMine ? theme.colors.sentText : theme.colors.receivedText,
            ),
          ),
        ],
      ],
    );
  }
}

class _DefaultFileContent extends StatelessWidget {
  const _DefaultFileContent({required this.message, required this.isMine});

  final FileMessage message;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final theme = ChatScope.of(context).theme;
    final textColor =
        isMine ? theme.colors.sentText : theme.colors.receivedText;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.insert_drive_file, color: textColor, size: 24),
        const SizedBox(width: 8),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message.fileName,
                style: theme.typography.bodyMedium.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (message.fileSize case final int size)
                Text(
                  _formatFileSize(size),
                  style: theme.typography.bodySmall.copyWith(
                    color: textColor.withValues(alpha: 0.6),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  static String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

// =============================================================================
// Shared timestamp widget
// =============================================================================

class _MessageTimestamp extends StatelessWidget {
  const _MessageTimestamp({
    required this.time,
    required this.color,
    this.status,
    this.isEdited = false,
  });

  final DateTime time;
  final Color color;
  final ChatMessageStatus? status;
  final bool isEdited;

  static final DateFormat _timeFormat = DateFormat.Hm();

  @override
  Widget build(BuildContext context) {
    final theme = ChatScope.of(context).theme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isEdited) ...[
          Text(
            'edited',
            style: theme.typography.labelSmall.copyWith(
              color: color,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(width: 4),
        ],
        Text(
          _timeFormat.format(time),
          style: theme.typography.labelSmall.copyWith(color: color),
        ),
        if (status != null) ...[
          const SizedBox(width: 2),
          Icon(
            switch (status!) {
              ChatMessageStatus.sending => Icons.access_time,
              ChatMessageStatus.sent => Icons.check,
              ChatMessageStatus.delivered => Icons.done_all,
              ChatMessageStatus.seen => Icons.done_all,
              ChatMessageStatus.error => Icons.error_outline,
            },
            size: 14,
            color: status == ChatMessageStatus.seen ? theme.colors.seen : color,
            semanticLabel: status!.name,
          ),
        ],
      ],
    );
  }
}
