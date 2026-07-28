// SHADOW FILE — do not migrate callers to this path without reading
// `.planning/phases/03-gw-component-library/03-SHADOW-NAMES.md` first.
//
// This file declares `class Loading extends StatelessWidget`, the exact same
// class name as `lib/components/loading.dart` (develop's canonical file,
// 18 importers). The two are different, non-interchangeable implementations
// at different import paths — this one uses Phase 2 tokens
// (GeniusWalletColors.brandGreen, GeniusWalletConsts.space8,
// GeniusWalletTypography.headlineLg); the canonical file uses raw values.
//
// `lib/components/loading.dart` remains the canonical file for all 18
// existing callers. Do not repoint any of them to this path. Migrating a
// caller to this path is a deliberate act that requires updating
// `.planning/phases/03-gw-component-library/03-SHADOW-NAMES.md` and
// re-running `tool/verify_additive_boundary.sh` in the same commit.
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class Loading extends StatelessWidget {
  final String? text;
  const Loading({super.key, this.text});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: GeniusWalletConsts.space8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        LoadingAnimationWidget.flickr(
          leftDotColor: GeniusWalletColors.brandGreen,
          rightDotColor: GeniusWalletColors.statusInfo,
          size: 50,
        ),
        AutoSizeText(text ?? "", style: GeniusWalletTypography.headlineLg),
      ],
    );
  }
}
