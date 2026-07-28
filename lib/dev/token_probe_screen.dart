import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_decorations.dart';
import 'package:genius_wallet/theme/genius_wallet_gradient.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_appearance.dart';

/// Dev-only probe surface (UI-SPEC §9). Proves the new token layer resolves
/// at runtime and flips live with [GWAppearance] — without touching, or being
/// touched by, any un-ported screen. Reachable only through the `Tokens`
/// button inside [DevToolsWidget] (`kDebugMode && kShowDevTools`).
///
/// This is a probe, not a gallery — the full primitive gallery is DS-03
/// (Phase 3). Deliberately does not instantiate the dormant canvas-background
/// decoration widget from `genius_wallet_decorations.dart`: its noise-texture
/// asset is not bundled until Phase 3 / DS-04.
class TokenProbeScreen extends StatefulWidget {
  const TokenProbeScreen({super.key});

  @override
  State<TokenProbeScreen> createState() => _TokenProbeScreenState();
}

class _TokenProbeScreenState extends State<TokenProbeScreen> {
  @override
  void initState() {
    super.initState();
    // Exercises the `preferences` Hive box (plan 02-01) and restores the
    // persisted appearance mode, so re-entering the probe proves the
    // load()/setMode() round-trip rather than just the in-memory flip.
    GWAppearance.instance.load();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<GWAppearanceMode>(
      valueListenable: GWAppearance.instance,
      builder: (context, mode, _) {
        final isLight = GWAppearance.isLight;
        return Scaffold(
          backgroundColor: GeniusWalletColors.surfaceBase,
          appBar: AppBar(
            backgroundColor: GeniusWalletColors.surfaceBase,
            elevation: 0,
            title: Text(
              'Design tokens',
              style: GeniusWalletTypography.headlineLg,
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(GeniusWalletConsts.space10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Design tokens', style: GeniusWalletTypography.headlineLg),
                const SizedBox(height: GeniusWalletConsts.space6),
                Text(
                  'This probe renders the new typography, surface decoration, '
                  'brand CTA gradient, spacing and radius tokens. It proves '
                  'the token layer resolves and flips at runtime, without '
                  'touching any un-ported screen.',
                  style: GeniusWalletTypography.bodyMd,
                ),
                const SizedBox(height: GeniusWalletConsts.space12),
                Container(
                  padding: const EdgeInsets.all(GeniusWalletConsts.space8),
                  decoration: GWDecorations.surface(
                    radius: GeniusWalletConsts.radius2xl,
                  ),
                  child: Text(
                    'Card surface — GWDecorations.surface() with radius2xl',
                    style: GeniusWalletTypography.bodyMd,
                  ),
                ),
                const SizedBox(height: GeniusWalletConsts.space12),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: GeniusWalletConsts.space12,
                      vertical: GeniusWalletConsts.space6,
                    ),
                    decoration: BoxDecoration(
                      gradient: GeniusWalletGradient.brandCta,
                      borderRadius: BorderRadius.circular(
                        GeniusWalletConsts.radiusPill,
                      ),
                    ),
                    child: Text(
                      'Brand CTA',
                      style: GeniusWalletTypography.titleMd.copyWith(
                        color: GeniusWalletColors.textOnBrand,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: GeniusWalletConsts.space16),
                OutlinedButton(
                  onPressed: () {
                    GWAppearance.instance.setMode(
                      isLight ? GWAppearanceMode.dark : GWAppearanceMode.light,
                    );
                  },
                  child: Text(isLight ? 'Dark' : 'Light'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
