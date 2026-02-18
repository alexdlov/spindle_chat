import 'package:flutter/material.dart';

import '../model/chat_controller.dart';
import '../model/chat_message.dart';
import '../theme/chat_theme.dart';
import 'chat_composer.dart';
import 'chat_message_list.dart';
import 'chat_scope.dart';

/// {@template chat_view}
/// The main chat widget composing the message list and the input bar.
///
/// This is the primary entry point for embedding a chat UI.
///
/// ```dart
/// ChatView(
///   controller: chatController,
///   currentUserId: 'user-123',
///   onSend: (text) => sendMessage(text),
/// )
/// ```
/// {@endtemplate}
class ChatView extends StatelessWidget {
  /// {@macro chat_view}
  const ChatView({
    required this.controller,
    required this.currentUserId,
    this.theme,
    this.resolveAuthor,
    this.builders = const ChatBuilders(),
    this.l10n = const ChatL10n(),
    this.onSend,
    this.onMessageTap,
    this.onMessageLongPress,
    this.onLoadMore,
    super.key,
  });

  /// The chat controller managing messages.
  final ChatController controller;

  /// The id of the current user.
  final AuthorId currentUserId;

  /// Optional theme override. Falls back to [ChatTheme.fromThemeData].
  final ChatTheme? theme;

  /// Resolve an author from their id.
  final ResolveAuthorCallback? resolveAuthor;

  /// Widget builder overrides.
  final ChatBuilders builders;

  /// Localization strings.
  final ChatL10n l10n;

  /// Called when the user sends a text message.
  final OnSendCallback? onSend;

  /// Called when a message is tapped.
  final OnMessageTapCallback? onMessageTap;

  /// Called when a message is long-pressed.
  final OnMessageLongPressCallback? onMessageLongPress;

  /// Called to load earlier messages.
  final OnLoadMoreCallback? onLoadMore;

  @override
  Widget build(BuildContext context) {
    final resolvedTheme = theme ?? ChatTheme.fromThemeData(Theme.of(context));

    return ChatScope(
      controller: controller,
      currentUserId: currentUserId,
      theme: resolvedTheme,
      resolveAuthor: resolveAuthor,
      builders: builders,
      l10n: l10n,
      onSend: onSend,
      onMessageTap: onMessageTap,
      onMessageLongPress: onMessageLongPress,
      onLoadMore: onLoadMore,
      child: ColoredBox(
        color: resolvedTheme.colors.surface,
        child: const Column(
          children: [Expanded(child: ChatMessageList()), ChatComposer()],
        ),
      ),
    );
  }
}
