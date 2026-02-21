import 'package:flutter/material.dart';
import 'package:readium/core/context_extension.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerBox extends StatelessWidget {
  final Widget child;
  const ShimmerBox({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.colorScheme.surface,
      highlightColor: context.colorScheme.background,
      child: child,
    );
  }
}
