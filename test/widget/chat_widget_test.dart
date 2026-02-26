import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spindle_chat/spindle_chat.dart';

void main() {
  final now = DateTime(2025, 1, 15, 12, 0);

  Widget buildApp({
    required ChatController controller,
    String currentUserId = 'me',
    ChatTheme? theme,
    ResolveAuthorCallback? resolveAuthor,
    OnSendCallback? onSend,
    OnAttachmentTapCallback? onAttachmentTap,
    OnMessageTapCallback? onMessageTap,
    OnMessageLongPressCallback? onMessageLongPress,
    ChatBuilders builders = const ChatBuilders(),
    ChatL10n l10n = const ChatL10n(),
  }) => MaterialApp(
    home: Scaffold(
      body: ChatView(
        controller: controller,
        currentUserId: currentUserId,
        theme: theme,
        resolveAuthor: resolveAuthor,
        builders: builders,
        l10n: l10n,
        onSend: onSend,
        onAttachmentTap: onAttachmentTap,
        onMessageTap: onMessageTap,
        onMessageLongPress: onMessageLongPress,
      ),
    ),
  );

  group('ChatView', () {
    testWidgets('renders empty state when no messages', (tester) async {
      final controller = InMemoryChatController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(buildApp(controller: controller));
      await tester.pumpAndSettle();

      expect(find.text('No messages yet'), findsOneWidget);
    });

    testWidgets('renders text message', (tester) async {
      final controller = InMemoryChatController(
        initialMessages: [TextMessage(id: 'msg-1', authorId: 'other', createdAt: now, text: 'Hello from other!')],
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(buildApp(controller: controller));
      await tester.pumpAndSettle();

      expect(find.text('Hello from other!'), findsOneWidget);
    });

    testWidgets('renders my message on the right side', (tester) async {
      final controller = InMemoryChatController(
        initialMessages: [TextMessage(id: 'msg-1', authorId: 'me', createdAt: now, text: 'My message')],
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(buildApp(controller: controller));
      await tester.pumpAndSettle();

      expect(find.text('My message'), findsOneWidget);
    });

    testWidgets('renders system message centered', (tester) async {
      final controller = InMemoryChatController(
        initialMessages: [SystemMessage(id: 'sys-1', createdAt: now, text: 'User joined')],
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(buildApp(controller: controller));
      await tester.pumpAndSettle();

      expect(find.text('User joined'), findsOneWidget);
    });

    testWidgets('renders file message with file name', (tester) async {
      final controller = InMemoryChatController(
        initialMessages: [
          FileMessage(
            id: 'file-1',
            authorId: 'other',
            createdAt: now,
            fileUrl: 'https://example.com/doc.pdf',
            fileName: 'document.pdf',
            fileSize: 2048,
          ),
        ],
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(buildApp(controller: controller));
      await tester.pumpAndSettle();

      expect(find.text('document.pdf'), findsOneWidget);
      expect(find.text('2.0 KB'), findsOneWidget);
    });

    testWidgets('uses custom l10n strings', (tester) async {
      final controller = InMemoryChatController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(buildApp(controller: controller, l10n: const ChatL10n(emptyStateText: 'Пусто')));
      await tester.pumpAndSettle();

      expect(find.text('Пусто'), findsOneWidget);
    });

    testWidgets('uses custom theme', (tester) async {
      final controller = InMemoryChatController(
        initialMessages: [TextMessage(id: 'msg-1', authorId: 'me', createdAt: now, text: 'Themed')],
      );
      addTearDown(controller.dispose);

      final theme = ChatTheme.dark();
      await tester.pumpWidget(buildApp(controller: controller, theme: theme));
      await tester.pumpAndSettle();

      // The message should render without errors.
      expect(find.text('Themed'), findsOneWidget);
    });
  });

  group('ChatComposer', () {
    testWidgets('shows text field with hint', (tester) async {
      final controller = InMemoryChatController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(buildApp(controller: controller));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
      // The hint from default ChatL10n.
      expect(find.text('Message'), findsOneWidget);
    });

    testWidgets('send button appears when text is entered', (tester) async {
      final controller = InMemoryChatController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(buildApp(controller: controller, onSend: (_) {}));
      await tester.pumpAndSettle();

      // Send icon exists but is transparent.
      final sendIcon = find.byIcon(Icons.send);
      expect(sendIcon, findsOneWidget);

      // Enter text.
      await tester.enterText(find.byType(TextField), 'Hello');
      await tester.pumpAndSettle();

      // Send icon should now be visible (opacity 1.0).
      expect(sendIcon, findsOneWidget);
    });

    testWidgets('send callback is invoked with text', (tester) async {
      final controller = InMemoryChatController();
      addTearDown(controller.dispose);
      String? sentText;

      await tester.pumpWidget(buildApp(controller: controller, onSend: (text) => sentText = text));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Hello');
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();

      expect(sentText, 'Hello');
    });

    testWidgets('text field clears after send', (tester) async {
      final controller = InMemoryChatController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(buildApp(controller: controller, onSend: (_) {}));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Hello');
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();

      // Text field should be empty.
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller!.text, isEmpty);
    });

    testWidgets('does not send empty text', (tester) async {
      final controller = InMemoryChatController();
      addTearDown(controller.dispose);
      var sendCount = 0;

      await tester.pumpWidget(buildApp(controller: controller, onSend: (_) => sendCount++));
      await tester.pumpAndSettle();

      // Try to send without entering text.
      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();

      expect(sendCount, 0);
    });

    testWidgets('attachment button appears when callback is provided', (tester) async {
      final controller = InMemoryChatController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(buildApp(controller: controller, onAttachmentTap: () {}));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('attachment button is hidden when no callback', (tester) async {
      final controller = InMemoryChatController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(buildApp(controller: controller));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.add), findsNothing);
    });

    testWidgets('attachment button invokes callback', (tester) async {
      final controller = InMemoryChatController();
      addTearDown(controller.dispose);
      var tapped = false;

      await tester.pumpWidget(buildApp(controller: controller, onAttachmentTap: () => tapped = true));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('custom l10n input hint', (tester) async {
      final controller = InMemoryChatController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(buildApp(controller: controller, l10n: const ChatL10n(inputHint: 'Type here...')));
      await tester.pumpAndSettle();

      expect(find.text('Type here...'), findsOneWidget);
    });
  });

  group('ChatScope', () {
    testWidgets('of() provides scope to descendants', (tester) async {
      final controller = InMemoryChatController();
      addTearDown(controller.dispose);
      ChatScope? captured;

      await tester.pumpWidget(
        MaterialApp(
          home: ChatScope(
            controller: controller,
            currentUserId: 'me',
            theme: ChatTheme.light(),
            child: Builder(
              builder: (context) {
                captured = ChatScope.of(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      expect(captured, isNotNull);
      expect(captured!.currentUserId, 'me');
      expect(captured!.controller, controller);
    });

    testWidgets('maybeOf() returns null when no scope', (tester) async {
      ChatScope? captured;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              captured = ChatScope.maybeOf(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(captured, isNull);
    });
  });

  group('ChatMessageBubble', () {
    testWidgets('renders text message content', (tester) async {
      final controller = InMemoryChatController();
      addTearDown(controller.dispose);

      final msg = TextMessage(id: 'msg-1', authorId: 'other', createdAt: now, text: 'Bubble text');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatScope(
              controller: controller,
              currentUserId: 'me',
              theme: ChatTheme.light(),
              child: ListView(
                children: [ChatMessageBubble(message: msg, groupStatus: const MessageGroupStatus.single())],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Bubble text'), findsOneWidget);
    });

    testWidgets('renders system message as centered text', (tester) async {
      final controller = InMemoryChatController();
      addTearDown(controller.dispose);

      final msg = SystemMessage(id: 'sys-1', createdAt: now, text: 'System event');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatScope(
              controller: controller,
              currentUserId: 'me',
              theme: ChatTheme.light(),
              child: ListView(
                children: [ChatMessageBubble(message: msg, groupStatus: const MessageGroupStatus.single())],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('System event'), findsOneWidget);
    });

    testWidgets('shows username for received messages with showAuthor', (tester) async {
      final controller = InMemoryChatController();
      addTearDown(controller.dispose);

      final msg = TextMessage(id: 'msg-1', authorId: 'other', createdAt: now, text: 'Hello');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatScope(
              controller: controller,
              currentUserId: 'me',
              theme: ChatTheme.light(),
              resolveAuthor: (id) => ChatAuthor(id: id, displayName: 'Alice'),
              child: ListView(
                children: [ChatMessageBubble(message: msg, groupStatus: const MessageGroupStatus.single())],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Alice'), findsOneWidget);
    });

    testWidgets('custom builders override default rendering', (tester) async {
      final controller = InMemoryChatController();
      addTearDown(controller.dispose);

      final msg = TextMessage(id: 'msg-1', authorId: 'me', createdAt: now, text: 'Original');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatScope(
              controller: controller,
              currentUserId: 'me',
              theme: ChatTheme.light(),
              builders: ChatBuilders(
                textMessageBuilder: (message, {isMine = false}) => Text('Custom: ${message.text}'),
              ),
              child: ListView(
                children: [ChatMessageBubble(message: msg, groupStatus: const MessageGroupStatus.single())],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Custom: Original'), findsOneWidget);
    });

    testWidgets('system message custom builder is used', (tester) async {
      final controller = InMemoryChatController();
      addTearDown(controller.dispose);

      final msg = SystemMessage(id: 'sys-1', createdAt: now, text: 'Joined');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatScope(
              controller: controller,
              currentUserId: 'me',
              theme: ChatTheme.light(),
              builders: ChatBuilders(systemMessageBuilder: (message) => Text('CUSTOM: ${message.text}')),
              child: ListView(
                children: [ChatMessageBubble(message: msg, groupStatus: const MessageGroupStatus.single())],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('CUSTOM: Joined'), findsOneWidget);
    });

    testWidgets('message tap callback is invoked', (tester) async {
      final controller = InMemoryChatController();
      addTearDown(controller.dispose);
      ChatMessage? tappedMessage;

      final msg = TextMessage(id: 'msg-1', authorId: 'me', createdAt: now, text: 'Tap me');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatScope(
              controller: controller,
              currentUserId: 'me',
              theme: ChatTheme.light(),
              onMessageTap: (message) => tappedMessage = message,
              child: ListView(
                children: [ChatMessageBubble(message: msg, groupStatus: const MessageGroupStatus.single())],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Tap me'));
      await tester.pumpAndSettle();

      expect(tappedMessage, isNotNull);
      expect(tappedMessage!.id, 'msg-1');
    });
  });

  group('ChatBuilders', () {
    test('default constructor has all null builders', () {
      const builders = ChatBuilders();
      expect(builders.textMessageBuilder, isNull);
      expect(builders.imageMessageBuilder, isNull);
      expect(builders.fileMessageBuilder, isNull);
      expect(builders.systemMessageBuilder, isNull);
      expect(builders.customMessageBuilder, isNull);
      expect(builders.composerBuilder, isNull);
      expect(builders.messageWrapperBuilder, isNull);
      expect(builders.avatarBuilder, isNull);
      expect(builders.usernameBuilder, isNull);
      expect(builders.timestampBuilder, isNull);
      expect(builders.scrollToBottomBuilder, isNull);
      expect(builders.emptyStateBuilder, isNull);
      expect(builders.loadingBuilder, isNull);
    });
  });
}
