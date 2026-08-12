import 'package:html/dom.dart';
import 'package:readium/core/utils/url_helper.dart';
import 'package:readium/features/article/models/article_tag.dart';

/// Data class for extracted article metadata
class ArticleMetadata {
  final String title;
  final String subtitle;
  final String publishDate;
  final String? coverImageUrl;
  final String authorName;
  final String authorImageUrl;
  final String readTime;
  final List<ArticleTag> tags;

  ArticleMetadata({
    required this.title,
    required this.subtitle,
    required this.publishDate,
    this.coverImageUrl,
    required this.authorName,
    required this.authorImageUrl,
    required this.readTime,
    required this.tags,
  });
}

/// Extracts metadata from Freedium article DOM structure
class ArticleMetadataExtractor {
  /// Extract all metadata from article element
  static ArticleMetadata extract(Element article) {
    final coverImg = _extractCoverImage(article);
    final header = article.querySelector('header');
    
    final publishDate = _extractPublishDate(header);
    final title = _extractTitle(header);
    final subtitle = _extractSubtitle(header);
    final authorInfo = _extractAuthorInfo(header);
    final tags = _extractTags(article);

    // Remove header and cover after extraction
    header?.remove();
    coverImg?.element.remove();

    return ArticleMetadata(
      title: title,
      subtitle: subtitle,
      publishDate: publishDate,
      coverImageUrl: coverImg?.url,
      authorName: authorInfo.name,
      authorImageUrl: authorInfo.imageUrl,
      readTime: authorInfo.readTime,
      tags: tags,
    );
  }

  /// Extract cover image
  static ({Element element, String? url, String? alt})? _extractCoverImage(
      Element article) {
    final img = article.querySelector('img');
    if (img == null) return null;

    final relativeUrl = img.attributes['src'] ?? '';
    final absoluteUrl = UrlHelper.makeAbsolute(relativeUrl);

    return (
      element: img,
      url: absoluteUrl.isNotEmpty ? absoluteUrl : null,
      alt: img.attributes['alt'],
    );
  }

  /// Extract publish date from header
  static String _extractPublishDate(Element? header) {
    final publishDateEl = header?.querySelector('p');
    return publishDateEl?.text.trim() ?? '';
  }

  /// Extract article title from header
  static String _extractTitle(Element? header) {
    final titleEl = header?.querySelector('h1');
    return titleEl?.text.trim() ?? '';
  }

  /// Extract article subtitle from header
  static String _extractSubtitle(Element? header) {
    final subtitleEl = header?.querySelectorAll('p').elementAtOrNull(1);
    return subtitleEl?.text.trim() ?? '';
  }

  /// Extract author information from header
  static ({String name, String imageUrl, String readTime}) _extractAuthorInfo(
      Element? header) {
    final authorDiv = header?.querySelector('div.flex.items-start') ??
        header?.querySelectorAll('div').lastOrNull;

    if (authorDiv == null) {
      return (name: '', imageUrl: '', readTime: '');
    }

    // Extract author image
    final authorImg = authorDiv.querySelector('img');
    final relativeAuthorUrl = authorImg?.attributes['src'] ?? '';
    final authorImageUrl = UrlHelper.makeAbsolute(relativeAuthorUrl);

    // Extract author name and read time
    final authorInfo = authorDiv.querySelectorAll('div > p');
    String authorName = '';
    String readTime = '';

    if (authorInfo.isNotEmpty) {
      authorName = authorInfo[0].text.trim().replaceFirst('By ', '');
    }
    if (authorInfo.length > 1) {
      readTime = authorInfo[1].text.trim();
    }

    return (name: authorName, imageUrl: authorImageUrl, readTime: readTime);
  }

  /// Extract article tags
  static List<ArticleTag> _extractTags(Element article) {
    final tagAnchors =
        article.querySelectorAll('a[href*="https://medium.com/tag/"]');
    
    return tagAnchors.map((a) {
      var href = a.attributes['href'] ?? '';
      href = href.replaceAll('#bypass', '');
      final title = a.attributes['title'] ?? a.text.trim();
      return ArticleTag(title: title, href: href);
    }).toList();
  }
}
