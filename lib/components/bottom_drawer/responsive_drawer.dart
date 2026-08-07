import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/theme/gw_context_extension.dart';
import 'package:genius_wallet/utils/breakpoints.dart';

/// The drawer body's inset, owned by the SHELL rather than by each caller.
///
/// 20 on the sides and bottom, **24 on top** because the header hairline sits
/// directly above and at a flat 20 the first label read as glued to it. The
/// value is not new — it is `_SlippageForm`'s, the one drawer that got this
/// right, promoted to the shared default.
///
/// **This reverses a decision, deliberately.** 07-06 prohibited a blanket body
/// padding here on the grounds that some of the ~19 callers already pad
/// themselves. The prohibition held right up until a caller *forgot*: the
/// transaction receipt (`transaction_displays.dart`) pads vertically only, so
/// its labels touch the panel's left edge and its values slam the right one.
/// "Every caller remembers" is a rule with no enforcement, and it has now
/// measurably failed once with seventeen unwalked drawers behind it. The
/// default is the safe case; forgetting now produces a correct drawer.
///
/// Pass [EdgeInsets.zero] when the body owns a SCROLLING viewport — a long
/// picker's inset has to live on the `ListView` so it scrolls with the content
/// and the rows still reach the panel edge. That is the half of 07-06's
/// prohibition that was right, and it is why this is a parameter and not a
/// hardcoded `Padding`.
const EdgeInsets kDrawerBodyPadding = EdgeInsets.fromLTRB(
  GeniusWalletConsts.space10,
  GeniusWalletConsts.space12,
  GeniusWalletConsts.space10,
  GeniusWalletConsts.space10,
);

/// The footer's inset, owned by the SHELL for exactly the reason
/// [kDrawerBodyPadding] is: three callers padded their own footers and the rest
/// did not, so the transaction receipt's `View on Explorer` ran edge to edge
/// while Swap Settings' `Apply` sat correctly inset 20.
///
/// Unlike the body this takes no opt-out. A footer holds one or two actions; it
/// is never a scrolling viewport, so the case that forced the body's
/// `EdgeInsets.zero` escape hatch cannot arise here.
const EdgeInsets kDrawerFooterPadding = EdgeInsets.all(
  GeniusWalletConsts.space10,
);

