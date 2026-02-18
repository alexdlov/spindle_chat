import 'package:meta/meta.dart';

/// Unique identifier for a chat message.
typedef MessageId = String;

/// Unique identifier for a chat user / author.
typedef AuthorId = String;

/// {@template chat_message_status}
/// Delivery status of a chat message.
/// {@endtemplate}
enum ChatMessageStatus {
  /// Message is being sent.
  sending,

  /// Message was sent to the server.
  sent,

  /// Message was delivered to the recipient.
  delivered,

  /// Message was read / seen by the recipient.
  seen,

  /// Message failed to send.
  error;

  /// Whether the message has been successfully delivered or read.
  bool get isDelivered => switch (this) {
    ChatMessageStatus.delivered || ChatMessageStatus.seen => true,
    _ => false,
  };
}

/// {@template chat_message}
/// A single chat message.
///
/// Sealed class hierarchy with exhaustive pattern matching:
/// [TextMessage], [ImageMessage], [FileMessage],
/// [SystemMessage], [CustomMessage].
/// {@endtemplate}
@immutable
sealed class ChatMessage {
  /// {@macro chat_message}
  const ChatMessage({
    required this.id,
    required this.authorId,
    required this.createdAt,
    this.status = ChatMessageStatus.sent,
    this.replyToMessageId,
    this.updatedAt,
    this.metadata,
  });

  /// Unique message identifier.
  final MessageId id;

  /// Author identifier.
  final AuthorId authorId;

  /// Time when the message was created.
  final DateTime createdAt;

  /// Current delivery status.
  final ChatMessageStatus status;

  /// ID of the message this one replies to, if any.
  final MessageId? replyToMessageId;

  /// Time when the message was last updated.
  final DateTime? updatedAt;

  /// Arbitrary metadata attached to the message.
  final Map<String, Object?>? metadata;

  /// Whether this message is a text message.
  bool get isText => this is TextMessage;

  /// Whether this message is a system message.
  bool get isSystem => this is SystemMessage;

  /// Whether the message has been edited.
  bool get isEdited => updatedAt != null;

  /// Create a copy with the given fields replaced.
  ChatMessage copyWith({
    ChatMessageStatus? status,
    MessageId? replyToMessageId,
    DateTime? updatedAt,
    Map<String, Object?>? metadata,
  });

  /// Serialize this message to JSON.
  Map<String, Object?> toJson();

  /// Deserialize a message from JSON.
  factory ChatMessage.fromJson(Map<String, Object?> json) {
    final type = json['type'] as String?;
    return switch (type) {
      'text' => TextMessage._fromJson(json),
      'image' => ImageMessage._fromJson(json),
      'file' => FileMessage._fromJson(json),
      'system' => SystemMessage._fromJson(json),
      'custom' => CustomMessage._fromJson(json),
      _ => throw FormatException('Unknown message type: $type', json),
    };
  }

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is ChatMessage && id == other.id);
}

// ---------------------------------------------------------------------------
// Subtypes
// ---------------------------------------------------------------------------

/// {@template text_message}
/// A plain text chat message.
/// {@endtemplate}
final class TextMessage extends ChatMessage {
  /// {@macro text_message}
  const TextMessage({
    required super.id,
    required super.authorId,
    required super.createdAt,
    required this.text,
    super.status,
    super.replyToMessageId,
    super.updatedAt,
    super.metadata,
  });

  /// The text content of the message.
  final String text;

  factory TextMessage._fromJson(Map<String, Object?> json) => TextMessage(
    id: json['id'] as MessageId,
    authorId: json['authorId'] as AuthorId,
    createdAt: DateTime.parse(json['createdAt'] as String),
    text: json['text'] as String,
    status: ChatMessageStatus.values.byName(
      json['status'] as String? ?? 'sent',
    ),
    replyToMessageId: json['replyToMessageId'] as MessageId?,
    updatedAt: switch (json['updatedAt']) {
      final String v => DateTime.parse(v),
      _ => null,
    },
    metadata: json['metadata'] as Map<String, Object?>?,
  );

  @override
  TextMessage copyWith({
    String? text,
    ChatMessageStatus? status,
    MessageId? replyToMessageId,
    DateTime? updatedAt,
    Map<String, Object?>? metadata,
  }) => TextMessage(
    id: id,
    authorId: authorId,
    createdAt: createdAt,
    text: text ?? this.text,
    status: status ?? this.status,
    replyToMessageId: replyToMessageId ?? this.replyToMessageId,
    updatedAt: updatedAt ?? this.updatedAt,
    metadata: metadata ?? this.metadata,
  );

