import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_gradient.dart';
import 'package:genius_wallet/theme/genius_wallet_motion.dart';
import 'package:genius_wallet/theme/gw_context_extension.dart';

/// Signature floating swap action.
///
/// A circular brand-gradient FAB with the swap glyph. Used by
/// [GlobalSwapFabHost] to expose Swap from anywhere in the authenticated
/// app, mirroring the always-reachable swap of mobile-first wallets.
///
/// This is just the button — placement/visibility is the host's job.
class GWSwapFab extends StatefulWidget {
  const GWSwapFab({
    super.key,
    required this.onPressed,
    this.size = 56,
    this.tooltip = 'Swap',
  });

  final VoidCallback onPressed;
  final double size;
  final String tooltip;

  @override
  State<GWSwapFab> createState() => _GWSwapFabState();
}

class _GWSwapFabState extends State<GWSwapFab> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    // NOTE: no Tooltip here — this FAB is mounted at the MaterialApp.router
    // builder level (above the Navigator's Overlay), and Tooltip requires an
    // Overlay ancestor. Semantics already covers accessibility.
    return Semantics(
      label: widget.tooltip,
      button: true,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onPressed,
        child: AnimatedScale(
          // motion/fast — snappy tap feedback per §3.7.
          scale: _pressed ? 0.92 : 1.0,
          duration: GeniusWalletMotion.fast,
          curve: GeniusWalletMotion.standard,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              gradient: GeniusWalletGradient.brandCta,
              shape: BoxShape.circle,
              boxShadow: [
                // glow/gradient — dual brand glow lifted from the gnus.ai hero.
                BoxShadow(
                  color: context.gw.brandPrimary.withAlpha(64),
                  blurRadius: 24,
                  spreadRadius: -2,
                  offset: const Offset(-2, 6),
                ),
                BoxShadow(
                  color: context.gw.brandSecondary.withAlpha(64),
                  blurRadius: 24,
                  spreadRadius: -2,
                  offset: const Offset(2, 6),
                ),
              ],
            ),
            child: Icon(
              Icons.swap_vert_rounded,
              color: context.gw.textOnBrand,
              size: 26,
            ),
          ),
        ),
      ),
    );
  }
}
