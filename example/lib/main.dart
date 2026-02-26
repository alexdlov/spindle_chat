import 'dart:async';

import 'package:flutter/material.dart';

import 'package:spindle_chat_example/pages/basic_chat_page.dart';
import 'package:spindle_chat_example/pages/custom_builders_page.dart';
import 'package:spindle_chat_example/pages/message_types_page.dart';
import 'package:spindle_chat_example/pages/themed_chat_page.dart';
import 'package:flutter/services.dart';

void main() => runZonedGuarded(
  () async {
    WidgetsFlutterBinding.ensureInitialized();
    // Set the app to be full-screen (no buttons, bar or notifications on top).
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    runApp(const SpindleChatExampleApp());
  },
  (error, stack) {
    // Catch any uncaught errors in the app.
    debugPrint('Uncaught error: $error');
    debugPrintStack(stackTrace: stack);
  },
);

/// Root of the example app for the `spindle_chat` package.
///
/// Demonstrates all major features:
/// - Basic two-user chat with auto-replies
/// - All message types (text, image, file, system, custom)
/// - Light / Dark / Custom theming
/// - Custom widget builders
class SpindleChatExampleApp extends StatelessWidget {
  const SpindleChatExampleApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Spindle Chat — Example',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorSchemeSeed: Colors.indigo,
      brightness: Brightness.light,
      useMaterial3: true,
    ),
    darkTheme: ThemeData(
      colorSchemeSeed: Colors.indigo,
      brightness: Brightness.dark,
      useMaterial3: true,
    ),
    home: const HomePage(),
  );
}

// =============================================================================
// Home — Gallery of demos
// =============================================================================

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final demos = <_DemoEntry>[
      _DemoEntry(
        icon: Icons.chat_bubble_outline,
        title: 'Basic Chat',
        subtitle: 'Two-user conversation with auto-replies & delivery status',
        color: Colors.indigo,
        builder: (_) => const BasicChatPage(),
      ),
      _DemoEntry(
        icon: Icons.category_outlined,
        title: 'Message Types',
        subtitle: 'Text, image, file, system & custom messages',
        color: Colors.teal,
        builder: (_) => const MessageTypesPage(),
      ),
      _DemoEntry(
        icon: Icons.palette_outlined,
        title: 'Theming',
        subtitle: 'Light, dark & custom color themes',
        color: Colors.deepOrange,
        builder: (_) => const ThemedChatPage(),
      ),
      _DemoEntry(
        icon: Icons.widgets_outlined,
        title: 'Custom Builders',
        subtitle: 'Override bubbles, avatars, composer & more',
        color: Colors.purple,
        builder: (_) => const CustomBuildersPage(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('spindle_chat'), centerTitle: true),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        itemCount: demos.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final demo = demos[index];
          return _DemoCard(demo: demo);
        },
      ),
    );
  }
}

// =============================================================================
// Models & widgets for the home page
// =============================================================================

class _DemoEntry {
  const _DemoEntry({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.builder,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final WidgetBuilder builder;
}

class _DemoCard extends StatelessWidget {
  const _DemoCard({required this.demo});

  final _DemoEntry demo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap:
            () => Navigator.of(
              context,
            ).push(MaterialPageRoute<void>(builder: demo.builder)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: demo.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(demo.icon, color: demo.color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(demo.title, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      demo.subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
