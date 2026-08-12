import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/article.dart';

class ArticleService {
  static const String baseUrl = 'https://freedium-mirror.cfd';

  /// Fetches articles from the freedium-mirror.cfd homepage
  /// The site uses Svelte SSR and embeds initial state in a script tag
  static Future<List<Article>> fetchArticles() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        return _parseArticlesFromSvelteState(response.body);
      } else {
        throw Exception('Failed to load articles: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching articles: $e');
    }
  }

  /// Parses articles from Svelte's initial state embedded in script tag
  static List<Article> _parseArticlesFromSvelteState(String htmlContent) {
    final articles = <Article>[];

    try {
      // Find the script tag that contains __sveltekit_*.resolve with initial state
      final scriptRegex = RegExp(
        r'<script>__sveltekit_[^.]+\.resolve\(1,\s*\(\)\s*=>\s*(\[.*?\])\)</script>',
        dotAll: true,
      );

      final match = scriptRegex.firstMatch(htmlContent);
      if (match == null) {
        return articles;
      }

      final jsonString = match.group(1);
      if (jsonString == null) {
        return articles;
      }

      // Parse JSON
      final List<dynamic> data = jsonDecode(jsonString);
      if (data.isEmpty) {
        return articles;
      }

      // Extract items array
      final firstObject = data[0] as Map<String, dynamic>;
      final items = firstObject['items'] as List<dynamic>?;

      if (items == null) {
        return articles;
      }

      // Parse each article
      for (final item in items) {
        try {
          final article = _parseArticleFromJson(item as Map<String, dynamic>);
          if (article != null) {
            articles.add(article);
          }
        } catch (e) {
          // Skip invalid articles
          continue;
        }
      }
    } catch (e) {
      // Return empty list if parsing fails
      return articles;
    }

    return articles;
  }

  /// Parses a single article from JSON data
  static Article? _parseArticleFromJson(Map<String, dynamic> json) {
    try {
      // Skip non-article cards (quotes, stats, etc.)
      final cardType = json['cardType'] as String?;
      if (cardType != 'standard' && cardType != 'featured') {
        return null;
      }

      final slug = json['slug'] as String? ?? '';
      if (slug.isEmpty) {
        return null;
      }

      final endpoint = '/$slug';
      final imageUrl = json['imageUrl'] as String?;
      final title = json['title'] as String? ?? '';
      final subtitle = json['excerpt'] as String? ?? '';
      final readTime = json['readingTime'] as String? ?? '';
      final creator = json['creator'] as String? ?? '';
      
      // Parse publish date
      final publishedAt = json['publishedAt'] as String?;
      String publishDate = '';
      if (publishedAt != null && publishedAt.isNotEmpty) {
        try {
          final dateTime = DateTime.parse(publishedAt);
          // Format as "Mon DD, YYYY" or relative date
          final now = DateTime.now();
          final difference = now.difference(dateTime);
          
          if (difference.inDays == 0) {
            publishDate = 'Today';
          } else if (difference.inDays == 1) {
            publishDate = 'Yesterday';
          } else if (difference.inDays < 30) {
            publishDate = '${difference.inDays} days ago';
          } else {
            final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                           'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
            publishDate = '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}';
          }
        } catch (e) {
          publishDate = '';
        }
      }

      // Parse collection (topic)
      String? topic;
      String? authorImageUrl;
      final collection = json['collection'] as Map<String, dynamic>?;
      if (collection != null) {
        topic = collection['name'] as String?;
        authorImageUrl = collection['avatarId'] as String?;
        if (authorImageUrl != null && !authorImageUrl.startsWith('http')) {
          authorImageUrl = 'https://miro.medium.com/v2/resize:fill:48:48/$authorImageUrl';
        }
      }

      // Format read time
      String formattedReadTime = readTime.isNotEmpty ? '$readTime min read' : '';

      return Article(
        endpoint: endpoint,
        imageUrl: imageUrl,
        title: title,
        topic: topic,
        authorName: creator.isNotEmpty ? creator : null,
        authorImageUrl: authorImageUrl,
        readTime: formattedReadTime,
        publishDate: publishDate,
        subtitle: subtitle,
      );
    } catch (e) {
      return null;
    }
  }
}