/// The drawer panel is painted in THREE places -- the desktop `Container`, the
/// mobile sheet's `backgroundColor`, and the `Scaffold` inside both. Sketch
/// **156-A "Card canvas"** moved all three from `surfaceMenu` #171A21 to
/// `surfaceElevated` #0C0E14, which is Jakub's *"ciemniejsze, bardziej
/// kompatybilne z resztą"* taken literally: the drawer was the ONLY large
/// surface in the app at #171A21, roughly two steps lighter than anything it
/// ever opened over. It is now the same value as every card on the dashboard.
///
/// **The hairline is not decoration; it is the consequence.** Two near-blacks
/// cannot separate by fill -- the same arithmetic sketch 156 used to kill a
/// darker field also applies to the panel against the scrimmed page behind it:
///
/// | panel edge, against `black54` over the page (#050608) | contrast |
/// |---|---|
/// | old #171A21, no border | 1.16:1 |
/// | new #0C0E14, no border | **1.05:1** -- the silhouette dissolves |
/// | new #0C0E14 + **`borderSubtle` 12%** -- shipped | **1.30:1** |
/// | new #0C0E14 + `borderStrong` 24% | 2.01:1 |
///
/// So the panel takes a card's WHOLE recipe, fill and hairline, not half of it.
/// It first shipped at `borderStrong`, on the reasoning that 1.05 was the
/// number that had to move and 24% moved it furthest. **Jakub overruled that
/// on a live look (2026-07-28): use the swap boxes' border.** Those are
/// `GWCard`s at `borderSubtle` width 1, and if the drawer is a card then that
/// is its hairline - a heavier one makes it a card that is trying harder than
/// every other card on screen.
///
/// The cost is real and is accepted: **1.30:1, not 2.01:1**. A modal sheet is
/// identified by its scrim, its position and its content rather than by its
/// outline, so no WCAG threshold applies to it - this is a legibility call, and
/// it was made with the panel on screen rather than in a table.
///
/// **The FIELD edge is a different question and does not follow this.** It
/// stays at `context.gw.borderControl` (36%, 3.30:1), because a card's
/// border is decoration while an input's border is the only thing that says
/// "this is an input" - 1.4.11 applies to one and not the other.
///
/// Two knock-ons ride with the fill change, both already applied at their call
/// sites: an input's own fill goes UP to `surfaceMenu` (it becomes the lighter
/// object on a darker panel, which is how a control on a card reads everywhere
/// else in this app), and its edge goes to
/// `context.gw.borderControl` -- because at 1.11:1 the fill cannot
/// identify the field and the border has to carry 1.4.11 alone.
class ResponsiveDrawer {
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    List<Widget>? actions,
    Widget? footer,
    double desktopWidth = 420,
    bool useRootNavigator = true,
    bool isDismissible = true,
    bool enableDrag = true,
    EdgeInsetsGeometry bodyPadding = kDrawerBodyPadding,
  }) {
    final isDesktop =
        MediaQuery.sizeOf(context).width >= GeniusBreakpoints.medium;

    // Fail-soft read: resolved once at open-time (this is a static factory,
    // not a widget build()), used for the two Route/API-level color params
    // below (desktop panel decoration, mobile bottom-sheet backgroundColor).
    // These are captured once when show() is invoked -- the same structural
    // limitation as GWDialog.show()'s barrierColor -- while the LIVE flip
    // while the drawer stays open is carried by
    // _ResponsiveDrawerScaffold.build()'s own Theme dependency below.
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();

    final content = _ResponsiveDrawerScaffold(
      title: title,
      actions: actions,
      footer: footer,
      bodyPadding: bodyPadding,
      child: child,
    );

    if (isDesktop) {
      return showDialog<T>(
        context: context,
        barrierDismissible: isDismissible,
        barrierColor: Colors.black54,
        useRootNavigator: useRootNavigator,
        builder: (_) {
          return Align(
            alignment: Alignment.centerRight,
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: desktopWidth,
                height: double.infinity,
                // Sketch 156-A "Card canvas": `surfaceElevated`, the same value
                // as every card in the app. See the class doc for the panel/
                // scrim arithmetic that forces the hairline to come with it.
                decoration: BoxDecoration(
                  color: gw.surfaceElevated,
                  // The swap boxes' edge, literally: `swap_field.dart` builds a
                  // GWCard with `Border.all(color: gw.borderSubtle, width: 1)`
                  // on a `surfaceElevated` fill. Jakub, live 2026-07-28 -- the
                  // drawer is a card, so it wears a card's hairline, not a
                  // heavier one. See the class doc for what this costs.
                  border: Border.all(color: gw.borderSubtle, width: 1),
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(GeniusWalletConsts.radiusXl),
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: content,
              ),
            ),
          );
        },
      );
    }

    return showModalBottomSheet<T>(
      context: context,
      useRootNavigator: useRootNavigator,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      useSafeArea: true,
      isScrollControlled: true,
      // 156-A, mirroring the desktop branch: card fill, and the same hairline
      // for the same reason -- the sheet's top edge is the only thing that
      // separates it from the scrimmed page behind it.
      backgroundColor: gw.surfaceElevated,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: gw.borderSubtle, width: 1),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(GeniusWalletConsts.radiusXl),
        ),
      ),
      builder: (_) => content,
    );
  }
}

class _ResponsiveDrawerScaffold extends StatelessWidget {
  final Widget child;
  final String? title;
  final List<Widget>? actions;
  final Widget? footer;
  final EdgeInsetsGeometry bodyPadding;

  const _ResponsiveDrawerScaffold({
    required this.child,
    this.title,
    this.actions,
    this.footer,
    this.bodyPadding = kDrawerBodyPadding,
  });

