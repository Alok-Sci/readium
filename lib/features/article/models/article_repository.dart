// article_repository.dart
import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:readium/core/utils/html_cleaner.dart';
import 'package:readium/core/utils/html_entity_decoder.dart';
import 'package:readium/core/utils/url_helper.dart';
import 'package:readium/features/article/models/article_data.dart';
import 'package:readium/features/article/models/article_metadata_extractor.dart';

class ArticleRepository {
  /// Load article from Medium URL via Freedium mirror
  Future<ArticleData> loadFromMediumUrl(String mediumUrl) async {
    final freediumUrl = UrlHelper.buildFreediumUrl(mediumUrl);
    log('Fetching article from: $freediumUrl');

    final response = await http.get(Uri.parse(freediumUrl));
    if (response.statusCode != 200) {
      throw Exception('Failed to load Freedium page: ${response.statusCode}');
    }

    // Force UTF-8 decoding to handle special characters correctly
    final htmlContent = utf8.decode(response.bodyBytes);
    final document = html_parser.parse(htmlContent);
    final article = document.querySelector('article');
    
    if (article == null) {
      throw Exception('Article tag not found in HTML');
    }

    // Clean unwanted elements
    HtmlCleaner.cleanArticle(article);

    // Extract metadata (also removes header and cover from DOM)
    final metadata = ArticleMetadataExtractor.extract(article);

    // Get HTML string
    final rawHtml = article.innerHtml;
    
    // Decode HTML entities in the string itself
    // (flutter_html re-parses, so decoding DOM nodes doesn't work)
    final cleanedHtml = HtmlEntityDecoder.decodeHtmlString(rawHtml);

    return ArticleData(
      originalUrl: mediumUrl,
      title: metadata.title,
      subtitle: metadata.subtitle,
      coverImageUrl: metadata.coverImageUrl,
      authorName: metadata.authorName,
      authorImageUrl: metadata.authorImageUrl,
      readTime: metadata.readTime,
      publishDate: metadata.publishDate,
      tags: metadata.tags,
      cleanedBodyHtml: cleanedHtml,
    );
  }
}
