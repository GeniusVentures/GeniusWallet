import 'package:flutter/material.dart';
import 'package:genius_wallet/components/effects/gw_hoverable.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_decorations.dart';
import 'package:genius_wallet/theme/genius_wallet_gradient.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

/// One row of a "pick exactly one of these" list.
///
/// Promoted from `_TokenRow` (`token_selector_drawer.dart`, sketch 032-A1) by
/// sketch **068-A**, after the other three pickers were read: Select Network,
/// SDK Accounts and Your Accounts each hand-rolled their own row and **two of
/// them could not show you what was selected at all**. Select Network passed
/// `ListTile(selected: true)` with no theme behind it, which paints nothing,
/// and had its title colour commented out; Your Accounts painted the selected
/// row a flat `brandPrimaryStrong`, the one thing the app's accent rule
/// forbids. Token Selector is now the fourth consumer of its own row rather
/// than its only one.
///
/// **Selection is drawn three ways, and that is not belt-and-braces.**
/// Selection is a STATE, so WCAG 1.4.11 applies to it. Measured on the 156-A
/// drawer panel (#0C0E14): the gradient tint is **1.39:1** and the brand edge
/// **1.60:1** - the same finding sketch 156 made about a field's fill, pointed
/// at a row. Neither carries the state on its own. The check glyph at
/// `brandPrimaryStrong` measures **6.81:1** and carries it by itself. So the
/// tint and the edge are for the eye and the glyph is for the requirement;
/// removing the glyph would fail 1.4.11, and removing the tint would make the
/// list feel dead.
///
/// **The border is always present and usually transparent.** A row that gains
/// a 1px border on hover shifts its own contents by a pixel every time the
/// pointer crosses it.
class GWSelectRow extends StatelessWidget {
  const GWSelectRow({
    super.key,
    required this.leading,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.titleStyle,
    this.subtitleStyle,
    this.trailing,
    this.action,
    this.selected = false,
  });

  /// Usually a 36px avatar, chain icon or glyph. The row does not size it -
  /// call sites hand it something already the right size, exactly as
  /// `_TokenRow` did.
  final Widget leading;

  final String title;
  final String? subtitle;

  /// For a title that is an address rather than a name - the mono treatment the
  /// account drawers use. Null takes the row's own `bodySm`/w600.
  final TextStyle? titleStyle;

  /// Same escape hatch for the second line - the wallet picker's address wants
  /// the mono treatment where a token's symbol does not.
  final TextStyle? subtitleStyle;

  /// INFORMATION, drawn before the state glyph: a balance, a "watched" eye.
  final Widget? trailing;

  /// An ACTION, drawn after the state glyph and hard against the row's edge: a
  /// `MenuAnchor` overflow. Two slots rather than one because these belong on
  /// opposite sides of the check - reading a row goes context, then state, then
  /// what you can do about it.
  final Widget? action;

  final bool selected;
  final VoidCallback onTap;

  /// The REAL `brandCta` stops at low alpha, so selection and the gradient
  /// check below it are the same brand statement. Built here rather than added
  /// to `GeniusWalletGradient` - one consumer does not earn a shared token, and
  /// this widget IS that consumer now.
  static const LinearGradient _selectionTint = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0x2E0AD89C), Color(0x2E0AAEE6)],
  );

  @override
  Widget build(BuildContext context) {
    // Fail-soft read: registers the InheritedWidget dependency that forces this
    // row to rebuild on a live appearance toggle while the drawer stays open.
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();

    // Hover plumbing moved into `GWHoverable` (23-05); this widget held no
    // other state, so it is a `StatelessWidget` now.
    return GWHoverable(
      builder: (hovered) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusMd),
        child: Container(
          margin: const EdgeInsets.only(bottom: GeniusWalletConsts.space2),
          padding: const EdgeInsets.symmetric(
            horizontal: GeniusWalletConsts.space6,
            vertical: GeniusWalletConsts.space6,
          ),
          decoration: BoxDecoration(
            // Resting is transparent: a row painted the panel's own colour is
            // decoration nobody sees. Unselected hover is THE app-wide recipe
            // (sketch 044) - brand tint + brand hairline, no geometry.
            gradient: selected ? _selectionTint : null,
            color: selected
                ? null
                : (hovered ? GWDecorations.hoverFill : Colors.transparent),
            borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusMd),
            border: Border.all(
              color: selected || hovered
                  ? GWDecorations.hoverEdge
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              leading,
              const SizedBox(width: GeniusWalletConsts.space6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          titleStyle ??
                          GeniusWalletTypography.bodySm.copyWith(
                            color: gw.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            subtitleStyle ??
                            GeniusWalletTypography.labelMd.copyWith(
                              color: gw.textSecondary,
                            ),
                      ),
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: GeniusWalletConsts.space4),
                trailing!,
              ],
              if (selected) ...[
                const SizedBox(width: GeniusWalletConsts.space4),
                ShaderMask(
                  shaderCallback: (bounds) =>
                      GeniusWalletGradient.brandCta.createShader(bounds),
                  child: const Icon(
                    Icons.check_circle,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ],
              if (action != null) ...[
                const SizedBox(width: GeniusWalletConsts.space2),
                action!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
