import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:readium/core/context_extension.dart';
import 'package:readium/features/article/models/article_data.dart';
import 'package:readium/infrastructure/freedium/sanitizers/markdown_html_sanitizer.dart';
import 'package:readium/shared/widgets/shimmer_network_image.dart';
import 'package:readium/core/sizedbox_extension.dart';
import 'package:readium/core/utils/date_util.dart';

class ArticleHeader extends StatelessWidget {
  final ArticleData article;
  final double? textScaleFactor;

  const ArticleHeader({
    required this.article,
    this.textScaleFactor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(textScaleFactor ?? 1.0),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Padding(
              padding: const EdgeInsets.only(
                top: 32.32,
                bottom: 0,
              ),
              child: Text(
                article.title,
                style: context.textTheme.displayLarge,
              ),
            ),
          ),
        ),

        // Subtitle
        if (article.subtitle != null)
          MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(textScaleFactor ?? 1.0),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 14.22,
                  bottom: 24,
                ),
                child: Text(
                  article.subtitle!,
                  style: context.textTheme.displaySmall,
                ),
              ),
            ),
          ),

        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text(
              '${article.readTime} · ${article.publishDate.toFormattedDate}',
              style: context.textTheme.labelMedium),
        ),
        const SizedBox(height: 12),
        // Author + meta
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              ShimmerNetworkImage(
                article.authorImageUrl!,
                width: 30,
                height: 30,
                borderRadius: 100,
                fit: BoxFit.cover,
              ),
              12.width,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.authorName,
                    style: context.textTheme.labelLarge,
                  ),
                ],
              ),
            ],
          ),
        ),

        // Cover image
        if (article.coverImageUrl != null) ...[
          Column(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 24, right: 24, top: 24),
                child: ShimmerNetworkImage(
                  width: 1.sw - 48,
                  article.coverImageUrl!,
                ),
              ),
              8.height,
              if (article.coverImageCaption != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: MarkdownBody(
                    data: MarkdownHtmlSanitizer.stripAnchorTags(
                        article.coverImageCaption!),
                    styleSheet: MarkdownStyleSheet(
                      p: context.textTheme.labelMedium,
                      a: context.textTheme.labelMedium?.copyWith(
                        decoration: TextDecoration.underline,
                        decorationColor: context.textTheme.labelMedium?.color,
                      ),
                    ),
                    shrinkWrap: true,
                    fitContent: true,
                  ),
                )
            ],
          ),
        ],
      ],
    );
  }
}
