import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_context_extension.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

/// Canonical shared loading spinner — 19 importers (see
/// `.planning/phases/03-gw-component-library/03-SHADOW-NAMES.md`). Re-skinned
/// in place so every call site picks up the redesign with zero changes; the
/// same-named shadow at `lib/components/loading/loading.dart` stays dead code.
///
/// The dot colors are MODE-INVARIANT brand/status tokens, so they read from the
/// `GeniusWalletColors` static getters rather than the `GWColors` extension.
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
          leftDotColor: context.gw.brandGreen,
          rightDotColor: context.gw.statusInfo,
          size: 50,
        ),
        if (text != null) Text(text!, style: GeniusWalletTypography.headlineLg),
      ],
    );
  }
}
