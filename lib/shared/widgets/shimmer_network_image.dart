import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:readium/core/context_extension.dart';
import 'package:readium/shared/widgets/shimmer_box.dart';
import 'package:readium/shared/widgets/skeleton_box.dart';

class ShimmerNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double width;
  final double height;
  final double borderRadius;
  final BoxFit fit;
  const ShimmerNetworkImage(
    this.imageUrl, {
    required this.width,
    required this.height,
    this.borderRadius = 0,
    this.fit = BoxFit.contain,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      imageBuilder: (context, imageProvider) => SizedBox(
        width: width,
        height: height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            image: DecorationImage(
              image: imageProvider,
              fit: fit,
            ),
          ),
        ),
      ),
      placeholder: (context, url) => ShimmerBox(
        child: SkeletonBox(
          width: width,
          height: height,
          borderRadius: borderRadius,
        ),
      ),
      errorWidget: (context, url, error) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          color: context.colorScheme.secondary,
        ),
        child: const Icon(Icons.broken_image_outlined, size: 12),
      ),
    );
  }
}
