import 'package:flutter/material.dart';
import 'package:genius_wallet/components/cards/gw_kicker.dart';
import 'package:genius_wallet/components/effects/gw_hoverable.dart';
import 'package:genius_wallet/theme/genius_wallet_motion.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

/// Editorial "View all" text link (sketch 003-markets-panel, variant D).
///
/// A boxless, right-aligned trailing link for the shared [GWSectionTitle] slot:
/// a small uppercase tracked label plus a right-arrow. No background box, no
/// border, and no underline anywhere in this widget - the lightest footprint a
/// link can have. Reusable across panels; three render today (Assets, Markets,
/// Transactions), all of them inside a `DashboardScrollContainer`.
///
/// ## What it paints
///
/// [gradient] is the single place that decides, and it decides both states:
///
/// ```
/// rest    flat gw.textSecondary  (#8A8F9D)
/// hover   flat gw.textPrimary    (white), and the arrow slides 3px right
/// ```
///
/// Both states hand `LinearGradient` ONE colour repeated, so neither blends.
/// The `ShaderMask` below is a recolouring device for the opaque-white
/// children, not a decoration, and it is the only paint path in the widget.
///
/// ## Contrast, measured on `surfaceElevated` (`#0C0E14` dark)
///
/// All three render sites paint on `DashboardScrollContainer`, whose
/// `GWDecorations.surface` resolves to `surfaceElevated`. One surface, so one
/// contrast answer covers the whole census. The bar is 4.5:1 (this is text):
///
/// ```
/// rest    textSecondary #8A8F9D   5.97:1
/// hover   textPrimary   white    19.29:1
/// ```
///
/// 5.97 clears AA and does not reach AAA's 7:1. AA is the bar here, and this
/// is the colour that shipped for months.
///
/// ## The 2026-08-07 round trip, recorded so there is not a third
///
/// For part of 2026-08-07 the rest state painted the brand CTA blend instead
/// of grey. The argument was sound and is worth keeping on the record: iOS has
/// no hover, so on the actual target device REST is the only state that ever
/// renders, and a link at `textSecondary` is permanently the dimmest thing in
/// every panel row it lives in.
///
/// Jakub saw it on the phone the same day and chose consistency across the
/// three dashboard sections over the extra emphasis: take `View all` back to
/// the old grey it used to be. Colour is therefore DECIDED. If
/// the link ever reads too quiet, the next lever is weight or size, not
/// colour.
///
/// One claim that lived in this file during that round trip is falsified by
/// the revert and must not survive it: brand-blend TEXT was described as this
/// app's general mark for a navigational affordance. With these three links
/// flat, the only such text left on the dashboard is the bottom-bar ACTIVE
/// TAB, which marks where you already are rather than leading anywhere - so it
/// is not a general mark for anything, and this file must not describe it as
/// one.
///
/// ## Hover plumbing
///
/// Hover needs mutable state and [GWHoverable] (23-05) supplies it, so this
/// widget holds none and is stateless. [GWHoverable] uses [MouseRegion] +
/// [GestureDetector] rather than [InkWell] on purpose: InkWell paints a
/// hover/splash box, which this "no background box" design forbids.
class GWViewAllLink extends StatelessWidget {
  const GWViewAllLink({
    super.key,
    required this.onTap,
    this.label = 'View all',
  });

  final VoidCallback onTap;
  final String label;

  /// The shader colours for one state, exposed as a public static so exactly
  /// one place decides paint and a test can assert the STOPS rather than
  /// pixel-reading an opaque `Shader`. `GWKicker.style(gw, dense:)` is the
  /// precedent for lifting a styling decision out of a build method this way.
  ///
  /// Both states return one colour repeated. That is the honest shape of a
  /// flat fill expressed through the `ShaderMask` this widget already owns:
  /// the revert to grey did not remove a paint path, it collapsed one.
  ///
  /// The colours are read off [GWColors], never hard-coded, so the link
  /// re-skins with the appearance rather than needing a light-mode branch of
  /// its own. `gw_view_all_link_paint_test.dart` asserts that in both
  /// appearances.
  static LinearGradient gradient(GWColors gw, {required bool hovered}) =>
      hovered
      ? LinearGradient(colors: <Color>[gw.textPrimary, gw.textPrimary])
      : LinearGradient(colors: <Color>[gw.textSecondary, gw.textSecondary]);

  @override
  Widget build(BuildContext context) {
    // Fail-soft read: registers the InheritedWidget dependency so the link
    // re-skins on a live appearance toggle (04-04 discipline).
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();

    // Takes GWKicker's shared TYPE but not the widget (sketch 065): this link
    // owns hover and a sliding arrow, neither of which belongs in a label
    // component. Two properties are overridden: `color: white` is load-bearing,
    // it is what the ShaderMask below has to recolour, and `height: 1.0` keeps
    // the label's line box tight to the text so the link does not inflate the
    // title row it sits in. The tracking DOES change here, 0.88 -> the dense
    // step's 0.6, so the app carries one value instead of two.
    final labelStyle = GWKicker.style(
      gw,
      dense: true,
    ).copyWith(height: 1.0, color: Colors.white);

    return GWHoverable(
      cursor: SystemMouseCursors.click,
      builder: (hovered) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        // One srcIn ShaderMask recolours the opaque-white children. It asks
        // `gradient` for the colours and decides nothing itself. See the class
        // doc for which state paints what.
        child: ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) =>
              gradient(gw, hovered: hovered).createShader(bounds),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // RESIDUE, kept deliberately: the IntrinsicWidth + stretched
              // Column existed to size a rule to the label width. Variant D
              // shipped without any such rule and the file's class doc
              // described one for months anyway. The scaffolding is inert and
              // height-neutral around a single Text, so it is left standing
              // rather than removed inside a colour change - the title rows it
              // sits in are height-capped and asserted, and this task has no
              // business moving them. If it is ever removed, do it as its own
              // change with `dashboard_section_caps_test.dart` green either
              // side. (The IntrinsicWidth is not optional while the Column is
              // here: stretch inside a MainAxisSize.min Row gets unbounded
              // width constraints and throws "RenderBox was not laid out",
              // blanking the whole panel.)
              IntrinsicWidth(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [Text(label.toUpperCase(), style: labelStyle)],
                ),
              ),
              const SizedBox(width: 6),
              // Arrow slides ~3px right on hover (transform doesn't reserve
              // layout, so no reflow). It is the second half of the hover
              // state, and on iOS it is the half that never renders - which is
              // the observation that started the 2026-08-07 round trip.
              AnimatedContainer(
                duration: GeniusWalletMotion.base,
                curve: GeniusWalletMotion.standard,
                transform: Matrix4.translationValues(
                  hovered ? 3.0 : 0.0,
                  0.0,
                  0.0,
                ),
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
