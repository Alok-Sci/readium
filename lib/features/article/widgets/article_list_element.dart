import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:readium/core/context_extension.dart';
import 'package:readium/shared/widgets/primary_text_button.dart';
import 'package:readium/shared/widgets/shimmer_network_image.dart';
import 'package:readium/core/sizedbox_extension.dart';
import 'package:url_launcher/url_launcher.dart';

class ArticleListElement extends StatelessWidget {
  const ArticleListElement({
    super.key,
    required this.title,
    required this.href,
    required this.imageUrl,
  });

  final String title;
  final String href;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final image = ShimmerNetworkImage(
      imageUrl,
      width: .8.sw,
      height: 100,
      fit: BoxFit.cover,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: context.colorScheme.tertiary,
        border: Border.all(color: context.colorScheme.tertiaryContainer),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          20.height,
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
            ),
            child: Text(
              title,
              style: context.textTheme.headlineSmall,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
            ),
            child: PrimaryTextButton(
              text: 'View List',
              onPressed: () {
                launchUrl(Uri.parse(href));
              },
            ),
          ),
          20.height,
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                flex: 3,
                child: image,
              ),
              5.width,
              Expanded(
                flex: 2,
                child: image,
              ),
              5.width,
              Expanded(
                flex: 1,
                child: image,
              ),
            ],
          )
        ],
      ),
    );
  }
}
