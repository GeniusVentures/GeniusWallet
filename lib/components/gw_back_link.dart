import 'package:flutter/material.dart';
import 'package:genius_wallet/components/cards/gw_kicker.dart';
import 'package:genius_wallet/components/effects/gw_hoverable.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

/// "‹ MARKETS" — the app's one breadcrumb-style way back, promoted out of
/// `token_info_screen.dart`'s private `_BackToMarkets` (2026-07-31, at
/// Jakub's direction while porting `/buy` into the shell) so a second page
/// that needs the identical link is not a hand-rolled copy of the first.
///
/// **Sketch 165 Synthesis, change 1 (Jakub, 2026-07-30): no chip.** This used
/// to be a `‹ Markets` pill — a `BoxDecoration` with a 999-radius border, a
/// `borderSubtle` hairline at rest and `GWDecorations.hoverFill` on hover,
/// padded `space6`/`space3`. None of that survives here either: at rest this
/// draws no border, no fill and no rounded box, and hovering only lifts the
/// text and chevron colour — the element never changes size under the
/// cursor. [label] carries `GWKicker.style(dense: true)` (11px/w600/0.6
/// tracking) rather than the `GWKicker` widget itself, because it is
/// interactive and owns its own hover state — exactly the case
/// `gw_kicker.dart` names as staying its own widget.
///
/// **Deliberately NOT pre-uppercased here.** `GWKicker`'s own doc forbids a
/// caller pre-calling `toUpperCase()` on ITS `label` parameter — but that rule
/// is about callers of the WIDGET, and this one only borrows the static
/// style. [label] is rendered exactly as given, so a caller decides its own
/// casing (every call site today passes it already upper-cased, matching the
/// original `_BackToMarkets` recipe byte for byte).
///
/// **[onTap] is the "destination", expressed as a callback rather than a bare
/// route string.** The one call site this was promoted from uses
/// `context.pop()` — go_router's own "back in the route stack" call, not a
/// fixed path — and a caller reached from more than one entry point (as the
/// Buy GNUS page is) has no single fixed destination to hardcode anyway.
/// Passing the action instead of a path keeps that flexibility rather than
/// forcing every consumer into one navigation shape.
class GWBackLink extends StatelessWidget {
  const GWBackLink({super.key, required this.label, required this.onTap});

  /// The destination name shown after the chevron, e.g. `'MARKETS'`.
  final String label;

  /// What tapping the link does — the "destination". Typically
  /// `() => context.pop()`.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    // Hover plumbing lives in `GWHoverable` (23-05); this widget holds no
    // other state, so it stays a `StatelessWidget`.
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          12,
          0,
          12,
          GeniusWalletConsts.space4,
        ),
        child: GWHoverable(
          builder: (hovered) => GestureDetector(
            onTap: onTap,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.chevron_left,
                  size: 16,
                  color: hovered ? gw.textPrimary : gw.textSecondary,
                ),
                const SizedBox(width: GeniusWalletConsts.space3),
                Text(
                  label,
                  style: GWKicker.style(gw, dense: true).copyWith(
                    color: hovered ? gw.textPrimary : gw.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
