/// {@template spindle_chat}
/// Composable, themeable chat UI for Flutter.
///
/// ## Quick start
///
/// ```dart
/// import 'package:spindle_chat/spindle_chat.dart';
///
/// final controller = InMemoryChatController();
///
/// ChatView(
///   controller: controller,
///   currentUserId: 'user-123',
///   onSend: (text) {
///     controller.insertMessage(
///       TextMessage(
///         id: uuid(),
///         authorId: 'user-123',
///         createdAt: DateTime.now(),
///         text: text,
///       ),
///     );
///   },
/// )
/// ```
///
/// ## Architecture
///
/// - **Models** — Sealed [ChatMessage] hierarchy with exhaustive matching.
/// - **Controller** — [ChatController] interface + [InMemoryChatController].
/// - **Theme** — [ChatTheme] with `light` / `dark` / `fromThemeData` factories.
/// - **Widgets** — [ChatView] = [ChatMessageList] + [ChatComposer].
/// - **Customization** — [ChatBuilders] to override any widget.
/// - **DI** — [ChatScope] InheritedWidget.
/// {@endtemplate}
library;

// Models
export 'src/model/chat_author.dart';
export 'src/model/chat_controller.dart';
export 'src/model/chat_message.dart';
export 'src/model/chat_operation.dart';
export 'src/model/message_group_status.dart';

// Theme
export 'src/theme/chat_theme.dart';

// Widgets
export 'src/widget/chat_composer.dart';
export 'src/widget/chat_message_bubble.dart';
export 'src/widget/chat_message_list.dart';
export 'src/widget/chat_scope.dart';
export 'src/widget/chat_view.dart';
