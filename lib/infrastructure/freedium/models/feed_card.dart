import 'package:readium/core/utils/url_helper.dart';

/// A single card in the Freedium home feed.
///
/// Freedium mixes real article cards with occasional "quote" and "stat"
/// promotional cards to break up the feed visually. [FeedCard.fromMap]
/// resolves each raw card map to the right subtype so UI code can
/// pattern-match (`switch (card) { ArticleFeedCard c => ..., ... }`)
/// instead of null-checking a pile of fields that only apply to one card
/// type.
sealed class FeedCard {
  const FeedCard({required this.id});

  final int id;

  factory FeedCard.fromMap(Map<String, dynamic> map) {
    switch (map['cardType']) {
      case 'quote':
        return QuoteFeedCard.fromMap(map);
      case 'stat':
        return StatFeedCard.fromMap(map);
      default:
        // 'featured', 'standard', or any new type Freedium introduces —
        // treated as a normal article card so an unrecognized future
        // type degrades gracefully instead of crashing the whole feed.
        return ArticleFeedCard.fromMap(map);
    }
  }
}

/// A real Medium article card.
class ArticleFeedCard extends FeedCard {
  const ArticleFeedCard({
    required super.id,
    required this.slug,
    required this.title,
    required this.excerpt,
    required this.imageUrl,
    required this.readingTime,
    required this.publishedAt,
    required this.creatorName,
    this.collectionName,
    this.collectionAvatarId,
    this.cardType,
    this.size,
  });

  final String slug;
  final String title;
  final String excerpt;
  final String? imageUrl;
  final String readingTime;
  final DateTime? publishedAt;
  final String creatorName;
  final String? collectionName;
  final String? collectionAvatarId;

  /// Raw value from Freedium, e.g. `"featured"` / `"standard"`. Kept as
  /// the source string (rather than an enum) since we've only observed a
  /// couple of values and don't want a new one from Freedium to throw.
  final String? cardType;

  /// Layout size hint, e.g. `"wide"`, or `null`/`-1` when not set.
  final String? size;

  String? get absoluteImageUrl => UrlHelper.absoluteMediumImageUrl(imageUrl);

  factory ArticleFeedCard.fromMap(Map<String, dynamic> map) {
    final collection = map['collection'];
    return ArticleFeedCard(
      id: map['id'] as int,
      slug: map['slug'] as String,
      title: map['title'] as String? ?? '',
      excerpt: map['excerpt'] as String? ?? '',
      imageUrl: map['imageUrl'] as String?,
      readingTime: map['readingTime'] as String? ?? '',
      publishedAt: _parseDate(map['publishedAt']),
      creatorName: map['creator'] as String,
      collectionName: switch (collection) {
        Map<String, dynamic> c => c['name'] as String?,
        String s => s,
        _ => null,
      },
      collectionAvatarId: collection is Map<String, dynamic>
          ? collection['avatarId'] as String?
          : null,
      cardType: map['cardType'] as String?,
      size: map['size']?.toString(),
    );
  }
}

/// A decorative quote card interspersed in the feed.
class QuoteFeedCard extends FeedCard {
  const QuoteFeedCard({
    required super.id,
    required this.quoteText,
    this.attribution,
  });

  final String quoteText;
  final String? attribution;

  factory QuoteFeedCard.fromMap(Map<String, dynamic> map) => QuoteFeedCard(
        id: map['id'] as int,
        quoteText: map['quoteText'] as String? ?? '',
        attribution: map['creator'] as String?,
      );
}

/// A decorative statistic card interspersed in the feed.
class StatFeedCard extends FeedCard {
  const StatFeedCard({
    required super.id,
    required this.value,
    required this.label,
    this.description,
  });

  final String value;
  final String label;
  final String? description;

  factory StatFeedCard.fromMap(Map<String, dynamic> map) => StatFeedCard(
        id: map['id'] as int,
        value: map['statValue'] as String? ?? '',
        label: map['statLabel'] as String? ?? '',
        description: map['statDesc'] as String?,
      );
}

DateTime? _parseDate(dynamic raw) {
  if (raw is! String || raw.isEmpty) return null;
  return DateTime.tryParse(raw);
}
