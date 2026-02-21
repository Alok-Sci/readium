import 'package:flutter/material.dart';
import 'package:readium/core/context_extension.dart';
import 'package:readium/core/helpers/article_helpers.dart';
import 'package:readium/core/helpers/datetime_helper.dart';
import 'package:readium/core/utils/app_assets.dart';
import 'package:readium/shared/widgets/shimmer_network_image.dart';
import 'package:readium/core/sizedbox_extension.dart';

class ArticleHistoryTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String authorName;
  final String authorImageUrl;
  final String readTime;
  final String publishDate;
  final String? coverImageUrl;
  final bool isMemberOnly;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  final DateTime? readAt;
  final String originalUrl;

  const ArticleHistoryTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.authorName,
    required this.authorImageUrl,
    required this.readTime,
    required this.publishDate,
    this.coverImageUrl,
    required this.isMemberOnly,
    required this.onTap,
    required this.onRemove,
    this.readAt,
    required this.originalUrl,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: ShimmerNetworkImage(
                    authorImageUrl,
                    width: 24,
                    height: 24,
                    fit: BoxFit.cover,
                  ),
                ),
                8.width,
                Expanded(
                  child: Text(
                    authorName,
                    style: context.textTheme.labelMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Article content
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Author info
                      12.height,

                      // Title
                      Text(
                        title,
                        style: context.textTheme.headlineMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      8.height,

                      // Subtitle
                      Text(
                        subtitle,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colorScheme.onSurface.withOpacity(0.7),
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      12.height,

                      // Read time and publish date
                    ],
                  ),
                ),
                16.width,
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: ShimmerNetworkImage(
                    coverImageUrl!,
                    width: 80,
                    height: 50,
                    fit: BoxFit.cover,
                    borderRadius: 1,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                if (isMemberOnly) ...[
                  Image.asset(AppAssets.star, height: 18),
                  8.width,
                ],
                Text(publishDate, style: context.textTheme.labelMedium),
                Spacer(),
                // Text(
                //   readTime,
                //   style: context.textTheme.labelMedium,
                // )
                if (readAt != null) ...[
                  4.width,
                  Text(
                    formatReadTime(readAt!),
                    style: context.textTheme.labelMedium,
                  ),
                ],
                SizedBox(width: 5),

                IconButton(
                  icon: Image.asset(
                    AppAssets.delete,
                    color: context.colorScheme.secondary,
                    height: 24,
                    width: 24,
                  ),
                  tooltip: 'Remove from history',
                  onPressed: onRemove,
                ),
                PopupMenuButton<String>(
                  icon: Image.asset(
                    AppAssets.more,
                    color: context.colorScheme.secondary,
                    height: 24,
                    width: 24,
                  ),
                  tooltip: 'More',
                  onSelected: (String value) {
                    switch (value) {
                      case 'open_medium':
                        handleOpenInMedium(originalUrl);
                        break;
                      case 'share':
                        handleShareArticle(title, originalUrl);
                        break;
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem<String>(
                      value: 'open_medium',
                      child: Row(
                        children: [
                          Image.asset(
                            AppAssets.redirect,
                            height: 20,
                            width: 20,
                            color: context.colorScheme.primary,
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Open in medium',
                            style: context.textTheme.labelLarge,
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'share',
                      child: Row(
                        children: [
                          Image.asset(
                            AppAssets.share,
                            height: 20,
                            width: 20,
                            color: context.colorScheme.primary,
                          ),
                          SizedBox(width: 12),
                          Text('Share', style: context.textTheme.labelLarge),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
