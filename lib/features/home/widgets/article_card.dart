import 'package:flutter/material.dart';
import 'package:readium/core/context_extension.dart';
import 'package:readium/core/helpers/article_helpers.dart';
import 'package:readium/core/utils/app_assets.dart';
import 'package:readium/shared/widgets/shimmer_network_image.dart';
import 'package:readium/core/sizedbox_extension.dart';
import '../models/article.dart';

class ArticleCard extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;

  const ArticleCard({super.key, required this.article, required this.onTap});

  String get _displayAuthor {
    if (article.authorName != null) {
      return article.authorName!;
    } else if (article.authorName != null) {
      return article.authorName!;
    }
    return 'Unknown Author';
  }

  String? get _authorImageUrl {
    if (article.authorImageUrl != null) {
      return article.authorImageUrl;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Author info row
            Row(
              children: [
                if (_authorImageUrl != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: ShimmerNetworkImage(
                      _authorImageUrl!,
                      width: 24,
                      height: 24,
                      fit: BoxFit.cover,
                    ),
                  ),
                  8.width,
                ],
                Expanded(
                  child: Text(
                    _displayAuthor,
                    style: context.textTheme.labelMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            // Main content row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Article content
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      12.height,

                      // Title
                      Text(
                        article.title,
                        style: context.textTheme.headlineMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      8.height,

                      // Subtitle
                      if (article.subtitle.isNotEmpty)
                        Text(
                          article.subtitle,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.colorScheme.onSurface.withValues(
                              alpha: 0.7,
                            ),
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      12.height,
                    ],
                  ),
                ),
                16.width,

                // Cover image
                if (article.imageUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: ShimmerNetworkImage(
                      article.imageUrl!,
                      width: 80,
                      height: 50,
                      fit: BoxFit.cover,
                      borderRadius: 1,
                    ),
                  ),
              ],
            ),

            // Bottom metadata row
            Row(
              children: [
                if (article.isMemberOnly) ...[
                  Image.asset(AppAssets.star, height: 18),
                  8.width,
                ],
                Text(article.publishDate, style: context.textTheme.labelMedium),
                const Spacer(),

                // Share button
                IconButton(
                  icon: Image.asset(
                    AppAssets.share,
                    color: context.colorScheme.secondary,
                    height: 24,
                    width: 24,
                  ),
                  tooltip: 'Share',
                  onPressed: () =>
                      handleShareArticle(article.title, article.fullUrl),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
