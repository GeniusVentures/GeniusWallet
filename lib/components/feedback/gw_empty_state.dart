import 'package:flutter/material.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_decorations.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

class GWEmptyState extends StatelessWidget {
  const GWEmptyState({
    super.key,
    this.icon = Icons.inbox_outlined,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  // Full-size metrics — today's values, extracted from the inline literals so
  // each reads next to its compact counterpart below.
  static const double _iconBoxFull = 72;
  static const double _iconGlyphFull = 32;

  // Compact metrics — used only when the incoming slot is height-bounded and
  // below `_compactHeightThreshold`.
  static const double _iconBoxCompact = 48;
  static const double _iconGlyphCompact = 24;

  // The height the FULL layout needs at its minimum for the tightest shape
  // any call site uses (1-line title + 1-line message):
  //   space12 padding (top+bottom) + 72 circle + space8 + 24px titleLg line
  //   + space4 + 24px bodyMd line
  //   = 24+24 + 72 + 16 + 24 + 8 + 24 = 192
  // Below this the Column cannot fit and RenderFlex overflows.
  static const double _compactHeightThreshold = 192;

  // The WORST-CASE compact height, with the message at its bounded two-line
  // maximum:
  //   space6 padding (top+bottom) + 48 circle + space4 + 24 title + space2
  //   + 48 of message (2 lines)
  //   = 12+12 + 48 + 8 + 24 + 4 + 48 = 156
  static const double _compactLayoutHeight = 156;

  // The action block's cost in the FULL layout: the action-button gap reuses
  // `iconToTitleGap`, which is space8 when not compact, plus the button's own
  // height. Read from `GWButton._height` for `GWButtonSize.md`
  // (gw_button.dart:77-87) — the default size, and the one this widget's
  // `GWButton(...)` call uses (no `size:` override) — rather than assumed:
  //   space8 + 48 = 16 + 48 = 64
  static const double _actionButtonHeight = 48; // GWButtonSize.md height
  static const double _actionBlockHeight =
      GeniusWalletConsts.space8 + _actionButtonHeight; // 16 + 48 = 64

  // The action block's cost in the COMPACT layout: the action-button gap
  // reuses `iconToTitleGap`, which is space4 when compact — compact does NOT
  // shrink the button itself, so the height term is unchanged:
  //   space4 + 48 = 8 + 48 = 56
  static const double _compactActionBlockHeight =
      GeniusWalletConsts.space4 + _actionButtonHeight; // 8 + 48 = 56

  // How far this widget will search for the vertical middle of its slot.
  //
  // THE RULE (sketch 021 §3, locked in sketch 022): centre within the slot,
  // but never search more than 480px for the middle. Sketch 020 measured the
  // bare `Center` this replaced: in the ~1400px `/transactions` slot the icon
  // landed ~650px down with ~260px of visible void above and below — below
  // the fold on a laptop. Sketch 021 rejected both hand-picked offsets
  // (topCenter + space16, topCenter + space32) because a fixed offset is
  // wrong at every height except the one it was picked at. This is a RULE, so
  // a slot shorter than 480 renders byte-identically to what shipped before.
  //
  // It is a FIXED LITERAL, deliberately — not a fraction of the incoming
  // height. A proportional anchor (`maxHeight * 0.35`) would derive a
  // dimension continuously from constraints, which is the exact class of
  // thing commit `37639d5` banned after it froze the macOS app: a distinct
  // value per frame thrashes skia's fixed-size caches and layout never
  // settles. 480 is one number and `isHeightBounded` below is a bool — both
  // bounded sets. Guard: `test/chart/compact_price_font_size_test.dart`.
  static const double _anchorSearchHeight = 480;

  // ponytail: the base threshold (192) assumes the title+message shape, so a
  // title-only call site sitting in a 160-192px slot goes compact without
  // strictly needing to — harmless, and it is a REAL case, not a
  // hypothetical: `dashboard_screen.dart:491` renders
  // `GWEmptyState(title: "No market data available")` with no message, no
  // icon override and no action, in a ~114px Markets card. That card is far
  // below 192 either way, so the compact tier already handles it correctly;
  // only the shape assumption is loose, and tightening the threshold
  // arithmetic to match would buy nothing. When `actionLabel`/`onAction` are
  // set, the effective threshold below adds `_actionBlockHeight` so an
  // action-bearing instance in the ~192-256px band correctly stays FULL
  // instead of false-negatively skipping compact (the false-negative case a
  // fixed 192 threshold missed — see the deviation note in the plan summary).
  // The real remaining ceiling: compact mode does NOT shrink the action
  // button itself — `GWButton` stays at its `GWButtonSize.md` height (48px)
  // in both branches — so an action-bearing empty state below roughly 212px
  // (`_compactLayoutHeight + _compactActionBlockHeight`) still cannot fit
  // even in compact, and there is no third, button-shrinking tier. The
  // layout pops between full and compact at the boundary rather than
  // shrinking continuously. Upgrade path for all of this: derive the
  // required height from the actual children with a TextPainter (and, for
  // the button, consider `GWButtonSize.sm`) instead of fixed constants.

  @override
  Widget build(BuildContext context) {
    // Fail-soft read: registers the InheritedWidget dependency that forces
    // this const-instanced widget to rebuild on a live appearance toggle.
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isHeightBounded = constraints.maxHeight != double.infinity;
        final bool hasAction = actionLabel != null && onAction != null;
        // Shape-aware threshold: an action-bearing instance also needs room
        // for the action block, or a bounded slot in the ~192-256px band
        // would pick the full layout (isCompact false) while still needing
        // 256px — a false negative that silently reopens the overflow this
        // guard exists to prevent.
        final double compactHeightThreshold =
            _compactHeightThreshold + (hasAction ? _actionBlockHeight : 0);
        final bool isCompact =
            isHeightBounded && constraints.maxHeight < compactHeightThreshold;

        // Pure constant/instance-field relation — cannot fire at runtime for
        // any real layout (it never reads `constraints`), only for a future
        // edit that breaks the design invariant, in either the title+message
        // shape or the action-bearing shape.
        assert(
          _compactLayoutHeight + (hasAction ? _compactActionBlockHeight : 0) <
              compactHeightThreshold,
          'compact metrics (including the action block when present) must '
          'stay smaller than the threshold that selects them, or switching '
          'to compact cannot relieve the overflow it exists to prevent',
        );

        // Same property as the assert above — constant-only, so it can never
        // fire for a real layout, only for a future edit that breaks the
        // design invariant. This one states in code what the anchor comment
        // argues in prose: the cap only BINDS above 480 while compact only
        // fires below 192 (256 with an action), so there is no slot height at
        // which the cap could become the thing selecting the layout.
        assert(
          _anchorSearchHeight > compactHeightThreshold,
          'the anchor search height must stay clear of the threshold that '
          'selects the compact tier, or the cap could become the thing '
          'choosing the layout instead of the real slot height',
        );

        final double iconBox = isCompact ? _iconBoxCompact : _iconBoxFull;
        final double iconGlyph = isCompact ? _iconGlyphCompact : _iconGlyphFull;
        final double outerPadding = isCompact
            ? GeniusWalletConsts.space6
            : GeniusWalletConsts.space12;
        final double iconToTitleGap = isCompact
            ? GeniusWalletConsts.space4
            : GeniusWalletConsts.space8;
        final double titleToMessageGap = isCompact
            ? GeniusWalletConsts.space2
            : GeniusWalletConsts.space4;

        final Widget centred = Center(
          child: Padding(
            padding: EdgeInsets.all(outerPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: iconBox,
                  height: iconBox,
                  decoration: BoxDecoration(
                    gradient: GWDecorations.surfaceSheen,
                    shape: BoxShape.circle,
                    border: Border.all(color: gw.borderSubtle),
                  ),
                  child: Icon(icon, size: iconGlyph, color: gw.textSecondary),
                ),
                SizedBox(height: iconToTitleGap),
                Text(
                  title,
                  style: GeniusWalletTypography.titleLg,
                  textAlign: TextAlign.center,
                  maxLines: isCompact ? 1 : null,
                  overflow: isCompact ? TextOverflow.ellipsis : null,
                ),
                if (message != null) ...[
                  SizedBox(height: titleToMessageGap),
                  Text(
                    message!,
                    style: GeniusWalletTypography.bodyMd.copyWith(
                      color: gw.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: isCompact ? 2 : null,
                    overflow: isCompact ? TextOverflow.ellipsis : null,
                  ),
                ],
                if (hasAction) ...[
                  SizedBox(height: iconToTitleGap),
                  GWButton(
                    label: actionLabel,
                    onPressed: onAction,
                    variant: GWButtonVariant.secondary,
                  ),
                ],
              ],
            ),
          ),
        );

        // UNBOUNDED slot — the design gallery (`design_gallery_screen.dart:757`
        // sits in a `Column(crossAxisAlignment: stretch)`). Today's tree,
        // returned unchanged, and this guard is the entire reason the branch
        // exists: `Align`/`ConstrainedBox` under an infinite height would hand
        // the inner `Center` a BOUNDED 0..480, `Center` would then take the
        // largest allowed size, and this widget would inflate from its ~192px
        // content to exactly 480 — growing a 288px void in the gallery
        // (measured, by dropping this line). `isHeightBounded` is the same
        // flag the compact decision above reads: one source of truth for
        // "is this slot real".
        if (!isHeightBounded) {
          return centred;
        }

        // BOUNDED slot. Read inner-to-outer, because that is the non-obvious
        // part: `centred` centres the block inside whatever height it is
        // given; the `ConstrainedBox` caps that height at 480; the outer
        // `Align` pins the capped box to the top of the real slot. In a slot
        // SHORTER than 480 the cap does not bind, the box fills the slot, and
        // the result is exactly the plain `Center` this widget shipped with —
        // which is why nothing regresses where the layout is already fine.
        //
        // On the compact interaction, because a reviewer will ask: the
        // `ConstrainedBox` sits INSIDE the `LayoutBuilder`, so
        // `constraints.maxHeight` — the value `isCompact` is computed from —
        // is untouched by the cap. Compact selection reads the REAL slot
        // height exactly as it did before. And the two ranges cannot overlap:
        // compact fires below 192 (256 with an action) while the cap only
        // binds above 480, so no slot exists in which the cap could push a
        // full layout into compact or hold a compact layout out of it. The
        // second assert above says so in code.
        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: _anchorSearchHeight),
            child: centred,
          ),
        );
      },
    );
  }
}
