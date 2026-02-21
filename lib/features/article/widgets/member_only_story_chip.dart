import 'package:flutter/material.dart';
import 'package:readium/core/context_extension.dart';
import 'package:readium/core/sizedbox_extension.dart';
import 'package:readium/core/utils/app_assets.dart';

class MemberOnlyStoryChip extends StatelessWidget {
  const MemberOnlyStoryChip({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(width: 1, color: context.colorScheme.tertiary),
        borderRadius: BorderRadius.circular(8),
      ),
      margin: EdgeInsets.symmetric(horizontal: 24),
      padding: EdgeInsets.only(left: 8, right: 10, top: 4, bottom: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(AppAssets.star, height: 18),
          5.width,
          Text(
            "Member-only story",
            style: context.textTheme.labelMedium!.copyWith(),
          ),
        ],
      ),
    );
  }
}