  // Sketch 030-B1 "Quiet band" (.planning/sketches/030-drawer-shell,
  // drawers-final): the header is its own quiet zone.
  //
  // Was 48 to read "compact" against the old 56px-leading close button. With
  // that gone and the title at its specified 18px, 48 left the title crowded
  // between the panel's top edge and the hairline — the band stopped reading
  // as a zone and started reading as a strip. 56 gives the title the same
  // breathing room the body below it has -- which the shell now supplies
  // itself, see kDrawerBodyPadding.
  static const double _compactToolbarHeight = 56;

  /// The title's left edge.
  ///
  /// Material's default `titleSpacing` is 16 (`NavigationToolbar.kMiddleSpacing`)
  /// while the body is inset by `space10` (20) via [kDrawerBodyPadding], so
  /// the title sat 4px inside its own content's left edge — close enough to
  /// look like a mistake rather than a decision, which is exactly how it read
  /// on a live walk. Pinning it to the same token puts the two on one axis.
  static const double _titleInset = GeniusWalletConsts.space10;

  @override
  Widget build(BuildContext context) {
    // Fail-soft read: registers the InheritedWidget dependency that forces
    // this widget to rebuild on a live appearance toggle -- this is the
    // read that makes the LIVE drawer's own background genuinely flip while
    // the drawer stays open (this widget stays mounted for the drawer's
    // lifetime in both the desktop and mobile branches of
    // ResponsiveDrawer.show()).
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    return Scaffold(
      // 156-A. This is the third of the three panel paints and the one that is
      // actually visible behind the content -- the two in `show()` only cover
      // the corners this Scaffold does not reach.
      backgroundColor: gw.surfaceElevated,

      // Native Material app bar -- sketch 030-B1 "Quiet band": left-aligned
      // title, a small close ✕ at TOP-RIGHT (replacing the old big
      // 56px-wide leading close), a faint 1px brand hairline under the
      // header, compact toolbar height. Body inset is the shell's too now --
      // see kDrawerBodyPadding for why 07-06's prohibition was reversed and
      // which half of it survived as the `EdgeInsets.zero` opt-out.
      appBar: title != null
          ? AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: false,
              toolbarHeight: _compactToolbarHeight,
              titleSpacing: _titleInset,
              title: Text(
                title!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                // 18px/w600 is what 030-B1 "Quiet band" specified; the shell
                // shipped `titleMedium` (16/w500) and nobody re-measured it
                // against the sketch. Still ellipsizing — long coin names are
                // why the title was made smaller in the first place, and that
                // constraint has not gone away.
                style: GeniusWalletTypography.titleLg.copyWith(
                  color: gw.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              // No leading close well anymore (was a 56px-wide leading slot
              // holding a padded 48px IconButton) -- leading is fully
              // cleared so the title starts flush left.
              leading: null,
              // Close ✕ moves into actions, top-right, small and AFTER any
              // caller-supplied actions so it coexists with them rather than
              // replacing them.
              actions: [
                ...?actions,
                // The ✕ sits on the SAME axis as the title, measured glyph to
                // glyph: the title starts `_titleInset` (20) from the left, so
                // the icon ends 20 from the right. Walk finding 2026-07-27 --
                // with `padding: EdgeInsets.zero` and 36x36 constraints the box
                // sat flush to the panel edge and its hover circle bled over it.
                //
                // Why 6 and not the 12 the arithmetic suggests (20 minus the
                // glyph's 8-per-side inset in a 36 box): `AppBar` contributes
                // its own 6 to the actions slot. That is measured, not assumed,
                // and it is pinned by the close-button case in
                // `responsive_drawer_body_padding_test.dart` -- if a Flutter
                // upgrade changes it, that test fails instead of the ✕ drifting.
                Padding(
                  padding: const EdgeInsets.only(
                    right: GeniusWalletConsts.space3,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    iconSize: 20,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                    tooltip: MaterialLocalizations.of(
                      context,
                    ).closeButtonTooltip,
                    onPressed: Navigator.of(context).pop,
                  ),
                ),
              ],
              // Faint 1px brand-primary-subtle hairline under the header
              // (030-B1). Decorative separator only -- not a WCAG 1.4.11
              // graphical-object (it carries no information on its own,
              // mirroring the existing gw.borderSubtle hairlines elsewhere
              // in the codebase) -- reads faint-but-visible as a translucent
              // overlay on both the dark and light surfaceMenu canvases.
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(
                  height: 1,
                  color: context.gw.brandPrimarySubtle,
                ),
              ),
            )
          : null,

      // Content decides its own scrolling; the shell decides its inset.
      // `EdgeInsets.zero` is the opt-out for bodies that own a scrolling
      // viewport -- see kDrawerBodyPadding.
      body: Padding(padding: bodyPadding, child: child),

      // Native Material footer area
      // The footer's inset AND its top rule are the shell's, not each
      // caller's -- 030-B1 specified "footer with a top border" and exactly one
      // of the callers implemented it. See kDrawerFooterPadding.
      bottomNavigationBar: footer != null ? _buildFooter(context, gw) : null,
    );
  }

