import 'package:flutter/material.dart';
import 'package:readium/core/context_extension.dart';
import 'package:readium/core/helpers/article_helpers.dart';
import 'package:readium/core/utils/app_assets.dart';
import 'package:readium/shared/widgets/shimmer_network_image.dart';
import 'package:readium/core/sizedbox_extension.dart';
import '../models/home_feed_article.dart';

class HomeFeedArticleCard extends StatelessWidget {
  final HomeFeedArticle article;
  final VoidCallback onTap;

  const HomeFeedArticleCard({
    super.key,
    required this.article,
    required this.onTap,
  });

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
                if (article.absoluteAuthorImageUrl.isNotEmpty) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: ShimmerNetworkImage(
                      article.absoluteAuthorImageUrl,
                      width: 24,
                      height: 24,
                      fit: BoxFit.cover,
                    ),
                  ),
                  8.width,
                ],
                Expanded(
                  child: Text(
                    article.authorName,
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
                            color: context.colorScheme.onSurface.withValues(alpha: 0.7),
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
                if (article.absoluteImageUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: ShimmerNetworkImage(
                      article.absoluteImageUrl,
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
                Text(
                  article.publishDate,
                  style: context.textTheme.labelMedium,
                ),
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
                  onPressed: () => handleShareArticle(article.title, article.fullUrl),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
