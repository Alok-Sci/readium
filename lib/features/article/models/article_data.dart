import 'package:readium/features/article/models/article_tag.dart';

class ArticleData {
  final String originalUrl;
  final String title;
  final String subtitle;
  final String? coverImageUrl;
  final String authorName;
  final String authorImageUrl;
  final String readTime;
  final String publishDate;
  final List<ArticleTag> tags;
  final String cleanedBodyHtml; // ready to feed into flutter_html

  ArticleData({
    required this.originalUrl,
    required this.title,
    required this.subtitle,
    required this.coverImageUrl,
    required this.authorName,
    required this.authorImageUrl,
    required this.readTime,
    required this.publishDate,
    required this.tags,
    required this.cleanedBodyHtml,
  });
}