  @override
  Map<String, Object?> toJson() => <String, Object?>{
    'type': 'text',
    'id': id,
    'authorId': authorId,
    'createdAt': createdAt.toIso8601String(),
    'text': text,
    'status': status.name,
    'replyToMessageId': replyToMessageId,
    'updatedAt': updatedAt?.toIso8601String(),
    'metadata': metadata,
  };

  @override
  String toString() =>
      'TextMessage{id: $id, author: $authorId, '
      'text: ${text.length > 30 ? '${text.substring(0, 30)}...' : text}}';
}

/// {@template image_message}
/// An image chat message.
/// {@endtemplate}
final class ImageMessage extends ChatMessage {
  /// {@macro image_message}
  const ImageMessage({
    required super.id,
    required super.authorId,
    required super.createdAt,
    required this.imageUrl,
    this.caption,
    this.width,
    this.height,
    this.thumbUrl,
    super.status,
    super.replyToMessageId,
    super.updatedAt,
    super.metadata,
  });

  /// URL of the image.
  final String imageUrl;

  /// Optional caption.
  final String? caption;

  /// Image width in logical pixels.
  final double? width;

  /// Image height in logical pixels.
  final double? height;

  /// URL of the thumbnail preview.
  final String? thumbUrl;

  factory ImageMessage._fromJson(Map<String, Object?> json) => ImageMessage(
    id: json['id'] as MessageId,
    authorId: json['authorId'] as AuthorId,
    createdAt: DateTime.parse(json['createdAt'] as String),
    imageUrl: json['imageUrl'] as String,
    caption: json['caption'] as String?,
    width: (json['width'] as num?)?.toDouble(),
    height: (json['height'] as num?)?.toDouble(),
    thumbUrl: json['thumbUrl'] as String?,
    status: ChatMessageStatus.values.byName(
      json['status'] as String? ?? 'sent',
    ),
    replyToMessageId: json['replyToMessageId'] as MessageId?,
    updatedAt: switch (json['updatedAt']) {
      final String v => DateTime.parse(v),
      _ => null,
    },
    metadata: json['metadata'] as Map<String, Object?>?,
  );

  @override
  ImageMessage copyWith({
    String? imageUrl,
    String? caption,
    double? width,
    double? height,
    String? thumbUrl,
    ChatMessageStatus? status,
    MessageId? replyToMessageId,
    DateTime? updatedAt,
    Map<String, Object?>? metadata,
  }) => ImageMessage(
    id: id,
    authorId: authorId,
    createdAt: createdAt,
    imageUrl: imageUrl ?? this.imageUrl,
    caption: caption ?? this.caption,
    width: width ?? this.width,
    height: height ?? this.height,
    thumbUrl: thumbUrl ?? this.thumbUrl,
    status: status ?? this.status,
    replyToMessageId: replyToMessageId ?? this.replyToMessageId,
    updatedAt: updatedAt ?? this.updatedAt,
    metadata: metadata ?? this.metadata,
  );

  @override
  Map<String, Object?> toJson() => <String, Object?>{
    'type': 'image',
    'id': id,
    'authorId': authorId,
    'createdAt': createdAt.toIso8601String(),
    'imageUrl': imageUrl,
    'caption': caption,
    'width': width,
    'height': height,
    'thumbUrl': thumbUrl,
    'status': status.name,
    'replyToMessageId': replyToMessageId,
    'updatedAt': updatedAt?.toIso8601String(),
    'metadata': metadata,
  };

  @override
  String toString() =>
      'ImageMessage{id: $id, author: $authorId, url: $imageUrl}';
}

/// {@template file_message}
/// A file attachment chat message.
/// {@endtemplate}
final class FileMessage extends ChatMessage {
  /// {@macro file_message}
  const FileMessage({
    required super.id,
    required super.authorId,
    required super.createdAt,
    required this.fileUrl,
    required this.fileName,
    this.fileSize,
    this.mimeType,
    super.status,
    super.replyToMessageId,
    super.updatedAt,
    super.metadata,
  });

  /// URL to download the file.
  final String fileUrl;

  /// Display name of the file.
  final String fileName;

  /// File size in bytes.
  final int? fileSize;

  /// MIME type of the file.
  final String? mimeType;

  factory FileMessage._fromJson(Map<String, Object?> json) => FileMessage(
    id: json['id'] as MessageId,
    authorId: json['authorId'] as AuthorId,
    createdAt: DateTime.parse(json['createdAt'] as String),
    fileUrl: json['fileUrl'] as String,
    fileName: json['fileName'] as String,
    fileSize: json['fileSize'] as int?,
    mimeType: json['mimeType'] as String?,
    status: ChatMessageStatus.values.byName(
      json['status'] as String? ?? 'sent',
    ),
    replyToMessageId: json['replyToMessageId'] as MessageId?,
    updatedAt: switch (json['updatedAt']) {
      final String v => DateTime.parse(v),
      _ => null,
    },
    metadata: json['metadata'] as Map<String, Object?>?,
  );

