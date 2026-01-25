import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:readium/shared/widgets/shimmer_box.dart';
import 'package:readium/shared/widgets/skeleton_box.dart';
import 'package:readium/core/sizedbox_extension.dart';

class ArticleListTileSkeleton extends StatelessWidget {
  const ArticleListTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerBox(
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBox(height: 21, width: 0.3.sw),
              9.height,
              SkeletonBox(height: 25, width: 0.6.sw),
              5.height,
              SkeletonBox(height: 25, width: 0.6.sw),
              5.height,
              SkeletonBox(height: 25, width: 0.4.sw),
            ],
          ),
          22.width,
          Expanded(child: SkeletonBox(height: 55, width: 0.20.sw)),
        ],
      ),
    );
  }
}
