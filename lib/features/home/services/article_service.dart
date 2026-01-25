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
    final gridDiv = document.querySelector('div.grid');
    if (gridDiv == null) return articles;

    // Find all article cards
    final articleCards = gridDiv.querySelectorAll('div.p-6');

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
  static Article? _parseArticleCard(Element card) {
    try {
      // Extract endpoint from the main link
      final mainLink = card.querySelector('a.group');
      if (mainLink == null) return null;
      final endpoint = mainLink.attributes['href'] ?? '';

      // Extract image URL
      final img = card.querySelector('img');
      final imageUrl = img?.attributes['src'];

      // Extract title
      final titleElement = card.querySelector('h3');
      final title = titleElement?.text.trim() ?? '';

      // Extract metadata container
      final metadataDiv = card.querySelector('div.flex.flex-wrap');
      if (metadataDiv == null) return null;

      // Extract author info (if exists)
      final authorLink = metadataDiv.querySelector('a[href^="https://medium.com"]');
      String? authorName;
      String? authorImageUrl;
      if (authorLink != null) {
        final pubImg = authorLink.querySelector('img');
        authorImageUrl = pubImg?.attributes['src'];
        final pubText = authorLink.querySelector('p');
        authorName = pubText?.text.trim();
      }

      // Extract all text spans
      final spans = metadataDiv.querySelectorAll('span');
      String readTime = '';
      String publishDate = '';
      bool isMemberOnly = false;

      for (final span in spans) {
        final text = span.text.trim();
        
        // Check for read time (contains "min read")
        if (text.contains('min read')) {
          readTime = text.replaceAll('~', '');
        }
        // Check for publish date (contains date patterns)
        else if (text.contains('202') || text.contains('Updated:')) {
          publishDate = text.split('(').first;
        }
        // Check for member-only status
        else if (text.startsWith('Free:')) {
          isMemberOnly = text.contains('No');
        }
        // // Check if it's author name (not a separator and not other metadata)
        // else if (text.isNotEmpty && 
        //          text != '·' && 
        //          !text.contains('min read') && 
        //          !text.contains('Free:') &&
        //          authorName == null) {
        //   authorName = text;
        // }
      }

      // Extract subtitle
      final subtitleElement = card.querySelector('p.mt-6.leading-normal');
      final subtitle = subtitleElement?.text.trim() ?? '';

      return Article(
        endpoint: endpoint,
        imageUrl: imageUrl,
        title: title,
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
