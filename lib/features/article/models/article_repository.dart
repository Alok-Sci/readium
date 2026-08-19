import 'package:readium/core/utils/url_helper.dart';
import 'package:readium/features/article/models/article_data.dart';
import 'package:readium/infrastructure/freedium/freedium_service.dart';

class ArticleRepository {
  final FreediumService _freediumService = FreediumService();

  Future<ArticleData> loadFromMediumUrl(String mediumUrl) async {
    final uri = Uri.parse(mediumUrl);
    final articlePath =
        uri.path.startsWith('/') ? uri.path.substring(1) : uri.path;

    final article = await _freediumService.fetchArticleDetail(articlePath);
    if (article.error != null) {
      throw Exception('Article error: ${article.error}');
    }

    final metadata = article.metadata;
    final authorName =
        metadata.authors.isNotEmpty ? metadata.authors.first.name : null;
    final authorImageUrl =
        metadata.authors.isNotEmpty ? metadata.authors.first.avatarUrl : null;

    return ArticleData(
      originalUrl: mediumUrl,
      title: metadata.title,
      subtitle: metadata.subtitle,
      coverImageUrl:
          UrlHelper.absoluteMediumImageUrl(metadata.postImage, size: 500),
      coverImageCaption: metadata.postImageCaption,
      authorName: authorName!,
      authorImageUrl: UrlHelper.absoluteMediumImageUrl(authorImageUrl),
      readTime: metadata.readingTime,
      publishDate: metadata.publishedAt.toIso8601String(),
      tags: const [],
      markdownContent: article.markdown,
    );
  }
}
