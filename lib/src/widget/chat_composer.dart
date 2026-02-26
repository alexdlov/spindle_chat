import 'package:flutter/material.dart';

import 'package:spindle_chat/src/widget/chat_scope.dart';

/// {@template chat_composer}
/// Message input bar at the bottom of the chat.
///
/// Provides a text field with an animated send button.
/// Can be fully replaced via [ChatBuilders.composerBuilder].
/// {@endtemplate}
class ChatComposer extends StatefulWidget {
  /// {@macro chat_composer}
  const ChatComposer({super.key});

  @override
  State<ChatComposer> createState() => _ChatComposerState();
}

class _ChatComposerState extends State<ChatComposer> {
  final TextEditingController _textController = TextEditingController();
  final ValueNotifier<bool> _hasText = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _textController
      ..removeListener(_onTextChanged)
      ..dispose();
    _hasText.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    _hasText.value = _textController.text.trim().isNotEmpty;
  }

  void _onSend() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    ChatScope.of(context).onSend?.call(text);
    _textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final scope = ChatScope.of(context);

    // Use custom builder if provided.
    if (scope.builders.composerBuilder case final builder?) {
      return builder(scope.onSend ?? (_) {});
    }

    final theme = scope.theme;

    return Container(
      decoration: BoxDecoration(
        color: theme.colors.surface,
        border: Border(top: BorderSide(color: theme.colors.divider, width: 0.5)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (scope.onAttachmentTap case final onAttachmentTap?)
                Semantics(
                  label: 'Add attachment',
                  button: true,
                  child: Material(
                    color: Colors.transparent,
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: onAttachmentTap,
                      customBorder: const CircleBorder(),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Icon(Icons.add, color: theme.colors.timestamp, size: 24),
                      ),
                    ),
                  ),
                ),
              Expanded(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 120),
                  child: TextField(
                    controller: _textController,
                    maxLines: null,
                    textInputAction: TextInputAction.newline,
                    style: theme.typography.bodyLarge.copyWith(color: theme.colors.inputText),
                    decoration:
                        theme.inputDecoration ??
                        InputDecoration(
                          hintText: scope.l10n.inputHint,
                          hintStyle: theme.typography.bodyLarge.copyWith(color: theme.colors.timestamp),
                          filled: true,
                          fillColor: theme.colors.inputBackground,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                        ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              ValueListenableBuilder<bool>(
                valueListenable: _hasText,
                builder:
                    (context, hasText, _) => AnimatedOpacity(
                      opacity: hasText ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 150),
                      child: IgnorePointer(
                        ignoring: !hasText,
                        child: Semantics(
                          label: 'Send message',
                          button: true,
                          child: Material(
                            color: theme.colors.sentBubble,
                            shape: const CircleBorder(),
                            child: InkWell(
                              onTap: _onSend,
                              customBorder: const CircleBorder(),
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Icon(Icons.send, color: theme.colors.sentText, size: 20),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
