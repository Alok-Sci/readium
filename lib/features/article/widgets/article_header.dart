import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:readium/core/context_extension.dart';
import 'package:readium/features/article/models/article_data.dart';
import 'package:readium/features/article/widgets/member_only_story_chip.dart';
import 'package:readium/shared/widgets/primary_text_button.dart';
import 'package:readium/shared/widgets/shimmer_network_image.dart';
import 'package:readium/core/sizedbox_extension.dart';
import 'package:url_launcher/url_launcher.dart';

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
        // Member only story
        if (article.isMemberOnly) MemberOnlyStoryChip(),

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
                bottom: 0, // -
              ), // title margins [file:1]
              child: Text(
                article.title,
                style: context.textTheme.displayLarge,
              ),
            ),
          ),
        ),

        // Subtitle
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
              ), // subtitle margins [file:1]
              child: Text(
                article.subtitle,
                style: context.textTheme.displaySmall,
              ),
            ),
          ),
        ),

        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text('${article.readTime} · ${article.publishDate}',
              style: context.textTheme.labelMedium),
        ),
        const SizedBox(height: 12),
        // Author + meta
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              ShimmerNetworkImage(
                article.authorImageUrl,
                width: 30,
                height: 30,
                borderRadius: 100,
              ),
              12.width, // gap [file:1]
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.authorName,
                    style: context.textTheme.labelLarge,
                  ),
                ],
              ),
              12.width, // gap [file:1]

              // follow button
              PrimaryTextButton(
                text: "Follow",
                onPressed: () {
                  launchUrl(Uri.parse(article.authorUrl));
                },
              )
            ],
          ),
        ),

        // Cover image
        if (article.coverImageUrl != null) ...[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Padding(
              padding: const EdgeInsets.only(
                top: 40,
              ), // image margin-top [file:1]
              child: Row(
                children: [
                  Expanded(
                    child: ShimmerNetworkImage(
                      width: 1.sw - 48,
                      height: 0.4.sh,
                      article.coverImageUrl!,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
