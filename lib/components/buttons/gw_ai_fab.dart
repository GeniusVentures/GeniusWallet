import 'package:flutter/material.dart';
import 'package:genius_wallet/ai/ai_processing_status.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_decorations.dart';
import 'package:genius_wallet/theme/genius_wallet_elevation.dart';
import 'package:genius_wallet/theme/genius_wallet_motion.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';

/// AI-processing floating action — the bottom-left mirror of the Swap FAB.
///
/// A surface-style circle (so it reads as informational, distinct from the
/// brand-gradient Swap CTA) carrying a faint brain glyph with the live
/// 0–100% counter in its centre and a purple ([GeniusWalletColors
/// .brandTertiary] = the AI accent) progress ring. Listens to
/// [AiProcessingStatus.instance]; placement/visibility is the host's job.
class GWAiFab extends StatefulWidget {
  const GWAiFab({
    super.key,
    required this.onPressed,
    this.size = 56,
  });

  final VoidCallback onPressed;
  final double size;

  @override
  State<GWAiFab> createState() => _GWAiFabState();
}

class _GWAiFabState extends State<GWAiFab> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    // NOTE: no Tooltip here — mounted above the Navigator's Overlay (same
    // constraint as GWSwapFab). Semantics covers accessibility.
    return ValueListenableBuilder<int>(
      valueListenable: AiProcessingStatus.instance,
      builder: (context, percent, _) => Semantics(
        label: 'AI processing $percent%',
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
                gradient: GWDecorations.surfaceSheen,
                shape: BoxShape.circle,
                border: Border.all(
                    color: GeniusWalletColors.borderSubtle, width: 1),
                boxShadow: [
                  ...GeniusWalletElevation.card,
                  // Purple AI glow — the tertiary accent, so the FAB is
                  // clearly not the (mint) Swap action.
                  BoxShadow(
                    color: GeniusWalletColors.brandTertiary.withAlpha(56),
                    blurRadius: 20,
                    spreadRadius: -2,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: widget.size - 9,
                    height: widget.size - 9,
                    child: CircularProgressIndicator(
                      value: percent / 100,
                      strokeWidth: 2.5,
                      strokeCap: StrokeCap.round,
                      color: GeniusWalletColors.brandTertiary,
                      backgroundColor: GeniusWalletColors.textPrimary12,
                    ),
                  ),
                  // Faint brain behind the counter.
                  Icon(
                    Icons.psychology_outlined,
                    size: 26,
                    color: GeniusWalletColors.brandTertiary.withAlpha(82),
                  ),
                  Text(
                    '$percent%',
                    style: GeniusWalletTypography.numericBody.copyWith(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: GeniusWalletColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
