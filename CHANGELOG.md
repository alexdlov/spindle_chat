## 0.1.0

- Initial release.
- Sealed message types: `TextMessage`, `ImageMessage`, `FileMessage`, `SystemMessage`, `CustomMessage`.
- `ChatController` interface and `InMemoryChatController` implementation.
- `ChatView` widget with animated message list and composer.
- `ChatTheme` with `light()`, `dark()`, and `fromThemeData()` factories.
- `ChatBuilders` for full widget customization.
- `ChatL10n` for localization.
- Date separators and message grouping.
- Delivery status indicators.
- Pagination via `onLoadMore` callback.
