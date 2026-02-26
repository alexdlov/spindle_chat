import 'package:flutter/widgets.dart';

import 'package:spindle_chat/src/model/chat_author.dart';
import 'package:spindle_chat/src/model/chat_controller.dart';
import 'package:spindle_chat/src/model/chat_message.dart';
import 'package:spindle_chat/src/theme/chat_theme.dart';

/// Callback for resolving an author by their id.
typedef ResolveAuthorCallback = ChatAuthor? Function(AuthorId authorId);

/// Callback invoked when the user sends a text message.
typedef OnSendCallback = void Function(String text);

/// Callback invoked when the user taps on a message.
typedef OnMessageTapCallback = void Function(ChatMessage message);

/// Callback invoked when the user long-presses a message.
typedef OnMessageLongPressCallback = void Function(ChatMessage message);

/// Callback for loading earlier messages (pagination).
typedef OnLoadMoreCallback = Future<void> Function();

/// Callback invoked when the user taps the attachment button.
typedef OnAttachmentTapCallback = void Function();

/// {@template chat_l10n}
/// Localization strings for the chat UI.
///
/// Override to provide custom or translated strings.
/// {@endtemplate}
@immutable
class ChatL10n {
  /// {@macro chat_l10n}
  const ChatL10n({
    this.inputHint = 'Message',
    this.emptyStateText = 'No messages yet',
    this.today = 'Today',
    this.yesterday = 'Yesterday',
  });

  /// Placeholder text in the input field.
  final String inputHint;

  /// Text shown when the message list is empty.
  final String emptyStateText;

  /// Label for today's date separator.
  final String today;

  /// Label for yesterday's date separator.
  final String yesterday;
}

/// {@template chat_builders}
/// Collection of optional builder overrides for chat widgets.
///
/// Any builder set to `null` uses the default implementation.
/// {@endtemplate}
@immutable
class ChatBuilders {
  /// {@macro chat_builders}
  const ChatBuilders({
    this.textMessageBuilder,
    this.imageMessageBuilder,
    this.fileMessageBuilder,
    this.systemMessageBuilder,
    this.customMessageBuilder,
    this.composerBuilder,
    this.messageWrapperBuilder,
    this.avatarBuilder,
    this.usernameBuilder,
    this.timestampBuilder,
    this.scrollToBottomBuilder,
    this.emptyStateBuilder,
    this.loadingBuilder,
  });

  /// Override the default text message widget.
  final Widget Function(TextMessage message, {bool isMine})? textMessageBuilder;

  /// Override the default image message widget.
  final Widget Function(ImageMessage message, {bool isMine})? imageMessageBuilder;

  /// Override the default file message widget.
  final Widget Function(FileMessage message, {bool isMine})? fileMessageBuilder;

  /// Override the default system message widget.
  final Widget Function(SystemMessage message)? systemMessageBuilder;

  /// Override the default custom message widget.
  final Widget Function(CustomMessage message, {bool isMine})? customMessageBuilder;

  /// Override the default message composer (input bar).
  final Widget Function(OnSendCallback onSend)? composerBuilder;

  /// Wrap each message in a custom container.
  final Widget Function(ChatMessage message, {required Widget child, bool isMine})? messageWrapperBuilder;

  /// Override the default avatar widget.
  final Widget Function(ChatAuthor author)? avatarBuilder;

  /// Override the default username widget.
  final Widget Function(ChatAuthor author)? usernameBuilder;

  /// Override the default timestamp widget.
  final Widget Function(DateTime time)? timestampBuilder;

  /// Override the scroll-to-bottom button.
  final Widget Function(VoidCallback onTap)? scrollToBottomBuilder;

  /// Widget shown when the message list is empty.
  final Widget Function()? emptyStateBuilder;

  /// Widget shown during initial loading.
  final Widget Function()? loadingBuilder;
}

/// {@template chat_scope}
/// InheritedWidget that provides chat configuration down the widget tree.
///
/// Provides access to [ChatController], [ChatTheme], [ChatBuilders],
/// current user id, author resolution, and callbacks.
/// {@endtemplate}
class ChatScope extends InheritedWidget {
  /// {@macro chat_scope}
  const ChatScope({
    required this.controller,
    required this.currentUserId,
    required this.theme,
    required super.child,
    this.resolveAuthor,
    this.builders = const ChatBuilders(),
    this.l10n = const ChatL10n(),
    this.onSend,
    this.onAttachmentTap,
    this.onMessageTap,
    this.onMessageLongPress,
    this.onLoadMore,
    super.key,
  });

  /// The chat controller managing messages.
  final ChatController controller;

  /// The id of the current user (to distinguish "my" vs "their" messages).
  final AuthorId currentUserId;

  /// Theme for the chat UI.
  final ChatTheme theme;

  /// Optional author resolver.
  final ResolveAuthorCallback? resolveAuthor;

  /// Widget builders for customization.
  final ChatBuilders builders;

  /// Localization strings.
  final ChatL10n l10n;

  /// Called when the user sends a message.
  final OnSendCallback? onSend;

  /// Called when the user taps the attachment button.
  final OnAttachmentTapCallback? onAttachmentTap;

  /// Called when a message is tapped.
  final OnMessageTapCallback? onMessageTap;

  /// Called when a message is long-pressed.
  final OnMessageLongPressCallback? onMessageLongPress;

  /// Called when the user scrolls to the top to load more.
  final OnLoadMoreCallback? onLoadMore;

  /// Obtain the nearest [ChatScope] from the given context.
  static ChatScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ChatScope>();
    assert(
      scope != null,
      'No ChatScope found in the widget tree. '
      'Wrap your chat widgets with ChatView or ChatScope.',
    );
    return scope!;
  }

  /// Try to obtain the nearest [ChatScope], returns null if not found.
  static ChatScope? maybeOf(BuildContext context) => context.dependOnInheritedWidgetOfExactType<ChatScope>();

  @override
  bool updateShouldNotify(covariant ChatScope oldWidget) =>
      controller != oldWidget.controller || currentUserId != oldWidget.currentUserId || theme != oldWidget.theme;
}