  @override
  FileMessage copyWith({
    String? fileUrl,
    String? fileName,
    int? fileSize,
    String? mimeType,
    ChatMessageStatus? status,
    MessageId? replyToMessageId,
    DateTime? updatedAt,
    Map<String, Object?>? metadata,
  }) => FileMessage(
    id: id,
    authorId: authorId,
    createdAt: createdAt,
    fileUrl: fileUrl ?? this.fileUrl,
    fileName: fileName ?? this.fileName,
    fileSize: fileSize ?? this.fileSize,
    mimeType: mimeType ?? this.mimeType,
    status: status ?? this.status,
    replyToMessageId: replyToMessageId ?? this.replyToMessageId,
    updatedAt: updatedAt ?? this.updatedAt,
    metadata: metadata ?? this.metadata,
  );

  @override
  Map<String, Object?> toJson() => <String, Object?>{
    'type': 'file',
    'id': id,
    'authorId': authorId,
    'createdAt': createdAt.toIso8601String(),
    'fileUrl': fileUrl,
    'fileName': fileName,
    'fileSize': fileSize,
    'mimeType': mimeType,
    'status': status.name,
    'replyToMessageId': replyToMessageId,
    'updatedAt': updatedAt?.toIso8601String(),
    'metadata': metadata,
  };

  @override
  String toString() =>
      'FileMessage{id: $id, author: $authorId, file: $fileName}';
}

/// {@template system_message}
/// A system / service message (e.g. "User joined the chat").
/// {@endtemplate}
final class SystemMessage extends ChatMessage {
  /// {@macro system_message}
  const SystemMessage({
    required super.id,
    required super.createdAt,
    required this.text,
    super.metadata,
  }) : super(authorId: '');

  /// The system message text.
  final String text;

  factory SystemMessage._fromJson(Map<String, Object?> json) => SystemMessage(
    id: json['id'] as MessageId,
    createdAt: DateTime.parse(json['createdAt'] as String),
    text: json['text'] as String,
    metadata: json['metadata'] as Map<String, Object?>?,
  );

  @override
  SystemMessage copyWith({
    String? text,
    ChatMessageStatus? status,
    MessageId? replyToMessageId,
    DateTime? updatedAt,
    Map<String, Object?>? metadata,
  }) => SystemMessage(
    id: id,
    createdAt: createdAt,
    text: text ?? this.text,
    metadata: metadata ?? this.metadata,
  );

  @override
  Map<String, Object?> toJson() => <String, Object?>{
    'type': 'system',
    'id': id,
    'authorId': '',
    'createdAt': createdAt.toIso8601String(),
    'text': text,
    'metadata': metadata,
  };

  @override
  String toString() => 'SystemMessage{id: $id, text: $text}';
}

/// {@template custom_message}
/// A custom message with arbitrary data in [metadata].
/// {@endtemplate}
final class CustomMessage extends ChatMessage {
  /// {@macro custom_message}
  const CustomMessage({
    required super.id,
    required super.authorId,
    required super.createdAt,
    super.status,
    super.replyToMessageId,
    super.updatedAt,
    super.metadata,
  });

  factory CustomMessage._fromJson(Map<String, Object?> json) => CustomMessage(
    id: json['id'] as MessageId,
    authorId: json['authorId'] as AuthorId,
    createdAt: DateTime.parse(json['createdAt'] as String),
    status: ChatMessageStatus.values.byName(
      json['status'] as String? ?? 'sent',
    ),
    replyToMessageId: json['replyToMessageId'] as MessageId?,
    updatedAt: switch (json['updatedAt']) {
      final String v => DateTime.parse(v),
      _ => null,
    },
    metadata: json['metadata'] as Map<String, Object?>?,
  );

  @override
  CustomMessage copyWith({
    ChatMessageStatus? status,
    MessageId? replyToMessageId,
    DateTime? updatedAt,
    Map<String, Object?>? metadata,
  }) => CustomMessage(
    id: id,
    authorId: authorId,
    createdAt: createdAt,
    status: status ?? this.status,
    replyToMessageId: replyToMessageId ?? this.replyToMessageId,
    updatedAt: updatedAt ?? this.updatedAt,
    metadata: metadata ?? this.metadata,
  );

  @override
  Map<String, Object?> toJson() => <String, Object?>{
    'type': 'custom',
    'id': id,
    'authorId': authorId,
    'createdAt': createdAt.toIso8601String(),
    'status': status.name,
    'replyToMessageId': replyToMessageId,
    'updatedAt': updatedAt?.toIso8601String(),
    'metadata': metadata,
  };

  @override
  String toString() => 'CustomMessage{id: $id, author: $authorId}';
}
