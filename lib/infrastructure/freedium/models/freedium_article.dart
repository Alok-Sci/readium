/// One author byline on an article.
class ArticleAuthor {
  const ArticleAuthor({required this.name, this.avatarUrl});

  final String name;
  final String? avatarUrl;

  factory ArticleAuthor.fromMap(Map<String, dynamic> map) => ArticleAuthor(
        name: map['name'] as String? ?? '',
        avatarUrl: map['avatar'] as String?,
      );
}

/// One entry in the article's table of contents.
class TocEntry {
  const TocEntry({
    required this.id,
    required this.level,
    required this.title,
  });

  /// The HTML anchor id this entry jumps to (matches heading ids in
  /// [FreediumArticle.html]).
  final String id;

  /// Heading level, e.g. `3` for an `<h3>`.
  final int level;

  final String title;

  factory TocEntry.fromMap(Map<String, dynamic> map) => TocEntry(
        id: map['id'] as String? ?? '',
        level: (map['level'] as num?)?.toInt() ?? 0,
        title: map['title'] as String? ?? '',
      );
}

/// Metadata for a single article, independent of which content format
/// (HTML/Markdown) ends up rendered.
class ArticleMetadata {
  const ArticleMetadata({
    required this.title,
    this.subtitle,
    required this.authors,
    required this.readingTime,
    this.bylineBio,
    this.date,
    required this.publishedAt,
    this.updatedAt,
    required this.isFree,
    this.postImage,
    this.postImageZoom,
    this.postImageCaption,
    required this.url,
    required this.tableOfContents,
  });

  final String title;
  final String? subtitle;
  final List<ArticleAuthor> authors;
  final String readingTime;
  final String? bylineBio;
  final DateTime? date;
  final DateTime publishedAt;
  final DateTime? updatedAt;
  final bool isFree;
  final String? postImage;
  final String? postImageZoom;
  final String? postImageCaption;
  final String url;
  final List<TocEntry> tableOfContents;

  factory ArticleMetadata.fromMap(Map<String, dynamic> map) {
    final rawAuthors = (map['authors'] as List?) ?? const [];
    final rawToc = (map['tableOfContents'] as List?) ?? const [];
    return ArticleMetadata(
      title: map['title'] as String? ?? '',
      subtitle: map['subtitle'] as String?,
      authors: rawAuthors
          .cast<Map<String, dynamic>>()
          .map(ArticleAuthor.fromMap)
          .toList(),
      readingTime: map['readingTime'] as String,
      bylineBio: map['bylineBio'] as String?,
      date: _parseDate(map['date']),
      publishedAt: _parseDate(map['publishedAt']),
      updatedAt: _parseDate(map['updatedAt']),
      isFree: map['isFree'] as bool? ?? false,
      postImage: map['postImage'] as String?,
      postImageZoom: map['postImageZoom'] as String?,
      postImageCaption: map['postImageCaption'] as String?,
      url: map['url'] as String? ?? '',
      tableOfContents:
          rawToc.cast<Map<String, dynamic>>().map(TocEntry.fromMap).toList(),
    );
  }
}

/// A fully-parsed Freedium article response.
///
/// Both [html] and [markdown] are kept. This app renders from
/// [content] (== [markdown]) by default — see the package README for
/// why: Freedium's HTML embeds a duplicate light-theme *and*
/// dark-theme copy of every code block (picked apart only by Tailwind
/// classes a non-browser HTML renderer can't interpret), plus
/// browser-only copy-button markup, and — critically — never states a
/// code block's language anywhere machine-readable. The Markdown
/// version has one clean fenced code block per snippet, each with an
/// explicit ` ```language ` tag, which is what a syntax highlighter
/// actually needs. [html] is kept for callers that want it anyway
/// (debugging, a future HTML-based renderer, etc.).
class FreediumArticle {
  const FreediumArticle({
    required this.mediumUrl,
    required this.html,
    required this.markdown,
    required this.metadata,
    this.cacheStatus,
    this.renderTimeMs,
    this.error,
  });

  /// The original Medium URL this article was fetched for.
  final String mediumUrl;

  final String html;
  final String markdown;
  final ArticleMetadata metadata;

  /// Freedium's own cache status for this render, e.g. `"l2_hit_cdn"`.
  /// Useful for diagnostics, not meant to be shown to end users.
  final String? cacheStatus;
  final int? renderTimeMs;
  final String? error;

  /// The content this app renders. Currently [markdown] — see the class
  /// doc for why.
  String get content => markdown;

  factory FreediumArticle.fromResolvedPageData(
    Map<String, dynamic> pageData,
  ) {
    final eager = pageData['eager'] as Map<String, dynamic>? ?? const {};
    final articleMap = eager['article'] as Map<String, dynamic>? ?? const {};
    return FreediumArticle(
      mediumUrl: pageData['slug'] as String? ?? '',
      html: eager['html'] as String? ?? '',
      markdown: eager['markdown'] as String? ?? '',
      metadata: ArticleMetadata.fromMap(articleMap),
      cacheStatus: eager['cacheStatus'] as String?,
      renderTimeMs: (eager['renderTimeMs'] as num?)?.toInt(),
      error: eager['error'] as String?,
    );
  }
}

DateTime _parseDate(dynamic raw) {
  return DateTime.tryParse(raw)!;
}
