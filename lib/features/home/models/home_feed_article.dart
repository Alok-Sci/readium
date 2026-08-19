import 'package:readium/core/utils/url_helper.dart';

class HomeFeedArticle {
  final String endpoint;
  final String? imageUrl;
  final String title;
  final String subtitle;
  final String? topic;
  final String authorName;
  final String? authorImageUrl;
  final String readTime;
  final String publishDate;

  HomeFeedArticle({
    required this.endpoint,
    this.imageUrl,
    required this.title,
    this.topic,
    required this.subtitle,
    required this.authorName,
    this.authorImageUrl,
    required this.readTime,
    required this.publishDate,
  });

  String get absoluteImageUrl => UrlHelper.absoluteMediumImageUrl(imageUrl, size: 300) ?? "";
  String get absoluteAuthorImageUrl => UrlHelper.absoluteMediumImageUrl(authorImageUrl, size: 50) ?? "";
  String get fullUrl => '${UrlHelper.freediumBaseUrl}$endpoint';
}
