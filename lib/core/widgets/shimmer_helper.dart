import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

extension ShimmerExtension on Widget {
  Widget withShimmerAi({
    required bool loading,
    double? width,
    double? height,
    BoxDecoration? decoration,
  }) {
    if (!loading) return this;

    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: decoration ??
            BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
        child: this,
      ),
    );
  }
}
