import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:readium/core/utils/url_helper.dart';
import 'package:readium/infrastructure/freedium/models/feed_page_result.dart';
import 'package:readium/infrastructure/freedium/models/freedium_article.dart';
import 'package:readium/infrastructure/freedium/parsers/freedium_article_parser.dart';
import 'package:readium/infrastructure/freedium/parsers/freedium_home_parser.dart';
import 'package:readium/infrastructure/freedium/models/feed_card.dart';

/// Service for fetching and managing articles from Freedium
///
/// This service uses the readium_svelte_parser package to properly parse
/// SvelteKit __data.json responses from Freedium.
class FreediumService {
  final FreediumHomeParser _homeParser = FreediumHomeParser();
  final FreediumArticleParser _articleParser = FreediumArticleParser();

  /// Fetches the home feed with all articles
  ///
  /// Returns a [FeedPageResult] containing the main feed items,
  /// random items, and metadata.
  Future<FeedPageResult> fetchHomeFeed() async {
    try {
      final uri = Uri.parse('${UrlHelper.freediumBaseUrl}/__data.json');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final utfDecodedString = utf8.decode(response.bodyBytes);
        return _homeParser.parse(utfDecodedString);
      } else {
        throw ArticleServiceException(
          'Failed to load home feed',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ArticleServiceException) rethrow;
      throw ArticleServiceException('Error fetching home feed: $e');
    }
  }

  /// Fetches a list of article cards from the home feed
  ///
  /// Returns only the actual article cards, filtering out quote and stat cards.
  /// Suitable for displaying in a list or grid view.
  Future<List<ArticleFeedCard>> fetchArticleCards() async {
    try {
      final feedResult = await fetchHomeFeed();
      return feedResult.items.whereType<ArticleFeedCard>().toList();
    } catch (e) {
      if (e is ArticleServiceException) rethrow;
      throw ArticleServiceException('Error fetching article cards: $e');
    }
  }

  /// Fetches detailed data for a specific article
  ///
  /// [articlePath] should be the Medium article URL path segment
  /// Example: "fludev/the-repository-pattern-in-flutter-..."
  ///
  /// Returns a [FreediumArticle] with complete article metadata,
  /// HTML content, and markdown content.
  Future<FreediumArticle> fetchArticleDetail(String articlePath) async {
    try {
      final uri =
          Uri.parse('${UrlHelper.freediumBaseUrl}/$articlePath/__data.json');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        return _articleParser.parse(response.body);
      } else {
        throw ArticleServiceException(
          'Failed to load article',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ArticleServiceException) rethrow;
      throw ArticleServiceException('Error fetching article: $e');
    }
  }

  /// Fetches the HTML content of an article
  ///
  /// [articlePath] should be the Medium article URL path segment
  ///
  /// Returns the article content as HTML string.
  Future<String> fetchArticleHtml(String articlePath) async {
    try {
      final article = await fetchArticleDetail(articlePath);
      return article.html;
    } catch (e) {
      if (e is ArticleServiceException) rethrow;
      throw ArticleServiceException('Error fetching article HTML: $e');
    }
  }

  /// Fetches the markdown content of an article
  ///
  /// [articlePath] should be the Medium article URL path segment
  ///
  /// Returns the article content as markdown string.
  Future<String> fetchArticleMarkdown(String articlePath) async {
    try {
      final article = await fetchArticleDetail(articlePath);
      return article.markdown;
    } catch (e) {
      if (e is ArticleServiceException) rethrow;
      throw ArticleServiceException('Error fetching article markdown: $e');
    }
  }
}

/// Exception thrown when the article service encounters an error
class ArticleServiceException implements Exception {
  final String message;
  final int? statusCode;

  ArticleServiceException(this.message, {this.statusCode});

  @override
  String toString() {
    if (statusCode != null) {
      return 'ArticleServiceException: $message (Status: $statusCode)';
    }
    return 'ArticleServiceException: $message';
  }
}
