# spindle_chat

Composable, themeable chat UI for Flutter.

[![Dart](https://img.shields.io/badge/Dart-3.7+-blue)](https://dart.dev)
[![Flutter](https://img.shields.io/badge/Flutter-3.29+-02569B)](https://flutter.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-green)](LICENSE)

---

## Features

- **Sealed message types** — `TextMessage`, `ImageMessage`, `FileMessage`, `SystemMessage`, `CustomMessage` with exhaustive `switch`.
- **Controller-driven** — `ChatController` interface + `InMemoryChatController` with animated list operations (insert, remove, update, set).
- **Theming** — `ChatTheme.light()`, `ChatTheme.dark()`, or `ChatTheme.fromThemeData(theme)` to match your app.
- **Custom builders** — Override any widget via `ChatBuilders` (message bubble, avatar, input, system message, date separator, empty state).
- **Localization** — `ChatL10n` for translatable strings (input hint, empty state, date labels).
- **Animated list** — `SliverAnimatedList` with fade/slide transitions, date separators, and a scroll-to-bottom button.
- **Accessibility** — `Semantics` on bubbles, buttons, and system messages.
- **Message groups** — Consecutive messages from the same author are grouped visually.
- **Delivery status** — `sent`, `delivered`, `seen`, `error` indicators on outgoing messages.
- **Edited indicator** — Shows "edited" label when `updatedAt != createdAt`.
- **Pagination** — `onLoadMore` callback for lazy loading.
- **No codegen, no heavy deps** — Only `meta` and `intl`.

---

## Installation

```yaml
dependencies:
  spindle_chat: ^0.1.0
```

```bash
flutter pub get
```

---

## Quick start

```dart
import 'package:spindle_chat/spindle_chat.dart';

// 1. Create a controller
final controller = InMemoryChatController();

// 2. Add the ChatView
ChatView(
  controller: controller,
  currentUserId: 'user-123',
  resolveAuthor: (id) => ChatAuthor(
    id: id,
    displayName: 'User',
  ),
  onSend: (text) {
    controller.insertMessage(
      TextMessage(
        id: const Uuid().v4(),
        authorId: 'user-123',
        createdAt: DateTime.now(),
        text: text,
      ),
    );
  },
);
```

That's it. `ChatView` renders the message list, date separators, and the input bar.

---

## Architecture

```
┌──────────────────────────────────────────┐
│                ChatView                  │
│  ┌─────────────────┐ ┌───────────────┐  │
│  │ ChatMessageList  │ │ ChatComposer  │  │
│  │ (SliverAnimated) │ │ (TextField)   │  │
│  └────────┬─────────┘ └──────┬────────┘  │
│           │                  │           │
│     ChatScope (InheritedWidget – DI)     │
│  ┌────────┴──────────────────┴────────┐  │
│  │  controller · theme · builders     │  │
│  │  resolveAuthor · l10n · callbacks  │  │
│  └────────────────────────────────────┘  │
└──────────────────────────────────────────┘
         │
   ChatController (interface)
         │
   InMemoryChatController
   ├─ messages: List<ChatMessage>
   ├─ insertMessage()
   ├─ removeMessage()
   ├─ updateMessage()
   └─ setMessages()
```

---

## Message types

All message types are subtypes of the **sealed** class `ChatMessage`:

| Type | Key fields |
|------|-----------|
| `TextMessage` | `text` |
| `ImageMessage` | `imageUrl`, `width`, `height` |
| `FileMessage` | `fileName`, `fileUrl`, `mimeType`, `fileSizeBytes` |
| `SystemMessage` | `text` |
| `CustomMessage` | `metadata` |

Exhaustive matching with Dart 3 `switch`:

```dart
switch (message) {
  case TextMessage(:final text)       => Text(text),
  case ImageMessage(:final imageUrl)  => Image.network(imageUrl),
  case FileMessage(:final fileName)   => Text(fileName),
  case SystemMessage(:final text)     => Text(text, style: italicStyle),
  case CustomMessage(:final metadata) => CustomWidget(metadata),
}
```

---

## Theming

### From your app theme

```dart
ChatView(
  theme: ChatTheme.fromThemeData(Theme.of(context)),
  // ...
)
```

### Custom colors

```dart
ChatView(
  theme: ChatTheme(
    colors: ChatColors(
      sentBubble: Colors.indigo,
      sentText: Colors.white,
      receivedBubble: Colors.grey.shade200,
      receivedText: Colors.black87,
      surface: Colors.white,
      onSurface: Colors.black,
      inputBackground: Colors.grey.shade100,
      inputText: Colors.black87,
      timestamp: Colors.grey,
      system: Colors.grey,
      divider: Colors.grey.shade300,
      seen: Colors.blue,
    ),
    typography: ChatTypography.standard(),
  ),
  // ...
)
```

---

## Custom builders

Override any widget by passing a `ChatBuilders`:

```dart
ChatView(
  builders: ChatBuilders(
    textMessageBuilder: (context, message, isMine) =>
        MyCustomBubble(message),
    avatarBuilder: (context, author) =>
        CircleAvatar(child: Text(author.displayName[0])),
    dateSeparatorBuilder: (context, date) =>
        Center(child: Chip(label: Text(formatDate(date)))),
    emptyStateBuilder: (context) =>
        const Center(child: Text('Start chatting!')),
    systemMessageBuilder: (context, message) =>
        Text(message.text, style: TextStyle(color: Colors.grey)),
  ),
  // ...
)
```

---

## Localization

```dart
ChatView(
  l10n: const ChatL10n(
    inputHint: 'Сообщение',
    emptyStateText: 'Нет сообщений',
    today: 'Сегодня',
    yesterday: 'Вчера',
  ),
  // ...
)
```

---

## Message lifecycle

```dart
// Insert (triggers slide-in animation)
controller.insertMessage(message);

// Update (e.g. delivery status)
controller.updateMessage(
  message.copyWith(status: MessageGroupStatus.delivered),
);

// Remove (triggers fade-out animation)
controller.removeMessage(message.id);

// Replace all (e.g. initial history load)
controller.setMessages(historyList);
```

---

## Delivery status

Each outgoing message can carry a `MessageGroupStatus`:

| Status | Icon |
|--------|------|
| `sending` | *(none)* |
| `sent` | ✓ |
| `delivered` | ✓✓ |
| `seen` | ✓✓ (colored) |
| `error` | ✗ |

---

## Callbacks

| Callback | Description |
|----------|-------------|
| `onSend` | User submits text from the composer |
| `onMessageTap` | Tap on a message bubble |
| `onMessageLongPress` | Long-press on a message bubble |
| `onLoadMore` | Scrolled to top — load earlier messages |

---

## API reference

### Models
- `ChatMessage` — Sealed base class
- `ChatAuthor` — Author with `id`, `displayName`, `avatarUrl`
- `ChatController` / `InMemoryChatController` — State management
- `ChatOperation` — Insert / Remove / Update / Set
- `MessageGroupStatus` — Delivery status enum

### Theme
- `ChatTheme` — Colors + typography + input decoration
- `ChatColors` — 12 configurable color slots
- `ChatTypography` — 4 text styles

### Widgets
- `ChatView` — Main entry point (list + composer)
- `ChatMessageList` — Animated scrollable list
- `ChatComposer` — Text input bar
- `ChatMessageBubble` — Individual message rendering
- `ChatScope` — InheritedWidget providing config

### Config
- `ChatBuilders` — Widget overrides
- `ChatL10n` — Localization strings

---

## License

MIT — see [LICENSE](LICENSE) for details.
