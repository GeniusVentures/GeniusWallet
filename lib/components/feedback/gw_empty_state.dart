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

  // ponytail: the base threshold (192) assumes the title+message shape, so a
  // hypothetical title-only call site sitting in a 160-192px slot would go
  // compact without needing to — harmless, and no current call site renders
  // `GWEmptyState` without a message today. When `actionLabel`/`onAction` are
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
          _compactLayoutHeight +
                  (hasAction ? _compactActionBlockHeight : 0) <
              compactHeightThreshold,
          'compact metrics (including the action block when present) must '
          'stay smaller than the threshold that selects them, or switching '
          'to compact cannot relieve the overflow it exists to prevent',
        );

        final double iconBox = isCompact ? _iconBoxCompact : _iconBoxFull;
        final double iconGlyph =
            isCompact ? _iconGlyphCompact : _iconGlyphFull;
        final double outerPadding = isCompact
            ? GeniusWalletConsts.space6
            : GeniusWalletConsts.space12;
        final double iconToTitleGap = isCompact
            ? GeniusWalletConsts.space4
            : GeniusWalletConsts.space8;
        final double titleToMessageGap = isCompact
            ? GeniusWalletConsts.space2
            : GeniusWalletConsts.space4;

        return Center(
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
                  child: Icon(
                    icon,
                    size: iconGlyph,
                    color: gw.textSecondary,
                  ),
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
      },
    );
  }
}
