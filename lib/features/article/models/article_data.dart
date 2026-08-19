import 'package:readium/features/article/models/article_tag.dart';

class ArticleData {
  final String originalUrl;
  final String title;
  final String? subtitle;
  final String? coverImageUrl;
  final String? coverImageCaption;
  final String authorName;
  final String? authorImageUrl;
  final String readTime;
  final String publishDate;
  final List<ArticleTag> tags;
  final String? markdownContent; // markdown version of the content

  ArticleData({
    required this.originalUrl,
    required this.title,
    this.subtitle,
    this.coverImageUrl,
    this.coverImageCaption,
    required this.authorName,
    this.authorImageUrl,
    required this.readTime,
    required this.publishDate,
    this.tags = const [],
    this.markdownContent,
  });
}
