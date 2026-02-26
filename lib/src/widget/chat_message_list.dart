import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:spindle_chat/src/model/chat_controller.dart';
import 'package:spindle_chat/src/model/chat_message.dart';
import 'package:spindle_chat/src/model/chat_operation.dart';
import 'package:spindle_chat/src/model/message_group_status.dart';
import 'package:spindle_chat/src/widget/chat_message_bubble.dart';
import 'package:spindle_chat/src/widget/chat_scope.dart';

/// {@template chat_message_list}
/// Scrollable list of chat messages with:
/// - Animated insertions / removals via [ChatOperation] stream
/// - Date separators between message groups
/// - Auto scroll-to-bottom on new messages
/// - Pull-to-load-more pagination
/// - Scroll-to-bottom FAB when scrolled away
/// {@endtemplate}
class ChatMessageList extends StatefulWidget {
  /// {@macro chat_message_list}
  const ChatMessageList({super.key});

  @override
  State<ChatMessageList> createState() => _ChatMessageListState();
}

class _ChatMessageListState extends State<ChatMessageList> {
  final ScrollController _scrollController = ScrollController();
  GlobalKey<SliverAnimatedListState> _listKey = GlobalKey<SliverAnimatedListState>();

  late List<ChatMessage> _messages;
  ChatController? _currentController;
  StreamSubscription<ChatOperation>? _operationsSub;
  bool _showScrollToBottom = false;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _messages = const [];
    _scrollController.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scope = ChatScope.of(context);
    final controller = scope.controller;

    // Only re-subscribe when the controller instance changes.
    if (identical(_currentController, controller)) {
      // Controller unchanged — just sync messages.
      _messages = List<ChatMessage>.of(controller.messages);
      return;
    }

    _currentController = controller;
    _operationsSub?.cancel();
    _messages = List<ChatMessage>.of(controller.messages);

    // Re-key the animated list so it fully rebuilds with correct item count.
    _listKey = GlobalKey<SliverAnimatedListState>();

