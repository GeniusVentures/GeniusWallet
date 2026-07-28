import 'package:flutter/material.dart';
import 'package:genius_wallet/components/cards/gw_kicker.dart';
import 'package:genius_wallet/theme/genius_wallet_motion.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

/// Editorial "View all" text link (sketch 003-markets-panel, variant D).
///
/// A boxless, right-aligned trailing link for the shared [GWSectionTitle] slot:
/// small uppercase tracked label + a right-arrow. On hover (desktop) the label
/// and arrow are painted with the brand-CTA GRADIENT (the same gradient
/// language as the CTAs — not a flat brand tint), the arrow slides ~3px right,
/// and a thin brand-CTA gradient underline draws under the LABEL width only.
/// Lightest footprint — no background box. Reusable across panels.
///
/// Hover needs mutable state, hence StatefulWidget + [MouseRegion]. We use
/// [MouseRegion]+[GestureDetector] rather than [InkWell] on purpose: InkWell
/// paints a hover/splash box, which this "no background box" design forbids.
class GWViewAllLink extends StatefulWidget {
  const GWViewAllLink({
    super.key,
    required this.onTap,
    this.label = 'View all',
  });

  final VoidCallback onTap;
  final String label;

  @override
  State<GWViewAllLink> createState() => _GWViewAllLinkState();
}

class _GWViewAllLinkState extends State<GWViewAllLink> {
  bool _hovered = false;

  void _setHover(bool value) {
    if (_hovered != value) setState(() => _hovered = value);
  }

  @override
  Widget build(BuildContext context) {
    // Fail-soft read: registers the InheritedWidget dependency so the link
    // re-skins on a live appearance toggle (04-04 discipline).
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();

    // Children are drawn opaque white and recolored by the ShaderMask below:
    // a solid textSecondary at rest, the brand-CTA gradient on hover.
    //
    // Takes GWKicker's shared TYPE but not the widget (sketch 065): this link
    // owns hover, a sliding arrow and a gradient underline sized to the label,
    // none of which belong in a label component. Two properties are overridden
    // and both are load-bearing — `color: white` is what the ShaderMask needs
    // to recolour, and `height: 1.0` keeps the underline tight under the text.
    // The tracking DOES change here, 0.88 -> the dense step's 0.6, so the app
    // carries one value instead of two; the underline is drawn to the measured
    // label width, so it follows automatically.
    final labelStyle = GWKicker.style(gw, dense: true).copyWith(
      height: 1.0,
      color: Colors.white,
    );

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _setHover(true),
      onExit: (_) => _setHover(false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        // srcIn ShaderMask recolors the opaque-white children: brand-CTA
        // gradient on hover (matches the CTAs), a flat textSecondary gradient
        // at rest (so it reads as plain secondary text).
        child: ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) => LinearGradient(
            // Lights up to WHITE (textPrimary) on hover -- same "light up white"
            // language as the nav bar; not the brand gradient.
            colors: _hovered
                ? [gw.textPrimary, gw.textPrimary]
                : [gw.textSecondary, gw.textSecondary],
          ).createShader(bounds),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // IntrinsicWidth bounds the Column so CrossAxisAlignment.stretch
              // is legal (without it, stretch in this MainAxisSize.min Row gets
              // unbounded-width constraints and throws "RenderBox was not laid
              // out", blanking the whole panel). The stretch sizes the underline
              // to exactly the label width; the arrow lives outside the Column.
              IntrinsicWidth(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // No underline: on hover the label + arrow simply light up
                    // white (arrow slides). Boxless, underline-free link.
                    Text(widget.label.toUpperCase(), style: labelStyle),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              // Arrow slides ~3px right on hover (transform doesn't reserve
              // layout, so no reflow).
              AnimatedContainer(
                duration: GeniusWalletMotion.base,
                curve: GeniusWalletMotion.standard,
                transform:
                    Matrix4.translationValues(_hovered ? 3.0 : 0.0, 0.0, 0.0),
                child: const Icon(
                  Icons.arrow_right_alt,
                  size: 15,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
