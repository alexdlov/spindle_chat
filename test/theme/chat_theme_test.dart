import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spindle_chat/spindle_chat.dart';

void main() {
  group('ChatColors', () {
    test('light factory creates consistent palette', () {
      final colors = ChatColors.light();
      expect(colors.sentBubble, isNotNull);
      expect(colors.sentText, isNotNull);
      expect(colors.receivedBubble, isNotNull);
      expect(colors.surface, const Color(0xFFFFFFFF));
    });

    test('dark factory creates consistent palette', () {
      final colors = ChatColors.dark();
      expect(colors.surface, const Color(0xFF121212));
    });

    test('copyWith replaces only specified fields', () {
      final colors = ChatColors.light();
      final copy = colors.copyWith(sentBubble: Colors.red);
      expect(copy.sentBubble, Colors.red);
      expect(copy.sentText, colors.sentText);
      expect(copy.surface, colors.surface);
    });

    test('equality works', () {
      final a = ChatColors.light();
      final b = ChatColors.light();
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('inequality when fields differ', () {
      final a = ChatColors.light();
      final b = a.copyWith(sentBubble: Colors.red);
      expect(a, isNot(equals(b)));
    });
  });

  group('ChatTypography', () {
    test('standard factory creates all styles', () {
      final typography = ChatTypography.standard();
      expect(typography.bodyLarge.fontSize, 16);
      expect(typography.bodyMedium.fontSize, 14);
      expect(typography.bodySmall.fontSize, 12);
      expect(typography.labelSmall.fontSize, 10);
    });

    test('equality works', () {
      final a = ChatTypography.standard();
      final b = ChatTypography.standard();
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });
  });

  group('ChatTheme', () {
    test('light factory creates theme', () {
      final theme = ChatTheme.light();
      expect(theme.colors, equals(ChatColors.light()));
      expect(theme.typography, equals(ChatTypography.standard()));
      expect(theme.inputDecoration, isNull);
    });

    test('dark factory creates theme', () {
      final theme = ChatTheme.dark();
      expect(theme.colors, equals(ChatColors.dark()));
    });

    test('fromThemeData derives from Material ThemeData', () {
      final themeData = ThemeData.light(useMaterial3: true);
      final theme = ChatTheme.fromThemeData(themeData);
      expect(theme.colors.sentBubble, themeData.colorScheme.primary);
      expect(theme.colors.sentText, themeData.colorScheme.onPrimary);
      expect(theme.colors.surface, themeData.colorScheme.surface);
    });

    test('copyWith replaces colors', () {
      final theme = ChatTheme.light();
      final newColors = ChatColors.dark();
      final copy = theme.copyWith(colors: newColors);
      expect(copy.colors, equals(newColors));
      expect(copy.typography, equals(theme.typography));
    });

    test('copyWith replaces inputDecoration', () {
      final theme = ChatTheme.light();
      const decoration = InputDecoration(hintText: 'Custom');
      final copy = theme.copyWith(inputDecoration: decoration);
      expect(copy.inputDecoration, decoration);
    });

    test('equality works', () {
      final a = ChatTheme.light();
      final b = ChatTheme.light();
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('inequality when colors differ', () {
      final a = ChatTheme.light();
      final b = ChatTheme.dark();
      expect(a, isNot(equals(b)));
    });
  });

  group('ChatL10n', () {
    test('has sensible defaults', () {
      const l10n = ChatL10n();
      expect(l10n.inputHint, 'Message');
      expect(l10n.emptyStateText, 'No messages yet');
      expect(l10n.today, 'Today');
      expect(l10n.yesterday, 'Yesterday');
    });

    test('accepts custom strings', () {
      const l10n = ChatL10n(
        inputHint: 'Сообщение',
        emptyStateText: 'Пока нет сообщений',
        today: 'Сегодня',
        yesterday: 'Вчера',
      );
      expect(l10n.inputHint, 'Сообщение');
      expect(l10n.emptyStateText, 'Пока нет сообщений');
    });
  });
}
