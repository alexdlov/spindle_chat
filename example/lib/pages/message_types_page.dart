import 'package:flutter/material.dart';
import 'package:spindle_chat/spindle_chat.dart';

/// Demonstrates all five message types supported by spindle_chat:
/// [TextMessage], [ImageMessage], [FileMessage], [SystemMessage], [CustomMessage].
///
/// Also shows delivery statuses, edited messages, and message grouping.
class MessageTypesPage extends StatefulWidget {
  const MessageTypesPage({super.key});

  @override
  State<MessageTypesPage> createState() => _MessageTypesPageState();
}

class _MessageTypesPageState extends State<MessageTypesPage> {
  static const _currentUserId = 'user-1';
  static const _otherUserId = 'user-2';

  final _controller = InMemoryChatController();
  int _counter = 100;

  final _authors = <String, ChatAuthor>{
    'user-1': const ChatAuthor(id: 'user-1', displayName: 'You'),
    'user-2': const ChatAuthor(
      id: 'user-2',
      displayName: 'Bob',
      avatarUrl: 'https://i.pravatar.cc/150?u=bob',
    ),
  };

  @override
  void initState() {
    super.initState();
    _loadShowcaseMessages();
  }

  void _loadShowcaseMessages() {
    final now = DateTime.now();

    _controller.setMessages([
      // System message — marks the beginning of conversation
      SystemMessage(
        id: 'sys-1',
        createdAt: now.subtract(const Duration(minutes: 20)),
        text: 'Chat created',
      ),

      // Text messages with grouping
      TextMessage(
        id: 'txt-1',
        authorId: _otherUserId,
        createdAt: now.subtract(const Duration(minutes: 18)),
        text: 'Hey! Let me show you all the message types.',
      ),
      TextMessage(
        id: 'txt-2',
        authorId: _otherUserId,
        createdAt: now.subtract(const Duration(minutes: 17, seconds: 50)),
        text: 'First, here\'s a regular text message with delivery statuses.',
      ),

      // Text with "seen" status
      TextMessage(
        id: 'txt-3',
        authorId: _currentUserId,
        createdAt: now.subtract(const Duration(minutes: 16)),
        text: 'Got it! This one is marked as "seen" ✓✓',
        status: ChatMessageStatus.seen,
      ),

      // Text with "delivered" status
      TextMessage(
        id: 'txt-4',
        authorId: _currentUserId,
        createdAt: now.subtract(const Duration(minutes: 15, seconds: 50)),
        text: 'And this one is "delivered" ✓✓',
        status: ChatMessageStatus.delivered,
      ),

      // Text with "sent" status
      TextMessage(
        id: 'txt-5',
        authorId: _currentUserId,
        createdAt: now.subtract(const Duration(minutes: 15, seconds: 40)),
        text: 'This is just "sent" ✓',
        status: ChatMessageStatus.sent,
      ),

      // Edited message
      TextMessage(
        id: 'txt-6',
        authorId: _otherUserId,
        createdAt: now.subtract(const Duration(minutes: 14)),
        text: 'This message was edited after sending.',
        updatedAt: now.subtract(const Duration(minutes: 13)),
      ),

      // Image message
      ImageMessage(
        id: 'img-1',
        authorId: _otherUserId,
        createdAt: now.subtract(const Duration(minutes: 12)),
        imageUrl: 'https://picsum.photos/seed/spindle1/400/300',
        caption: 'Check out this beautiful landscape!',
        width: 400,
        height: 300,
      ),

      TextMessage(
        id: 'txt-7',
        authorId: _currentUserId,
        createdAt: now.subtract(const Duration(minutes: 10)),
        text: 'Nice! Here\'s one from me too:',
        status: ChatMessageStatus.seen,
      ),

      ImageMessage(
        id: 'img-2',
        authorId: _currentUserId,
        createdAt: now.subtract(const Duration(minutes: 9)),
        imageUrl: 'https://picsum.photos/seed/spindle2/400/250',
        status: ChatMessageStatus.seen,
      ),

      // File messages
      FileMessage(
        id: 'file-1',
        authorId: _otherUserId,
        createdAt: now.subtract(const Duration(minutes: 7)),
        fileUrl: 'https://example.com/report.pdf',
        fileName: 'Q4_Report_2025.pdf',
        fileSize: 2456789,
        mimeType: 'application/pdf',
      ),

      FileMessage(
        id: 'file-2',
        authorId: _currentUserId,
        createdAt: now.subtract(const Duration(minutes: 6)),
        fileUrl: 'https://example.com/design.fig',
        fileName: 'chat_redesign_v3.fig',
        fileSize: 15728640,
        mimeType: 'application/x-figma',
        status: ChatMessageStatus.delivered,
      ),

      // System message
      SystemMessage(
        id: 'sys-2',
        createdAt: now.subtract(const Duration(minutes: 4)),
        text: 'Bob changed the group photo',
      ),

      // Custom message (rendered as a card since there's no custom builder set)
      TextMessage(
        id: 'txt-8',
        authorId: _otherUserId,
        createdAt: now.subtract(const Duration(minutes: 3)),
        text: 'That covers all the message types! 🎉',
      ),

      // Error status
      TextMessage(
        id: 'txt-err',
        authorId: _currentUserId,
        createdAt: now.subtract(const Duration(minutes: 1)),
        text: 'This message failed to send.',
        status: ChatMessageStatus.error,
      ),
    ]);
  }

  void _handleSend(String text) {
    _controller.insertMessage(
      TextMessage(
        id: 'msg-${++_counter}',
        authorId: _currentUserId,
        createdAt: DateTime.now(),
        text: text,
        status: ChatMessageStatus.sent,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Message Types')),
    body: ChatView(
      controller: _controller,
      currentUserId: _currentUserId,
      resolveAuthor: (id) => _authors[id],
      onSend: _handleSend,
      onAttachmentTap: () => _showAttachmentSheet(context),
      onMessageTap: (message) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tapped: ${message.id}'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      onMessageLongPress: (message) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Long-pressed: ${message.id}'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
    ),
  );

  void _showAttachmentSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder:
          (ctx) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.photo)),
                  title: const Text('Photo'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _controller.insertMessage(
                      ImageMessage(
                        id: 'img-${++_counter}',
                        authorId: _currentUserId,
                        createdAt: DateTime.now(),
                        imageUrl:
                            'https://picsum.photos/seed/attach$_counter/400/300',
                        caption: 'Sent from the attachment picker',
                        status: ChatMessageStatus.sent,
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.insert_drive_file),
                  ),
                  title: const Text('File'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _controller.insertMessage(
                      FileMessage(
                        id: 'file-${++_counter}',
                        authorId: _currentUserId,
                        createdAt: DateTime.now(),
                        fileUrl: 'https://example.com/doc.pdf',
                        fileName: 'document_$_counter.pdf',
                        fileSize: 2097152,
                        mimeType: 'application/pdf',
                        status: ChatMessageStatus.sent,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
    );
  }
}
