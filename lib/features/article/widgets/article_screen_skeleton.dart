import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:readium/shared/widgets/shimmer_box.dart';
import 'package:readium/shared/widgets/skeleton_box.dart';
import 'package:readium/core/sizedbox_extension.dart';

class ArticleScreenSkeleton extends StatelessWidget {
  const ArticleScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: NeverScrollableScrollPhysics(),
      child: ShimmerBox(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // title
              SkeletonBox(height: 40, width: 0.7.sw),
              25.height,

              // author meta
              Row(
                children: [
                  SkeletonBox(height: 45, width: 45, borderRadius: 100),
                  10.width,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBox(height: 16, width: 0.3.sw),
                      5.height,
                      SkeletonBox(height: 16, width: 0.2.sw),
                    ],
                  ),
                ],
              ),
              30.height,

              // paragraph 1
              SkeletonBox(height: 25, width: 0.85.sw),
              8.height,
              SkeletonBox(height: 25, width: 0.9.sw),
              8.height,
              SkeletonBox(height: 25, width: 0.6.sw),
              25.height,

              // paragraph 2
              SkeletonBox(height: 25, width: 0.85.sw),
              8.height,
              SkeletonBox(height: 25, width: 0.9.sw),
              8.height,
              SkeletonBox(height: 25, width: 0.95.sw),
              8.height,
              SkeletonBox(height: 25, width: 0.8.sw),
              8.height,
              SkeletonBox(height: 25, width: 0.6.sw),
              25.height,

              // paragraph 3
              SkeletonBox(height: 25, width: 0.85.sw),
              8.height,
              SkeletonBox(height: 25, width: 0.9.sw),
              8.height,
              SkeletonBox(height: 25, width: 0.6.sw),
              25.height,

              // paragraph 4
              SkeletonBox(height: 25, width: 0.85.sw),
              8.height,
              SkeletonBox(height: 25, width: 0.9.sw),
              8.height,
              SkeletonBox(height: 25, width: 0.95.sw),
              8.height,
              SkeletonBox(height: 25, width: 0.8.sw),
              8.height,
              SkeletonBox(height: 25, width: 0.6.sw),
              25.height,
            ],
          ),
        ),
      ),
    );
  }
}
