import 'package:flutter/material.dart';

/// {@template chat_theme}
/// Theme data for the chat UI.
///
/// Provides [colors], [typography], and shape customization.
/// Can be derived from the app's [ThemeData] via [ChatTheme.fromThemeData].
/// {@endtemplate}
@immutable
class ChatTheme {
  /// {@macro chat_theme}
  const ChatTheme({
    required this.colors,
    required this.typography,
    this.inputDecoration,
  });

  /// Construct a light chat theme.
  factory ChatTheme.light() => ChatTheme(
    colors: ChatColors.light(),
    typography: ChatTypography.standard(),
  );

  /// Construct a dark chat theme.
  factory ChatTheme.dark() => ChatTheme(
    colors: ChatColors.dark(),
    typography: ChatTypography.standard(),
  );

  /// Derive from an existing [ThemeData].
  factory ChatTheme.fromThemeData(ThemeData themeData) {
    final cs = themeData.colorScheme;
    return ChatTheme(
      colors: ChatColors(
        sentBubble: cs.primary,
        sentText: cs.onPrimary,
        receivedBubble: cs.surfaceContainerHighest,
        receivedText: cs.onSurface,
        surface: cs.surface,
        onSurface: cs.onSurface,
        inputBackground: cs.surfaceContainerLow,
        inputText: cs.onSurface,
        timestamp: cs.onSurface.withValues(alpha: 0.5),
        system: cs.onSurface.withValues(alpha: 0.5),
        divider: cs.outlineVariant,
        seen: cs.primary,
      ),
      typography: ChatTypography(
        bodyLarge:
            themeData.textTheme.bodyLarge ?? const TextStyle(fontSize: 16),
        bodyMedium:
            themeData.textTheme.bodyMedium ?? const TextStyle(fontSize: 14),
        bodySmall:
            themeData.textTheme.bodySmall ?? const TextStyle(fontSize: 12),
        labelSmall:
            themeData.textTheme.labelSmall ?? const TextStyle(fontSize: 10),
      ),
    );
  }

  /// Color palette for chat elements.
  final ChatColors colors;

  /// Text styles used throughout the chat.
  final ChatTypography typography;

  /// Optional custom decoration for the text input.
  final InputDecoration? inputDecoration;

  /// Create a copy with the given overrides.
  ChatTheme copyWith({
    ChatColors? colors,
    ChatTypography? typography,
    InputDecoration? inputDecoration,
  }) => ChatTheme(
    colors: colors ?? this.colors,
    typography: typography ?? this.typography,
    inputDecoration: inputDecoration ?? this.inputDecoration,
  );

  @override
  int get hashCode => Object.hash(colors, typography);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatTheme &&
          colors == other.colors &&
          typography == other.typography);
}

/// {@template chat_colors}
/// Color palette for the chat UI.
/// {@endtemplate}
@immutable
class ChatColors {
  /// {@macro chat_colors}
  const ChatColors({
    required this.sentBubble,
    required this.sentText,
    required this.receivedBubble,
    required this.receivedText,
    required this.surface,
    required this.onSurface,
    required this.inputBackground,
    required this.inputText,
    required this.timestamp,
    required this.system,
    required this.divider,
    required this.seen,
  });

  /// Light color scheme.
  factory ChatColors.light() => const ChatColors(
    sentBubble: Color(0xFF1976D2),
    sentText: Color(0xFFFFFFFF),
    receivedBubble: Color(0xFFF0F0F0),
    receivedText: Color(0xFF1C1B1F),
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF1C1B1F),
    inputBackground: Color(0xFFF5F5F5),
    inputText: Color(0xFF1C1B1F),
    timestamp: Color(0xFF9E9E9E),
    system: Color(0xFF9E9E9E),
    divider: Color(0xFFE0E0E0),
    seen: Color(0xFF1976D2),
  );

  /// Dark color scheme.
  factory ChatColors.dark() => const ChatColors(
    sentBubble: Color(0xFF1565C0),
    sentText: Color(0xFFFFFFFF),
    receivedBubble: Color(0xFF2C2C2C),
    receivedText: Color(0xFFE0E0E0),
    surface: Color(0xFF121212),
    onSurface: Color(0xFFE0E0E0),
    inputBackground: Color(0xFF1E1E1E),
    inputText: Color(0xFFE0E0E0),
    timestamp: Color(0xFF757575),
    system: Color(0xFF757575),
    divider: Color(0xFF424242),
    seen: Color(0xFF64B5F6),
  );

  final Color sentBubble;
  final Color sentText;
  final Color receivedBubble;
  final Color receivedText;
  final Color surface;
  final Color onSurface;
  final Color inputBackground;
  final Color inputText;
  final Color timestamp;
  final Color system;
  final Color divider;
  final Color seen;

  /// Create a copy with the given overrides.
  ChatColors copyWith({
    Color? sentBubble,
    Color? sentText,
    Color? receivedBubble,
    Color? receivedText,
    Color? surface,
    Color? onSurface,
    Color? inputBackground,
    Color? inputText,
    Color? timestamp,
    Color? system,
    Color? divider,
    Color? seen,
  }) => ChatColors(
    sentBubble: sentBubble ?? this.sentBubble,
    sentText: sentText ?? this.sentText,
    receivedBubble: receivedBubble ?? this.receivedBubble,
    receivedText: receivedText ?? this.receivedText,
    surface: surface ?? this.surface,
    onSurface: onSurface ?? this.onSurface,
    inputBackground: inputBackground ?? this.inputBackground,
    inputText: inputText ?? this.inputText,
    timestamp: timestamp ?? this.timestamp,
    system: system ?? this.system,
    divider: divider ?? this.divider,
    seen: seen ?? this.seen,
  );

  @override
  int get hashCode => Object.hash(
    sentBubble,
    sentText,
    receivedBubble,
    receivedText,
    surface,
    onSurface,
    inputBackground,
    inputText,
    timestamp,
    system,
    divider,
    seen,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatColors &&
          sentBubble == other.sentBubble &&
          sentText == other.sentText &&
          receivedBubble == other.receivedBubble &&
          receivedText == other.receivedText &&
          surface == other.surface &&
          onSurface == other.onSurface &&
          inputBackground == other.inputBackground &&
          inputText == other.inputText &&
          timestamp == other.timestamp &&
          system == other.system &&
          divider == other.divider &&
          seen == other.seen);
}

/// {@template chat_typography}
/// Text styles for the chat UI.
/// {@endtemplate}
@immutable
class ChatTypography {
  /// {@macro chat_typography}
  const ChatTypography({
    required this.bodyLarge,
    required this.bodyMedium,
    required this.bodySmall,
    required this.labelSmall,
  });

  /// Standard typography.
  factory ChatTypography.standard() => const ChatTypography(
    bodyLarge: TextStyle(fontSize: 16, height: 1.4),
    bodyMedium: TextStyle(fontSize: 14, height: 1.4),
    bodySmall: TextStyle(fontSize: 12, height: 1.3),
    labelSmall: TextStyle(fontSize: 10, height: 1.2),
  );

  /// Primary text style (message body).
  final TextStyle bodyLarge;

  /// Secondary text style (sender name).
  final TextStyle bodyMedium;

  /// Small text style (timestamp, status).
  final TextStyle bodySmall;

  /// Very small text style (labels).
  final TextStyle labelSmall;

  @override
  int get hashCode => Object.hash(bodyLarge, bodyMedium, bodySmall, labelSmall);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatTypography &&
          bodyLarge == other.bodyLarge &&
          bodyMedium == other.bodyMedium &&
          bodySmall == other.bodySmall &&
          labelSmall == other.labelSmall);
}
