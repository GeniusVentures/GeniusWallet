import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/account/account_drawer.dart';
import 'package:genius_wallet/components/overlay/more_sheet.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';

/// The side of both header controls, in logical pixels. Public so the tests
/// assert against the same number the widgets use rather than a literal
/// typed twice, which is the rule `kWalletPillMaxWidth` set before it was
/// deleted. 44 is Apple's minimum target and is on the 4-pt grid (4 x 11).
const double kHeaderControlSize = 44;

/// The phone header: the brand at top-left, and TWO controls at the right.
///
/// Sketch 180 scheme B for the header itself, then sketch 183 scheme F for the
/// right side, both picked by Jakub on 2026-08-07. What this header is for,
/// stated once: **whose wallet, on which chain, and the ways in.**
///
/// It replaces a header that carried TWO controls answering ONE question - an
/// `InkWell` wallet block in `AppBar.title` on the LEFT plus a
/// `NetworkDropdownSelector` alone in `actions`. That widget is no longer
/// mounted anywhere in the phone shell; its desktop mount in the control
/// track is untouched.
///
/// Scheme F then replaced the 223.94px wallet pill with a fixed 100.00px
/// cluster: a 44 x 44 wallet chip, `space6`, and a bare 44 x 44 hamburger. The
/// hamburger exists because sketch 182 scheme S7 took the `More` slot off the
/// bottom bar in the same change, and Markets, Web, Feedback and Settings
/// reach the phone through the sheet it opens.
class MobileHeader extends StatelessWidget implements PreferredSizeWidget {
  const MobileHeader({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();

    // 24-07 FIX: a real `AppBar`, not a hand-rolled Container.
    //
    // The Container version rendered UNDER the notch. `Scaffold` reserves
    // `preferredSize.height + MediaQuery.padding.top` for whatever it is given
    // in the appBar slot, but it does NOT inset the child -- `AppBar` does that
    // itself, and by not using one I skipped it. Jakub saw the content start at
    // the very top edge of the phone.
    //
    // `AppBar` also brings the Material ancestor the InkWell below wants, the
    // elevation/scroll behaviour every other screen already has, and
    // `toolbarHeight` for the 60 this used to hard-code.
    return AppBar(
      backgroundColor: gw.surfaceElevated,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: 60,
      automaticallyImplyLeading: false,
      // FROZEN, 2026-08-07, and this is the one line most likely to be
      // helpfully "fixed" by the next reader. Jakub asked twice for the brand
      // to move left and the pill to move right, then judged the alignment
      // correct on device and withdrew both: "ok logo zostaw jest dobrze
      // alignowane, ale zrob to wieksze", narrowed again to "rob po prostu to
      // logo i nazwe wieksza na chwile obecne, wallet i alignemnt zostaw,
      // ocenimy po zmianach".
      //
      // So the lockup GREW that day and nothing else moved: this
      // `titleSpacing`, the `actions` inset below and the mark-to-wordmark gap
      // are all unchanged. Growing the brand cannot disturb them either - see
      // the width budget in [BrandLockup] - and the pill's position is a
      // deferred question, not an oversight.
      titleSpacing: GeniusWalletConsts.space8,
      // borderStrong at 1px, up from borderSubtle at 0.5px: 1.34:1 becomes
      // 2.11:1, and the painted area doubles from 1.5 physical px at 3x to 3.
      //
      // A brand block anchoring the top-left turns this bar into a band, and a
      // band with no edge floats. No SURFACE swap can supply that edge: the
      // two candidates are 1.01:1 (surfaceElevated vs surfaceBase) and 1.12:1
      // (surfaceMenu vs surfaceBase), and no two dark surface tokens in this
      // palette separate by even 1.2:1. Only a line can.
      //
      // Not borderControl, which would reach 3.30:1: that token's own doc
      // reserves it for the edge of a control whose fill cannot identify it,
      // and states that decorative separators stay subtle. A bar's bottom edge
      // carries no information about a component's state. borderControl goes
      // on the pill instead, where it is load-bearing.
      shape: Border(bottom: BorderSide(color: gw.borderStrong, width: 1)),
      // Only the right inset, and it stays exactly this. The F cluster
      // deliberately does NOT live in `actions`: `AppBar` lays actions out at
      // their intrinsic size and gives the REMAINDER to `title`, so a cluster
      // in `actions` would drop the title Row from 342.00 to 246.00 and make
      // the BRAND the thing that shrinks under Dynamic Type, which is
      // backwards. Both controls stay in `title` and this line does not move.
      actions: const [SizedBox(width: GeniusWalletConsts.space8)],
      // Both blocks live in `title` so the shrink priority is expressed in
      // layout rather than asserted in a comment: the brand is intrinsic and
      // non-flex, and the `Expanded` holds the right-hand cluster. The cluster
      // is a FIXED 100.00 and non-flex itself, which is the one thing scheme F
      // changed about this arrangement - the pill it replaced absorbed shrink
      // by ellipsizing a name, and there is no name left to ellipsize. The
      // wordmark cap below is what keeps the `Expanded` from starving; see
      // [BrandLockup]. `GNUS.AI` truncating to `GNUS...` would read as broken,
      // and it still cannot happen.
      //
      // Hamburger OUTERMOST, which is the order Jakub asked for on 2026-08-07:
      // "ikonke walletu ... i obok tego hamburger menu".
      title: const Row(
        children: [
          BrandLockup(),
          SizedBox(width: GeniusWalletConsts.space6),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                WalletPill(),
                // EXACTLY ONE space6 inside the cluster. Sketch 183's "If F
                // ships" table reads "space6 to its right", which looks like a
                // second spacer; its own held-constant table pins the cluster
                // at 100.00 (44 + 12 + 44) and the free space at 135.94, both
                // of which require one gap. A trailing spacer would make it 112
                // and contradict every number the sketch measures.
                SizedBox(width: GeniusWalletConsts.space6),
                HeaderMenuButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The mark plus the wordmark, top-left. NOT interactive, and it must not
/// become so: a second tappable object in this bar reopens the exact "two
/// controls" complaint this header exists to close.
///
/// The wordmark is live TEXT, not `logo_and_title.png`. That image bakes the
/// same string but has no @2x or @3x variant anywhere in `lib/assets/images/`,
/// so it would be upscaled and soft; live text is crisp at any density,
/// respects Dynamic Type, and is read as text by a screen reader. Roughly
/// three quarters of this lockup's width therefore has no asset-resolution
/// problem at all.
///
/// Public rather than private so a test can measure its width directly. The
/// assertion that this width is IDENTICAL under a 4-character wallet name and
/// a 60-character one is the single most valuable one in the header's test
/// file, and it is font-independent, which matters because the test font is
/// not Inter.
class BrandLockup extends StatelessWidget {
  const BrandLockup({super.key});

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // The crop, and why the number is 29/38.
        //
        // `geniusappbarlogo.png` is a 38x38 canvas whose OPAQUE glyph occupies
        // only x[1..28]: 1px of transparent margin on the left and 9px on the
        // right, measured by walking the alpha channel. Rendered raw at
        // height 24 the box is 24 wide but the visible mark is 17.7 and sits
        // hard against the left, so a nominal 8px gap renders as roughly
        // 13.7px of visible air. That is not subtle, and it is why the DESKTOP
        // bar carries a hand-computed `SizedBox(width: 15)` to compensate.
        //
        // Cropping instead of compensating keeps the gap token honest: 29/38
        // keeps exactly one column of the left margin and drops the right
        // gutter, so the box is 18.3 wide and `space4` is a real 8.
        ClipRect(
          child: Align(
            alignment: Alignment.centerLeft,
            widthFactor: 29 / 38,
            child: Image.asset(
              'assets/images/geniusappbarlogo.png',
              // The declared package name and the on-disk path differ on
              // purpose: pubspec declares assets under
              // `packages/genius_wallet/assets/images/`, which resolves to
              // `lib/assets/images/`. This is the form all four existing call
              // sites use, the desktop app bar included.
              package: 'genius_wallet',
              // 28, up from 24 on 2026-08-07, and 28 is the CEILING this asset
              // supports rather than a taste call.
              //
              // There is no high-density variant in the repo - no 2.0x or 3.0x
              // directory exists for any asset - so on a 3x iPhone the mark is
              // drawn from a 38px source and upscaled:
              //
              //   24 (before)  ->  72 physical px  ->  1.89x
              //   28 (here)    ->  84 physical px  ->  2.21x
              //   32           ->  96 physical px  ->  2.53x
              //   36           -> 108 physical px  ->  2.84x
              //
              // The mark is an intricate line drawing, so a 1-source-pixel
              // stroke renders with no hard edge at all. Below roughly 2.5x
              // that reads as antialiasing; at and above it, it reads as blur.
              // 28 is therefore the last step before the artefact becomes the
              // thing you notice, and it is the largest size worth drawing
              // from THIS file.
              //
              // SUPERSEDED, kept because it was a real argument and not a
              // mistake: 24 was also chosen to leave the pill's 32px avatar the
              // largest circular object in the bar, so the wallet control
              // stayed dominant. Jakub overruled the premise by asking for a
              // bigger brand. The ordering it protected happens to survive
              // anyway - at 28 the 32px avatar is still the larger circle.
              //
              // THE UPGRADE, named so it is one step to pick up: re-export
              // `lib/assets/images/geniusappbarlogo.png` at 114x114 (3x of 38),
              // same path and same filename. It is a pure drop-in, because the
              // render height is fixed here in code and the crop above is a
              // `widthFactor`, so no layout number changes. At 114 the mark is
              // lossless up to `height: 38`, which is what unlocks 32 and 36 if
              // 28 still reads too small.
              height: 28,
              excludeFromSemantics: true,
            ),
          ),
        ),
        // UNCHANGED at `space4`, and it stays a true 8 after the size change:
        // the crop above drops the source's right gutter, so the mark's own
        // left ink margin is one source column, `28/38` = 0.74px at H=28
        // (it was 0.63px at H=24). The brand's left ink edge therefore moves
        // right by 0.11px, which is why "the alignment is frozen" survives a
        // size change literally and not merely in spirit.
        //
        // Growing this to `space6` would widen the lockup by 4 more and push
        // the pill slack below to -0.06. Named as the one-token step if the
        // lockup ever reads cramped; not taken.
        const SizedBox(width: GeniusWalletConsts.space4),
        // THE WIDTH BUDGET AT 390pt, MEASURED. It is written down because the
        // obvious model of it is wrong, and was wrong in this file's planning
        // once already.
        //
        //   mark box   29/38 * 28                    =  21.37
        //   gap        space4                        =   8.00
        //   GNUS.AI    Inter Bold 18                 =  76.69
        //   lockup                                   = 106.06
        //
        // That much is exact: a real-Inter probe in
        // `mobile_header_brand_and_pill_test.dart` measures the lockup at
        // 106.0618. The trap is what is left over. `AppBar` charges
        // `titleSpacing` on BOTH sides of the title, not only the leading one:
        // `NavigationToolbar` lays its middle slot out at
        // `width - leading - trailing - middleSpacing * 2`. So
        //
        //   title Row       390 - 2*titleSpacing(32) - actions(16)  = 342.00
        //   F cluster       44 + space6(12) + 44                    = 100.00
        //   free space      342 - lockup(106.06) - cluster(100)     = 135.94
        //
        // "Free space" here is everything in the title Row that is neither the
        // lockup nor the cluster, so it INCLUDES the `space6` separator below.
        // Net slack beyond that separator is 123.94, and the same definition
        // applied to the pill era gives `342 - 106.06 - 223.94` = 12.00, all of
        // it separator and none of it slack. Both figures are measured at real
        // Inter in `mobile_header_brand_and_pill_test.dart`.
        //
        // 2026-08-07, sketch 183 scheme F: the right side stopped being a
        // remainder absorber and became a fixed 100. `kWalletPillMaxWidth` is
        // deleted because there is nothing left to cap - the cluster's width
        // does not vary with the wallet name at all, which is a stronger
        // version of the invariant the cap was written to protect.
        //
        // A DYNAMIC TYPE STARVATION THAT LOOKS REAL ON PAPER AND IS NOT. The
        // measurement is written down because the arithmetic on its own argues
        // for shrinking the cap below, and shrinking it would be wrong. The
        // cluster is non-flex, so the `Expanded` holding it cannot shrink
        // gracefully the way the pill did:
        //
        //   overflow when  342 - lockup - 12 < 100
        //                  lockup > 230.00
        //                  wordmark > 200.63
        //                  textScaler > 200.63 / 76.6934 = 2.616x
        //
        // iOS AX5 reaches about 3.1x, so that threshold looks reachable. IT IS
        // NOT REACHABLE HERE, and the reason is one line inside `AppBar`:
        //
        //   app_bar.dart:1098  title = MediaQuery.withClampedTextScaling(
        //                        maxScaleFactor: _kMaxTitleTextScaleFactor,
        //   app_bar.dart:44    const _kMaxTitleTextScaleFactor = 1.34
        //
        // `AppBar` clamps its TITLE's text scaling at 1.34x so the toolbar's
        // visual hierarchy survives large type. Measured through this header at
        // ambient 1.0 / 1.34 / 2.0 / 2.5 / 3.0 / 3.5, the scaler the wordmark
        // actually sees is 1.34x from 1.34 upward and never higher. So:
        //
        //   wordmark ceiling   76.6934 * 1.34       = 102.77
        //   lockup ceiling     21.37 + 8 + 102.77   = 132.14
        //   Expanded receives  342 - 132.14 - 12    = 197.86
        //   cluster needs                             100.00
        //
        // 97.86px of headroom at EVERY scale, against a 230 lockup that would
        // be needed to starve it. This is also why the clamp is load-bearing
        // rather than incidental: mounting this lockup outside an
        // `AppBar.title` removes it and puts the 2.616x threshold back in play.
        //
        // The glyph was checked the same way rather than assumed:
        // `Icon.applyTextScaling` resolves to NULL on the hamburger and its box
        // measures 18.0 x 18.0 at every step to 3.5, so a scaling glyph cannot
        // overflow the fixed 44px control independently of the lockup. Both
        // controls measure 44 x 44 throughout.
        ConstrainedBox(
          // UNCHANGED at 216, and the alternative is recorded because the
          // arithmetic above invites it. Lowering this to 196 would buy 4.63px
          // of margin against an overflow that `AppBar`'s own clamp already
          // makes unreachable, and would cost real width in the only regime
          // that exists: the wordmark would ellipsize 20px earlier for nothing.
          //
          // A Dynamic Type fuse, not a behaviour: at normal scale `GNUS.AI`
          // measures 76.69 logical px against Inter Bold 18, so it never comes
          // near the cap and the ellipsis never fires. 216 is 180 scaled by the
          // same 1.20 the wordmark grew, specifically so the SHIPPED scale
          // headroom is held constant at `216 / 76.69` = 2.82x. Left at 180 it
          // would have dropped to 2.35x silently, which is a change to an
          // invariant disguised as leaving a number alone.
          //
          // That 2.82x is a ceiling this widget can no longer reach, because
          // the 1.34x clamp binds first. It is kept as the number that governs
          // the day this lockup is mounted anywhere other than `AppBar.title`.
          constraints: const BoxConstraints(maxWidth: 216),
          child: Text(
            // GNUS.AI, confirmed by Jakub on 2026-08-07 in preference to
            // GeniusAI, specifically so the app carries ONE brand string:
            // `logo_and_title.png` on the splash and on wallet creation
            // already renders GNUS.AI, and those screens are untouched. The
            // header now agrees with them by construction rather than by
            // coincidence.
            'GNUS.AI',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GeniusWalletTypography.labelMd.copyWith(
              // 18, up from 15 on 2026-08-07, the wordmark half of the same
              // growth. 18 rather than 17 because 18 is a step ON the type
              // scale - it is `titleLg`'s size, so the wordmark now reads at
              // the same size as the dashboard section titles, which is a real
              // systemic tie rather than a coincidence. The growth is 1.20x
              // against the mark's 1.167x, near-proportional either way.
              fontSize: 18,
              fontWeight: FontWeight.w700,
              // 19.29:1 on the bar. One colour, not two: a colour change
              // mid-token reads as a rendering fault rather than as design,
              // and the shipped wordmark image renders in one weight and one
              // colour too.
              color: gw.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

/// The wallet control: which wallet, on which chain, and the way into both.
///
/// Opens `AccountDrawer.show(context, includeNetwork: true)` - the sketch-174
/// accounts drawer with a network strip prepended. No third wallet surface is
/// invented.
///
/// 44 x 44 as of 2026-08-07, sketch 183 scheme F, down from a 223.94px pill.
/// The change is a DELETION, not a redesign: the `Material` /
/// `StadiumBorder(borderControl)` / `InkWell` recipe is untouched, and what
/// went is the name `Flexible`, the `space2`, the caret and the trailing
/// `space4`. On a square box the `StadiumBorder` renders as a circle. The name
/// `WalletPill` is KEPT so the sketch, this file and the test file agree on one
/// symbol rather than churning three places over a shape word.
///
/// The fill is 1.11:1 against the bar (`surfaceMenu` on `surfaceElevated`), so
/// it identifies nothing and the `borderControl` edge carries WCAG 1.4.11
/// alone, at 3.30:1. That is precisely the case that token exists for.
///
/// WHAT F GIVES UP, recorded here because it is a measured cost and not an
/// oversight: this header no longer prints the wallet's name anywhere.
/// [AccountAvatar] paints `crypto/{currencySymbol}.png` on a flat
/// `brandPrimaryStrong` fill - no per-wallet colour, no blockie, no seed - so
/// it identifies the CURRENCY, not the wallet, and two ETH wallets render
/// identical headers (sketch 181, finding 1). At 44px it is slightly worse: the
/// 32px disc and the 16px network badge resolve to the same `crypto/eth.png`
/// for an ETH wallet on Ethereum, so the same picture is drawn twice, 3px
/// apart.
///
/// The remedy is named and costed and is NOT built here: sketch 181 scheme E
/// puts a two-character monogram inside this same 44px circle at zero extra
/// width, as an additive `monogram` branch on [AccountAvatar] in
/// `lib/account/account_drawer.dart` - a file outside this change. It is filed
/// as a todo and put to Jakub as a ruling rather than closed silently. Until
/// then the semantic label below is the only thing in this header that names a
/// wallet or a chain at all.
class WalletPill extends StatelessWidget {
  const WalletPill({super.key});

  @override
  Widget build(BuildContext context) {
    // No `gw` read here while the control is bare: the chip that used it went
    // with the border, and `AccountAvatar` sources its own colours.
    final state = context.watch<WalletDetailsCubit>().state;
    final wallet = state.selectedWallet;
    final network = state.selectedNetwork;

    // THE ONLY PLACE THIS HEADER IDENTIFIES ANYTHING IN WORDS, as of sketch
    // 183 scheme F. It was already the only place the CHAIN was named - the
    // 16px badge below is a change-detector, it says the chain moved and not
    // which chain - and F deleted the name column, so it is now the only place
    // the WALLET is named either. Both facts are load-bearing rather than
    // decorative, and all three branches below are asserted in
    // `mobile_header_brand_and_pill_test.dart`.
    //
    // A sighted user reads a picture of the currency; a VoiceOver user still
    // hears the wallet and the chain. That asymmetry is the gap the monogram
    // in this class's doc would close, and it is why this block must survive
    // any further trimming of this control byte for byte.
    final String semanticLabel;
    if (wallet == null) {
      semanticLabel = 'No wallet selected. Opens wallet and network';
    } else if (network?.name == null) {
      semanticLabel = '${wallet.walletName}. Opens wallet and network';
    } else {
      semanticLabel =
          '${wallet.walletName}, on ${network!.name}. '
          'Opens wallet and network';
    }

    return Material(
      // Sketch 183 scheme C, chosen on device 2026-08-07 after F shipped and
      // was walked: both controls bare. F is still in the file's history and
      // its argument is worth knowing, because C did not refute it - F said
      // the wallet holds a VALUE (which wallet, which chain) and the hamburger
      // holds none, so only the wallet earns the chip. C answers that the
      // difference, while real, is not worth 3.30:1 of border when the avatar
      // already identifies the control at 7.54:1 on its own.
      //
      // Unlike the hamburger, this control does not go plain when its chip is
      // removed: `AccountAvatar` is itself an opaque disc on brandPrimaryStrong
      // #0AAEE6, which measures 7.54:1 against the bar. So the wallet keeps a
      // visible round object and 1.4.11 is carried by the avatar rather than by
      // an edge. Removing the chip costs nothing measurable - the surfaceMenu
      // fill under it was 1.11:1 and identified nothing.
      //
      // The Material and clipBehavior STAY despite the transparent colour:
      // they are what clips the InkWell ripple. Drop them and the splash paints
      // as an unclipped rectangle, the defect that disqualified
      // GWGradientBorderCard from this role in sketch 183.
      color: Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => AccountDrawer.show(context, includeNetwork: true),
        // The Semantics wraps the CONTENT, not the InkWell. Placed outside it
        // with `excludeSemantics: true` it would swallow the button role and
        // the tap action the InkWell supplies.
        // Both axes stated at the same constant, so the StadiumBorder above
        // resolves to a circle and the cluster's 100.00 cannot drift.
        child: SizedBox(
          width: kHeaderControlSize,
          height: kHeaderControlSize,
          child: Semantics(
            label: semanticLabel,
            excludeSemantics: true,
            // space3, not space4: a circle needs less inset than a glyph, and
            // it is now SYMMETRIC rather than a leading inset. 6 + 32 + 6 = 44,
            // which is sketch 183's "the disc stops 6 px inside its 44 box".
            // `space3` = 6 is the ONE documented exception to the 4-pt grid and
            // this is the use it was documented for.
            //
            // The name that used to sit here, its `space2` and the caret went
            // with scheme F. An address-shaped name reaching this control was a
            // real defect (the import screen at `import_security_screen.dart`
            // stores unvalidated free text, and the older header printed that
            // string twice - once whole-ish, once truncated). F removes the
            // string from the bar entirely, so the defect no longer surfaces
            // here. It is NOT fixed: the input still stores whatever it is
            // given, and that remains a todo against the import screen.
            // `walleticon.svg` was trialled here on 2026-08-07 at 26 then 20
            // and rejected on device: it is a SOLID silhouette at roughly 89%
            // ink coverage against Icons.menu's three 1.5px strokes, so it
            // reads far heavier than its neighbour at any size that is still
            // legible. Sketch 185 measured that true ink matching would put it
            // at 8.27. The avatar stays. If a generic glyph is ever wanted
            // here, the answer is a STROKE mark, not a smaller solid one.
            child: Padding(
              padding: const EdgeInsets.all(GeniusWalletConsts.space3),
              child: wallet != null
                  ? AccountAvatar(
                      wallet: wallet,
                      isSelected: true,
                      size: 32,
                      networkIconPath: network?.iconPath,
                    )
                  : const _NoWalletAvatar(),
            ),
          ),
        ),
      ),
    );
  }
}

/// The pill's avatar when no wallet is selected. The pill stays tappable in
/// this state, because the sheet it opens is where `Add Wallet` lives.
class _NoWalletAvatar extends StatelessWidget {
  const _NoWalletAvatar();

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    return CircleAvatar(
      radius: 32 / 2 - 2,
      backgroundColor: gw.brandPrimaryStrong,
      // 7.74:1.
      child: Icon(Icons.add, size: 20, color: gw.textOnBrand),
    );
  }
}

/// The header's hamburger: a bare glyph, opening the More sheet.
///
/// THE SPLIT IS THE WHOLE OF SCHEME F, and it will otherwise be "tidied" into a
/// matching pair by the next reader. The two controls beside each other carry
/// DIFFERENT decorations on purpose, because they are different kinds of
/// object:
///
///   * [WalletPill] holds a VALUE that changes, so it takes the app's chip
///     recipe - `surfaceMenu` fill, `borderControl` stadium - and its edge
///     carries WCAG 1.4.11 at 3.30:1.
///   * This button holds nothing and opens a fixed list, so it takes no
///     container at all: no `Material`, no `Container`, no border, no fill. The
///     glyph itself is the identifying element, at 19.29:1.
///
/// Both clear 1.4.11 on their own terms and neither depends on the 1.11:1 fill,
/// which identifies nothing in this bar. Giving this button a matching stadium
/// is sketch 183 scheme A, and A's defect is that two identical stadiums 12px
/// apart at a 56px pitch read as a SEGMENTED CONTROL - one object with two
/// halves rather than two objects. That is the specific reason F beat it. F's
/// ink gap is `12 + 13 = 25` against A's 12.
///
/// The one-edit fallback Jakub reserved on 2026-08-07 ("183F sprobujmy potem
/// mozemy cofnac do 183C jesli bedzie zle") is scheme C: drop the WALLET's
/// border too, so neither control has a container. That is a removal from
/// [WalletPill], never an addition here.
///
/// No gradient and no `GWGradientBorderCard`. That component's `onTap` path is
/// `Material(transparent) > InkWell > card`, so its splash paints behind an
/// opaque gradient `Container` and is never seen. On a 44px header button tap
/// feedback is most of the feedback there is.
class HeaderMenuButton extends StatelessWidget {
  const HeaderMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();

    return IconButton(
      // Material 3 gives `IconButton` a 48px minimum AND
      // `MaterialTapTargetSize.padded`, either of which silently makes this box
      // 48 and breaks the cluster's 100.00. All three lines below are needed to
      // pin it at 44, and `mobile_header_brand_and_pill_test.dart` measures the
      // result with `tester.getSize` rather than trusting them.
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(
        width: kHeaderControlSize,
        height: kHeaderControlSize,
      ),
      style: IconButton.styleFrom(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        // No decoration, so the glyph alone carries WCAG 1.4.11, at 19.29:1
        // against the bar. A chip was trialled here on 2026-08-07 (scheme A,
        // both controls bordered) and reverted: the wallet holds a value and
        // this does not, which is the whole of scheme F's argument.
      ),
      // 18, the same size as the caret this scheme deleted from the wallet
      // control. Sketch 183's ink-gap arithmetic is built on it:
      // `(44 - 18) / 2 = 13`, so F's separation is `12 + 13 = 25`. A 24 here
      // would break that measured figure and is not what Jakub looked at.
      // 24, raised from 18 on device 2026-08-07: "zostaw wiekszy hamburger
      // menu i tyle". The 18 came from matching the caret that scheme F had
      // just deleted from the wallet control, so it was sized against a glyph
      // that no longer exists.
      //
      // It moves one measured figure. Sketch 183's ink gap is
      // `(44 - glyph) / 2`, so the glyph now stops 10 inside its box rather
      // than 13, and F's apparent separation reads 22 rather than 25. The
      // 44x44 hit box and the cluster's 100.00 are unaffected - only the ink.
      icon: const Icon(Icons.menu, size: 24),
      color: gw.textPrimary,
      // Also supplies the semantic label, so no separate `Semantics` wrapper.
      tooltip: 'Menu',
      onPressed: () => MoreSheet.show(context),
    );
  }
}
