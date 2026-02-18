import 'package:meta/meta.dart';

/// {@template message_group_status}
/// Position of a message within a visual group.
///
/// Messages from the same author sent in quick succession form a group.
/// The group status determines styling (corner radii, spacing, avatar).
/// {@endtemplate}
@immutable
sealed class MessageGroupStatus {
  const MessageGroupStatus._();

  /// The message is the only one in its group.
  @literal
  const factory MessageGroupStatus.single() = _Single;

  /// First message in a group (shows author name + avatar).
  @literal
  const factory MessageGroupStatus.first() = _First;

  /// Middle message — no author, no tail.
  @literal
  const factory MessageGroupStatus.middle() = _Middle;

  /// Last message in a group (shows tail / avatar).
  @literal
  const factory MessageGroupStatus.last() = _Last;

  /// Whether the avatar / author name should be shown.
  bool get showAuthor => switch (this) {
    _Single() || _First() => true,
    _ => false,
  };

  /// Whether this is the tail of the group (last or single).
  bool get showTail => switch (this) {
    _Single() || _Last() => true,
    _ => false,
  };
}

final class _Single extends MessageGroupStatus {
  const _Single() : super._();

  @override
  String toString() => 'MessageGroupStatus.single';
}

final class _First extends MessageGroupStatus {
  const _First() : super._();

  @override
  String toString() => 'MessageGroupStatus.first';
}

final class _Middle extends MessageGroupStatus {
  const _Middle() : super._();

  @override
  String toString() => 'MessageGroupStatus.middle';
}

final class _Last extends MessageGroupStatus {
  const _Last() : super._();

  @override
  String toString() => 'MessageGroupStatus.last';
}