    _operationsSub = controller.operationsStream.listen(_onOperation);
  }

  @override
  void dispose() {
    _operationsSub?.cancel();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Scroll handling
  // ---------------------------------------------------------------------------

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final showButton = _scrollController.offset > 200;
    if (showButton != _showScrollToBottom) {
      setState(() => _showScrollToBottom = showButton);
    }

    // Load more when near the end of content (top of reverse list).
    if (!_isLoadingMore && _scrollController.position.extentAfter < 100) {
      final scope = ChatScope.maybeOf(context);
      if (scope?.onLoadMore case final onLoadMore?) {
        _isLoadingMore = true;
        onLoadMore().whenComplete(() {
          if (mounted) setState(() => _isLoadingMore = false);
        });
      }
    }
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  // ---------------------------------------------------------------------------
  // Operation handling
  // ---------------------------------------------------------------------------

  void _onOperation(ChatOperation operation) {
    if (!mounted) return;

    switch (operation) {
      case ChatOperationInsert(:final message, :final index):
        _messages.insert(index, message);
        _listKey.currentState?.insertItem(index, duration: const Duration(milliseconds: 250));
        // Auto-scroll when a new message arrives and user is near bottom.
        if (index == 0 && _scrollController.hasClients) {
          if (_scrollController.offset < 100) {
            Future.delayed(const Duration(milliseconds: 50), _scrollToBottom);
          }
        }

      case ChatOperationRemove(:final message, :final index):
        if (index >= 0 && index < _messages.length) {
          _messages.removeAt(index);
          _listKey.currentState?.removeItem(
            index,
            (context, animation) => _buildAnimatedItem(message, animation),
            duration: const Duration(milliseconds: 200),
          );
        }

      case ChatOperationUpdate(:final newMessage, :final index):
        if (index >= 0 && index < _messages.length) {
          _messages[index] = newMessage;
          if (mounted) setState(() {});
        }

      case ChatOperationSet(:final messages):
        // Full replacement — re-key the animated list.
        setState(() {
          _messages = List<ChatMessage>.of(messages);
          _listKey = GlobalKey<SliverAnimatedListState>();
        });
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final scope = ChatScope.of(context);

    if (_messages.isEmpty) {
      return scope.builders.emptyStateBuilder?.call() ?? _DefaultEmptyState(text: scope.l10n.emptyStateText);
    }

    return Stack(
      children: [
        CustomScrollView(
          controller: _scrollController,
          reverse: true,
          slivers: [
            SliverAnimatedList(
              key: _listKey,
              initialItemCount: _messages.length,
              itemBuilder: (context, index, animation) {
                if (index >= _messages.length) return const SizedBox.shrink();
                return _buildAnimatedItem(_messages[index], animation, index: index);
              },
            ),
            if (_isLoadingMore)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                ),
              ),
          ],
        ),
        if (_showScrollToBottom)
          Positioned(
            bottom: 8,
            right: 16,
            child:
                scope.builders.scrollToBottomBuilder?.call(_scrollToBottom) ??
                _DefaultScrollToBottomButton(onTap: _scrollToBottom),
          ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Item builders
  // ---------------------------------------------------------------------------

  Widget _buildAnimatedItem(ChatMessage message, Animation<double> animation, {int? index}) {
    final resolvedIndex = index ?? _messages.indexOf(message);
    final groupStatus = _resolveGroupStatus(resolvedIndex);
    final showDate = _shouldShowDateSeparator(resolvedIndex);

    final bubble = ChatMessageBubble(message: message, groupStatus: groupStatus);

    return SizeTransition(
      sizeFactor: CurvedAnimation(parent: animation, curve: Curves.easeOut),
      child: FadeTransition(
        opacity: animation,
        child: Column(children: [if (showDate) _DateSeparator(date: message.createdAt), bubble]),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Grouping
  // ---------------------------------------------------------------------------

  MessageGroupStatus _resolveGroupStatus(int index) {
    if (index < 0 || index >= _messages.length) {
      return const MessageGroupStatus.single();
    }

    final message = _messages[index];
    final newerMessage = index > 0 ? _messages[index - 1] : null;
    final olderMessage = index < _messages.length - 1 ? _messages[index + 1] : null;

    const groupThreshold = Duration(minutes: 2);

    final groupedWithNewer =
        newerMessage != null &&
        newerMessage.authorId == message.authorId &&
        message.createdAt.difference(newerMessage.createdAt).abs() < groupThreshold;

    final groupedWithOlder =
        olderMessage != null &&
        olderMessage.authorId == message.authorId &&
        olderMessage.createdAt.difference(message.createdAt).abs() < groupThreshold;

    return switch ((groupedWithOlder, groupedWithNewer)) {
      (false, false) => const MessageGroupStatus.single(),
      (true, false) => const MessageGroupStatus.first(),
      (true, true) => const MessageGroupStatus.middle(),
      (false, true) => const MessageGroupStatus.last(),
    };
  }

  bool _shouldShowDateSeparator(int index) {
    if (index < 0 || index >= _messages.length) return false;
    if (index == _messages.length - 1) return true;
    final current = _messages[index].createdAt;
    final older = _messages[index + 1].createdAt;
    return current.year != older.year || current.month != older.month || current.day != older.day;
  }
}

// =============================================================================
// Date separator
// =============================================================================

class _DateSeparator extends StatelessWidget {
  const _DateSeparator({required this.date});

  final DateTime date;

  static final DateFormat _dateFormat = DateFormat.yMMMd();

  @override
  Widget build(BuildContext context) {
    final scope = ChatScope.of(context);
    final theme = scope.theme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      child: Row(
        children: [
          Expanded(child: Divider(color: theme.colors.divider, height: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              _formatDate(date, scope.l10n),
              style: theme.typography.labelSmall.copyWith(color: theme.colors.timestamp),
            ),
          ),
          Expanded(child: Divider(color: theme.colors.divider, height: 1)),
        ],
      ),
    );
  }

  static String _formatDate(DateTime date, ChatL10n l10n) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDay = DateTime(date.year, date.month, date.day);
    final difference = today.difference(messageDay).inDays;

    if (difference == 0) return l10n.today;
    if (difference == 1) return l10n.yesterday;
    return _dateFormat.format(date);
  }
}

// =============================================================================
// Default empty state
// =============================================================================

class _DefaultEmptyState extends StatelessWidget {
  const _DefaultEmptyState({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = ChatScope.of(context).theme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.chat_bubble_outline, size: 48, color: theme.colors.timestamp),
          const SizedBox(height: 12),
          Text(text, style: theme.typography.bodyMedium.copyWith(color: theme.colors.timestamp)),
        ],
      ),
    );
  }
}

// =============================================================================
// Default scroll-to-bottom button
// =============================================================================

class _DefaultScrollToBottomButton extends StatelessWidget {
  const _DefaultScrollToBottomButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = ChatScope.of(context).theme;
    return Semantics(
      label: 'Scroll to bottom',
      button: true,
      child: Material(
        elevation: 4,
        shape: const CircleBorder(),
        color: theme.colors.surface,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(Icons.keyboard_arrow_down, color: theme.colors.onSurface, size: 24),
          ),
        ),
      ),
    );
  }
}
