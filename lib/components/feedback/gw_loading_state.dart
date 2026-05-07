import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:shimmer/shimmer.dart';

class GWLoadingState extends StatelessWidget {
  const GWLoadingState({
    super.key,
    this.message,
  });

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 36,
            height: 36,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                GeniusWalletColors.brandGreen,
              ),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: GeniusWalletConsts.space6),
            Text(
              message!,
              style: GeniusWalletTypography.bodyMd.copyWith(
                color: GeniusWalletColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Shimmer skeleton box. Use for loading states that hint at the shape
/// of content to come (rows, balance figures, avatars).
class GWSkeleton extends StatelessWidget {
  const GWSkeleton({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.radius = GeniusWalletConsts.radiusSm,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: GeniusWalletColors.surfaceMenu,
      highlightColor: GeniusWalletColors.surfaceElevated,
      period: const Duration(milliseconds: 1200),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: GeniusWalletColors.surfaceMenu,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

/// Shimmer wrapper for any child widget. Use when you want to shimmer
/// a composed layout (e.g. a whole fake list row) instead of a single box.
class GWShimmerWrap extends StatelessWidget {
  const GWShimmerWrap({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: GeniusWalletColors.surfaceMenu,
      highlightColor: GeniusWalletColors.surfaceElevated,
      period: const Duration(milliseconds: 1200),
      child: child,
    );
  }
}
