import 'package:readium/infrastructure/freedium/models/feed_card.dart';

/// The fully-decoded Freedium home feed.
class FeedPageResult {
  const FeedPageResult({
    required this.items,
    required this.randomItems,
    required this.isFeedEmpty,
    required this.backendError,
    required this.unlockedCount,
  });

  /// The main feed, in display order.
  final List<FeedCard> items;

  /// A secondary "random picks" list Freedium also returns.
  final List<FeedCard> randomItems;

  final bool isFeedEmpty;
  final String? backendError;

  /// Total number of paywalled articles Freedium reports having
  /// unlocked. Unlike [items], this is resolved immediately rather than
  /// streamed in behind a promise, so it's safe to show while the feed
  /// itself is still on its skeleton-loading state.
  final int unlockedCount;

  factory FeedPageResult.fromResolvedPageData(Map<String, dynamic> pageData) {
    final streamed =
        pageData['streamed'] as Map<String, dynamic>? ?? const {};
    final rawItems = (streamed['items'] as List?) ?? const [];
    final rawRandom = (streamed['randomItems'] as List?) ?? const [];

    return FeedPageResult(
      items: rawItems
          .cast<Map<String, dynamic>>()
          .map(FeedCard.fromMap)
          .toList(),
      randomItems: rawRandom
          .cast<Map<String, dynamic>>()
          .map(FeedCard.fromMap)
          .toList(),
      isFeedEmpty: streamed['isFeedEmpty'] as bool? ?? rawItems.isEmpty,
      backendError: streamed['backendError'] as String?,
      unlockedCount: (pageData['unlockedCount'] as num?)?.toInt() ?? 0,
    );
  }
}
