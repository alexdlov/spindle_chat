import 'package:meta/meta.dart';

import 'chat_message.dart';

/// {@template chat_author}
/// Represents a chat participant.
/// {@endtemplate}
@immutable
class ChatAuthor {
  /// {@macro chat_author}
  const ChatAuthor({required this.id, this.displayName, this.avatarUrl});

  /// Unique author identifier.
  final AuthorId id;

  /// Human-readable name.
  final String? displayName;

  /// URL to the author's avatar image.
  final String? avatarUrl;

  /// Returns [displayName] or a fallback derived from [id].
  String get effectiveName => displayName ?? id;

  /// Create a copy with the given fields replaced.
  ChatAuthor copyWith({AuthorId? id, String? displayName, String? avatarUrl}) =>
      ChatAuthor(
        id: id ?? this.id,
        displayName: displayName ?? this.displayName,
        avatarUrl: avatarUrl ?? this.avatarUrl,
      );

  /// Serialize to JSON.
  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'displayName': displayName,
    'avatarUrl': avatarUrl,
  };

  /// Deserialize from JSON.
  factory ChatAuthor.fromJson(Map<String, Object?> json) => ChatAuthor(
    id: json['id'] as AuthorId,
    displayName: json['displayName'] as String?,
    avatarUrl: json['avatarUrl'] as String?,
  );

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is ChatAuthor && id == other.id);

  @override
  String toString() => 'ChatAuthor{id: $id, name: $effectiveName}';
}
