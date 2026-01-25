import 'package:flutter/material.dart';
import 'package:readium/core/context_extension.dart';
import 'package:readium/features/article/models/article_tag.dart';

class ArticleTagWidget extends StatelessWidget {
  final ArticleTag tag;
  const ArticleTagWidget(
    this.tag, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: context.textTheme.labelSmall!.backgroundColor,
          border: Border.all(
            width: 1,
            color: context.textTheme.labelSmall!.backgroundColor!,
          ),
          borderRadius: BorderRadius.circular(100)),
      margin: EdgeInsets.only(right: 8, top: 8),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Text(
        tag.title,
        style: context.textTheme.labelMedium!.copyWith(
          color: context.textTheme.labelSmall!.color,
        ),
      ),
    );
  }
}