  /// The footer band: the shell's inset, its top rule, and a CAPPED share of
  /// the bottom safe-area inset.
  ///
  /// **2026-08-07: this used to be a `SafeArea(top: false)` and that was a
  /// measured defect.** The footer paid the bottom inset twice over. The mobile
  /// route opens with `showModalBottomSheet(useSafeArea: true)`, which resolves
  /// to `SafeArea(bottom: false, ...)` in the pinned SDK
  /// (`material/bottom_sheet.dart`) - so it neither consumes the bottom padding
  /// nor strips it from the MediaQuery, and the full 34pt of Jakub's iPhone
  /// passed straight through to this SafeArea, which then consumed all of it on
  /// top of [kDrawerFooterPadding]'s 20. Result: 20 above the button and 54
  /// below it, a 2.7 to 1 asymmetry under a single hollow button. Reported live
  /// on 2026-08-07 as "jakis taki duzy padding od spodu".
  ///
  /// The replacement is the pattern `_MobileTabBar` already ships
  /// (`responsive_overlay.dart`): read `viewPaddingOf` explicitly, cap it at
  /// [kMaxBottomSafeInset], and ADD the result to the design inset. 20 + at
  /// most 20 gives 40 below, recovering 14pt. This is the SUM, matching the tab
  /// bar's arithmetic that Jakub already approved on the device.
  ///
  /// The alternative is the MAX of the two, giving a symmetric 20 above and 20
  /// below and recovering 34pt. It is a legitimate variant and it is the named
  /// fallback if the band still reads bottom heavy on device - it is a
  /// one-line change from here. Recorded rather than argued: the sum ships
  /// first because it is the arithmetic already validated in this app.
  ///
  /// `viewPaddingOf` rather than `paddingOf` (which is viewPadding minus
  /// viewInsets) for the same reason the tab bar uses it: with the keyboard
  /// closed the two are identical, and this one keeps the footer stable instead
  /// of collapsing to 0 if a keyboard ever opens beneath it.
  ///
  /// One thing the wrapper did that is deliberately NOT replaced: a `SafeArea`
  /// also removes the consumed padding from its descendants' MediaQuery.
  /// Nothing in any of the 12 current footers reads it, which was checked - but
  /// the next author should know the wrapper had two jobs and only one of them
  /// came back.
  Widget _buildFooter(BuildContext context, GWColors gw) {
    final rawInset = MediaQuery.viewPaddingOf(context).bottom;
    final bottomInset = rawInset > kMaxBottomSafeInset
        ? kMaxBottomSafeInset
        : rawInset;

    return Container(
      padding: kDrawerFooterPadding.copyWith(
        bottom: kDrawerFooterPadding.bottom + bottomInset,
      ),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: gw.borderSubtle)),
      ),
      child: footer!,
    );
  }
}
