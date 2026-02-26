import 'dart:math';

import 'package:flutter/material.dart';
import 'package:spindle_chat/spindle_chat.dart';

/// Demonstrates theming capabilities of spindle_chat.
///
/// Toggle between:
/// - `ChatTheme.light()` — built-in light palette
/// - `ChatTheme.dark()` — built-in dark palette
/// - `ChatTheme.fromThemeData()` — derived from the app's Material theme
/// - Custom theme — fully hand-crafted colors
class ThemedChatPage extends StatefulWidget {
  const ThemedChatPage({super.key});

  @override
  State<ThemedChatPage> createState() => _ThemedChatPageState();
}

enum _ThemeVariant { light, dark, material, custom }

class _ThemedChatPageState extends State<ThemedChatPage> {
  static const _currentUserId = 'user-1';
  static const _otherUserId = 'user-2';

  final _controller = InMemoryChatController();
  _ThemeVariant _variant = _ThemeVariant.light;
  int _counter = 100;

  final _authors = <String, ChatAuthor>{
    'user-1': const ChatAuthor(id: 'user-1', displayName: 'You'),
    'user-2': const ChatAuthor(id: 'user-2', displayName: 'Eve', avatarUrl: 'https://i.pravatar.cc/150?u=eve'),
  };

  @override
  void initState() {
    super.initState();
    _seed();
  }

  void _seed() {
    final now = DateTime.now();
    _controller.setMessages([
      TextMessage(
        id: 't-1',
        authorId: _otherUserId,
        createdAt: now.subtract(const Duration(minutes: 6)),
        text: 'Try switching themes with the palette button ↗',
      ),
      TextMessage(
        id: 't-2',
        authorId: _currentUserId,
        createdAt: now.subtract(const Duration(minutes: 5)),
        text: 'Light theme looks clean!',
        status: ChatMessageStatus.seen,
      ),
      TextMessage(
        id: 't-3',
        authorId: _otherUserId,
        createdAt: now.subtract(const Duration(minutes: 4)),
        text: 'Dark mode is great for OLED screens. 🌙',
      ),
      TextMessage(
        id: 't-4',
        authorId: _currentUserId,
        createdAt: now.subtract(const Duration(minutes: 3)),
        text: 'And the Material theme auto-matches my app colors!',
        status: ChatMessageStatus.delivered,
      ),
      TextMessage(
        id: 't-5',
        authorId: _otherUserId,
        createdAt: now.subtract(const Duration(minutes: 2)),
        text:
            'You can also go fully custom. '
            'Try the "Custom" option — it uses a green accent.',
      ),
      ImageMessage(
        id: 'img-t',
        authorId: _otherUserId,
        createdAt: now.subtract(const Duration(minutes: 1)),
        imageUrl: 'https://picsum.photos/seed/theme/400/250',
        caption: 'Colors adapt to the theme!',
      ),
    ]);
  }

  ChatTheme _resolveTheme(BuildContext context) => switch (_variant) {
    _ThemeVariant.light => ChatTheme.light(),
    _ThemeVariant.dark => ChatTheme.dark(),
    _ThemeVariant.material => ChatTheme.fromThemeData(Theme.of(context)),
    _ThemeVariant.custom => ChatTheme(
      colors: const ChatColors(
        sentBubble: Color(0xFF2E7D32),
        sentText: Color(0xFFFFFFFF),
        receivedBubble: Color(0xFFE8F5E9),
        receivedText: Color(0xFF1B5E20),
        surface: Color(0xFFFAFAFA),
        onSurface: Color(0xFF212121),
        inputBackground: Color(0xFFE8F5E9),
        inputText: Color(0xFF212121),
        timestamp: Color(0xFF757575),
        system: Color(0xFF9E9E9E),
        divider: Color(0xFFC8E6C9),
        seen: Color(0xFF2E7D32),
      ),
      typography: ChatTypography.standard(),
    ),
  };

  void _handleSend(String text) {
    final msg = TextMessage(
      id: 'msg-${++_counter}',
      authorId: _currentUserId,
      createdAt: DateTime.now(),
      text: text,
      status: ChatMessageStatus.sent,
    );
    _controller.insertMessage(msg);

    // Auto-reply
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      _controller.insertMessage(
        TextMessage(
          id: 'reply-${Random().nextInt(999999)}',
          authorId: _otherUserId,
          createdAt: DateTime.now(),
          text: _themeReply(),
        ),
      );
    });
  }

  String _themeReply() {
    final replies = switch (_variant) {
      _ThemeVariant.light => ['Light theme looks so fresh!', 'Clean and minimal. 👌'],
      _ThemeVariant.dark => ['Dark mode is easier on the eyes.', 'Perfect for late night coding. 🌙'],
      _ThemeVariant.material => ['Material theming ties everything together.', 'Consistent with the rest of the app!'],
      _ThemeVariant.custom => ['Green vibes! 🌿', 'Custom colors look unique.'],
    };
    return replies[Random().nextInt(replies.length)];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatTheme = _resolveTheme(context);

    return Theme(
      data:
          _variant == _ThemeVariant.dark
              ? ThemeData(colorSchemeSeed: Colors.indigo, brightness: Brightness.dark, useMaterial3: true)
              : Theme.of(context),
      child: Scaffold(
        appBar: AppBar(
          title: Text(_variantLabel),
          actions: [
            PopupMenuButton<_ThemeVariant>(
              icon: const Icon(Icons.palette_outlined),
              onSelected: (v) => setState(() => _variant = v),
              itemBuilder:
                  (_) => [
                    _themeMenuItem(_ThemeVariant.light, 'Light', Icons.light_mode),
                    _themeMenuItem(_ThemeVariant.dark, 'Dark', Icons.dark_mode),
                    _themeMenuItem(_ThemeVariant.material, 'Material', Icons.auto_awesome),
                    _themeMenuItem(_ThemeVariant.custom, 'Custom (Green)', Icons.color_lens),
                  ],
            ),
          ],
        ),
        body: ChatView(
          controller: _controller,
          currentUserId: _currentUserId,
          theme: chatTheme,
          resolveAuthor: (id) => _authors[id],
          onSend: _handleSend,
        ),
      ),
    );
  }

  String get _variantLabel => switch (_variant) {
    _ThemeVariant.light => 'Light Theme',
    _ThemeVariant.dark => 'Dark Theme',
    _ThemeVariant.material => 'Material Theme',
    _ThemeVariant.custom => 'Custom Theme',
  };

  PopupMenuItem<_ThemeVariant> _themeMenuItem(_ThemeVariant value, String label, IconData icon) => PopupMenuItem(
    value: value,
    child: Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 12),
        Text(label),
        if (value == _variant) ...[const Spacer(), const Icon(Icons.check, size: 18)],
      ],
    ),
  );
}
