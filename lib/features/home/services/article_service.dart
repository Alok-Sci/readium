import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart';
import '../models/article.dart';

class ArticleService {
  static const String baseUrl = 'https://freedium-mirror.cfd';

  /// Fetches articles from the freedium-mirror.cfd homepage
  static Future<List<Article>> fetchArticles() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        return _parseArticles(response.body);
      } else {
        throw Exception('Failed to load articles: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching articles: $e');
    }
  }

  /// Parses HTML and extracts article information
  static List<Article> _parseArticles(String htmlContent) {
    final document = html_parser.parse(htmlContent);
    final articles = <Article>[];

    // Find the grid container
    final gridDiv = document.querySelector('div.feed');
    if (gridDiv == null) return articles;

    // Find all article cards
    final articleCards = gridDiv.querySelectorAll('a.card-link');

    for (final card in articleCards) {
      try {
        final article = _parseArticleCard(card);
        if (article != null) {
          articles.add(article);
        }
      } catch (e) {
        // Skip invalid articles
        continue;
      }
    }

    return articles;
  }

  /// Parses a single article card
  static Article? _parseArticleCard(Element article) {
    try {
      // Extract endpoint
      final endpoint = article.attributes['href'] ?? '';

      // Extract Card
      final card = article.querySelector('article.card');
      if (card == null) return null;

      // Extract image URL from thumb
      final thumb = card.querySelector('.thumb');
      final img = thumb?.querySelector('.thumb-img');
      final imageUrl = img?.attributes['src'];

      // Extract read time from thumb
      final readTimeSpan = thumb?.querySelector('.read-time');
      final readTime = readTimeSpan?.text.trim() ?? '';

      // Extract body
      final body = card.querySelector('.body');
      if (body == null) return null;

      // Extract topic
      final topicElement = body.querySelector('.topic');
      final topic = topicElement?.text.trim() ?? '';

      // Extract title
      final titleElement = body.querySelector('.title');
      final title = titleElement?.text.trim().replaceAll('"', '') ?? '';

      // Extract subtitle
      final subtitleElement = body.querySelector('.excerpt');
      final subtitle = subtitleElement?.text.trim() ?? '';

      // Extract metadata
      final metadataDiv = body.querySelector('.meta');
      if (metadataDiv == null) return null;

      // Extract author info
      final authorDiv = metadataDiv.querySelector('.author');
      String? authorName;
      String? authorImageUrl;
      
      if (authorDiv != null) {
        // Try to get author image (if exists)
        final authorImg = authorDiv.querySelector('img');
        authorImageUrl = authorImg?.attributes['src'];
        
        // Get author name from text content
        authorName = authorDiv.text.trim();
      }

      // Extract publish date
      final dateSpan = metadataDiv.querySelector('.date');
      final publishDate = dateSpan?.text.trim() ?? '';

      // Member-only status (currently not in new HTML, default to false)
      bool isMemberOnly = false;

      return Article(
        endpoint: endpoint,
        imageUrl: imageUrl,
        title: title,
        topic: topic,
        authorName: authorName,
        authorImageUrl: authorImageUrl,
        readTime: readTime,
        publishDate: publishDate,
        isMemberOnly: isMemberOnly,
        subtitle: subtitle,
      );
    } catch (e) {
      return null;
    }
  }
}
