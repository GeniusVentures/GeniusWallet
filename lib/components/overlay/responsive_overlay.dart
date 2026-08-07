import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/account/account_dropdown_selector.dart';
import 'package:genius_wallet/account/sdk_account_manager.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/components/overlay/mobile_header.dart';
import 'package:genius_wallet/components/overlay/nav_destinations.dart';
import 'package:genius_wallet/dashboard/transactions/cubit/transactions_cubit.dart';
import 'package:genius_wallet/network/network_dropdown_selector.dart';
import 'package:genius_wallet/reown/reown_connect_button.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_decorations.dart';
import 'package:genius_wallet/theme/genius_wallet_gradient.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/theme/gw_context_extension.dart';
import 'package:genius_wallet/utils/breakpoints.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:go_router/go_router.dart';

List<Widget> _buildActionRowWidgets(BuildContext context) {
  final walletDetailsCubit = context.read<WalletDetailsCubit>();
  final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
  return [
    // Control track (sketch 039-B "jeden tor", extended by 042 variant 2):
    // chain / SDK account / wallet / connection state share one recessed
    // surfaceSunken track, the same recipe as `_TimeframeSegment` and
    // `_TransactionFilterBar` -- see CONVENTIONS.md -> Control track.
    //
    // Connect moved INSIDE the track and Buy GNUS left the bar entirely
    // (2026-07-26): with no CTA there is no hierarchy left to protect, so the
    // whole right side is one instrument with four fields. Track height is 44
    // (36px chip + 6px padding + 2px border), matching the nav tab hover at
    // responsive_overlay.dart's destination row.
    //
    // ponytail: SDKAccountManagerButton self-hides to SizedBox.shrink() when
    // accounts.isEmpty, but Row(spacing: 2) still reserves its 2px gap --
    // a 2px phantom gap below the perceptual threshold. Ceiling: the track
    // never tightens that last 2px. Upgrade path: lift the accounts.isEmpty
    // read up to this function and build the children list conditionally.
    Container(
      // 6px horizontal (3 vertical) so the outer fields keep a hair more room
      // from the track's own edge than they do from a divider -- sketch 042
      // variant 3.
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: gw.surfaceSunken,
        border: Border.all(color: gw.borderSubtle),
        borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 2,
        children: [
          const NetworkDropdownSelector(),
          _trackDivider(gw),
          // The SDK chip and ITS divider appear together. SDKAccountManagerButton
          // self-hides to SizedBox.shrink() when the account list is empty, and
          // with a divider next to it that would leave a hairline floating
          // against nothing. So the emptiness is read HERE instead -- the
          // upgrade path the previous `ponytail:` note named, now required
          // rather than optional. `watch` (not `read`): the divider has to
          // disappear the moment the list empties.
          if (context.watch<AppBloc>().state.sdkAccounts.isNotEmpty) ...[
            const SDKAccountManagerButton(),
            _trackDivider(gw),
          ],
          const AccountDropdownSelector(),
          _trackDivider(gw),
          ReownConnectButton(
            walletAddress:
                walletDetailsCubit.state.selectedWallet?.address ?? '',
            geniusApi: context.read<GeniusApi>(),
            walletDetailsCubit: walletDetailsCubit,
            transactionsCubit: context.read<TransactionsCubit>(),
          ),
        ],
      ),
    ),
  ];
}

/// Hairline separating two fields inside the navbar control track (sketch 042
/// variant 3 "instrument"). 22px against a 36px chip, so it reads as a rule
/// between readouts rather than a full-height cut.
Widget _trackDivider(GWColors gw) =>
    Container(width: 1, height: 22, color: gw.borderSubtle);

/// Nav icon size, shared by the phone bar's slots and the desktop bar's tabs.
///
/// Public so `mobile_nav_destinations_test.dart` computes the slot's vertical
/// budget from the same number the widget draws with. Named for mobile because
/// mobile is the surface whose budget is measured against it - the desktop bar
/// has no comparable height constraint - but BOTH bars read it, so changing it
/// changes both.
const kMobileNavIconSize = 23.0;

/// Painted height of the phone bottom bar, excluding the bottom safe-area
/// inset. Fits a 23px icon, a 4px gap, a 10px label and 8px of padding.
///
/// Public for the same reason as [kMobileNavIconSize]: the vertical budget is
/// 56.85 against this 60.00, which is 3.15 of slack, and only the label line
/// scales. That is asserted rather than described.
const double kMobileBarHeight = 60.0;

/// Diameter of the Swap dock. Larger than the bar is tall, on purpose - it is
/// meant to read as a control sitting ON the bar, not a tab inside it.
const double _kDockSize = 64.0;

/// How far the dock rises ABOVE the bar's top edge.
///
/// The dock is drawn inside the bar's own box (a taller box whose lower part
/// carries the painted bar), NOT translated out of it. That distinction is the
/// whole reason taps on the protruding half work: Flutter hit-tests a child
/// only within its parent's bounds, so a `Transform.translate` would have
/// produced the right picture and a dead top half.
const double _kDockOverhang = 26.0;

/// Width the bar's Row reserves for the dock, so the four tabs lay themselves
/// out around it instead of underneath it.
///
/// Public so the label-width test computes the per-tab slot as
/// `(390 - kMobileDockSlotWidth) / 4` = 76.50 rather than typing 76.50 twice.
const double kMobileDockSlotWidth = 84.0;

/// Bottom bar for phones: four labelled destinations with a Swap dock between
/// the second and third.
///
/// Sketch 171 variant B (shape) x 172 variant A (what the dock is), both picked
/// by Jakub on 2026-08-06. The dock is Swap and carries the SAME glyph the
/// floating action button already used, `Icons.swap_vert_rounded`
/// (`gw_swap_fab.dart:73`) - the point was to move a control that already
/// existed out of the way of the asset list, not to invent a new one, so
/// changing its icon would have thrown away the only recognition it had.
///
/// 2026-08-07, sketch 182 scheme S7: all four slots are now PLACES. The fourth
/// used to be `More`, which opened a sheet and was the one slot with no route
/// behind it; the header's hamburger took that job in the same change.
///
/// The active-tab consequence, recorded rather than discovered: `/markets`
/// moved into the sheet, so standing on it lights NO tab -
/// [navIndexForLocation] returns -1, which is the shipped 24-05 answer and not
/// a gap. `/assets` and `/news` each gained a lit tab, so the count of in-shell
/// routes that light nothing went from seven to six. Nothing lights WRONGLY,
/// which is the property 24-05 was about. Lighting the HAMBURGER instead was
/// considered and refused: the header has no selection idiom, and inventing one
/// is the redesigned-menu work that sketch 184 has not settled.
class _MobileTabBar extends StatelessWidget {
  const _MobileTabBar();

  @override
  Widget build(BuildContext context) {
    // Fail-soft GWColors read (04-02 const-widget live-flip pattern): this
    // widget is const-instanced by MobileOverlay, so appearance-aware tokens
    // must come from the Theme.of(context) dependency, not a static getter.
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final destinations = mobileDestinations;
    final selected = currentIndex(context, destinations);
    final onSwap = GoRouterState.of(context).uri.path.startsWith('/swap');

    // Read the inset explicitly rather than wrapping in `SafeArea`. The bar's
    // painted surface has to run all the way to the physical bottom edge -
    // a SafeArea around the whole thing would leave a transparent strip of
    // page canvas under it - while the ROW inside it must still clear the home
    // indicator. One number, used in both places, does both.
    //
    // 24-10: CAPPED at `kMaxBottomSafeInset`. The raw `viewPadding.bottom` is
    // 34 on Jakub's iPhone, and reserving all of it left a visibly dead band
    // under the tab labels (reported on the 2026-08-06 walk). See that
    // constant's doc for why 20 clears the home indicator with room to spare.
    //
    // 2026-08-07: the cap moved out of this file into
    // `genius_wallet_consts.dart` so the drawer shell's footer could share it.
    // Same value, same reasoning, now one place - see
    // `responsive_drawer.dart`'s footer.
    final rawInset = MediaQuery.viewPaddingOf(context).bottom;
    final bottomInset = rawInset > kMaxBottomSafeInset
        ? kMaxBottomSafeInset
        : rawInset;

    return SizedBox(
      // Every height here is stated. 24-07 was caused by exactly one box that
      // left an axis free inside a slot Scaffold offers the whole screen to,
      // and the failure was silent - no overflow, no exception, all tests
      // green, app unusable.
      height: _kDockOverhang + kMobileBarHeight + bottomInset,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: kMobileBarHeight + bottomInset,
            child: Container(
              decoration: BoxDecoration(
                gradient: GWDecorations.surfaceSheen,
                border: Border(
                  top: BorderSide(color: gw.borderSubtle, width: 0.5),
                ),
              ),
              padding: EdgeInsets.only(bottom: bottomInset),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _MobileTabItem(
                    dest: destinations[0],
                    selected: selected == 0,
                  ),
                  _MobileTabItem(
                    dest: destinations[1],
                    selected: selected == 1,
                  ),
                  // The dock is NOT a child of this Row - it is painted above,
                  // overlapping the bar's top edge. This reserves its footprint
                  // so the four tabs sit either side rather than beneath it.
                  const SizedBox(width: kMobileDockSlotWidth),
                  _MobileTabItem(
                    dest: destinations[2],
                    selected: selected == 2,
                  ),
                  _MobileTabItem(
                    dest: destinations[3],
                    selected: selected == 3,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: _kDockSize,
            child: Center(child: _MobileSwapDock(active: onSwap)),
          ),
        ],
      ),
    );
  }
}

/// One labelled tab. Its own widget rather than a `_buildTab()` so it can be
/// `const`-constructed and shows up in the DevTools inspector (AGENTS.md).
class _MobileTabItem extends StatelessWidget {
  const _MobileTabItem({required this.dest, required this.selected});

  final NavDestination dest;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return _MobileBarSlot(
      icon: dest.icon,
      label: dest.label,
      selected: selected,
      onTap: () => context.go(dest.path),
    );
  }
}

/// Shared geometry for every slot in the bar, so the dock cannot drift out of
/// alignment with the tabs beside it.
class _MobileBarSlot extends StatelessWidget {
  const _MobileBarSlot({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();

    // 24-08: the active tab was a FLAT `brandPrimaryStrong` blue. The design
    // system's active-nav state is the brand GRADIENT (Jakub, live walk
    // 2026-08-06 - "follow the component"), which is what the desktop bar's
    // selected underline already paints.
    //
    // Same single-paint-path recipe `gw_view_all_link.dart` uses: children are
    // drawn opaque WHITE and recoloured by one srcIn ShaderMask, so there is no
    // `selected ? ... : ...` branch in the widget tree - only in the shader.
    // Inactive collapses to a flat two-stop `textSecondary`, which paints
    // identically to a plain colour.
    //
    // `brandCtaText` (not raw `brandCta`) because the raw gradient measures
    // 1.65:1 on a light surface; the helper degrades it to
    // `brandPrimaryOnSurface` there. `surfaceElevated` is the bar's own fill,
    // so it is the correct appearance proxy.
    final shader = selected
        ? GeniusWalletGradient.brandCtaText(gw.surfaceElevated)
        : LinearGradient(colors: [gw.textSecondary, gw.textSecondary]);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusMd),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: GeniusWalletConsts.space4,
          ),
          child: ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: shader.createShader,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: kMobileNavIconSize, color: Colors.white),
                const SizedBox(height: GeniusWalletConsts.space2),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GeniusWalletTypography.labelMd.copyWith(
                    fontSize: 10,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    color: Colors.white,
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

/// The centre dock: Swap, raised out of the bar.
///
/// This is the one place in the app where a filled gradient sits on a surface
/// that may already carry a gradient CTA, which the CTA-weight rule normally
/// forbids. It is a deliberate, single exception: the dock is chrome, not a
/// page action, and it is the same gradient the FAB it replaces already used.
class _MobileSwapDock extends StatelessWidget {
  const _MobileSwapDock({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    return SizedBox(
      // Both axes stated. A box with one free axis inside a slot that offers
      // the whole screen is precisely what caused 24-07.
      width: _kDockSize,
      height: _kDockSize,
      child: Center(
        child: Semantics(
          button: true,
          label: 'Swap',
          child: InkWell(
            onTap: () => context.go('/swap'),
            customBorder: const CircleBorder(),
            child: Container(
              width: _kDockSize,
              height: _kDockSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: GeniusWalletGradient.brandCta,
                border: Border.all(color: gw.surfaceElevated, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: gw.brandPrimaryStrong.withValues(
                      alpha: active ? 0.55 : 0.35,
                    ),
                    blurRadius: active ? 18 : 12,
                  ),
                ],
              ),
              child: Icon(
                Icons.swap_vert_rounded,
                size: 30,
                color: gw.textOnBrand,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DesktopTopBar extends StatelessWidget implements PreferredSizeWidget {
  const _DesktopTopBar();

  @override
  Size get preferredSize =>
      const Size.fromHeight(GeniusWalletConsts.appBarHeight);

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final destinations = visibleDestinations;
    final selected = currentIndex(context, destinations);
    final hideLabels = MediaQuery.sizeOf(context).width < GeniusBreakpoints.xxl;

    return ColoredBox(
      color: gw.surfaceElevated,
      child: SizedBox(
        height: GeniusWalletConsts.appBarHeight,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 12, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Image.asset(
                    'assets/images/geniusappbarlogo.png',
                    height: 40,
                    package: 'genius_wallet',
                  ),
                  // FIX 2: logo→nav gap. The logo PNG (38×38) bakes in a ~9px
                  // transparent right margin (opaque bbox ends at x=29) but only
                  // ~1px on the left, so at height 40 a raw 24px SizedBox renders
                  // a ~33px visible gap on the right vs ~25px on the left. 15px
                  // compensates the ~9.5px right margin → both visible gaps ≈24.
                  const SizedBox(width: 15),
                  Row(
                    spacing: hideLabels ? 6 : 2,
                    children: [
                      ...destinations.indexed.map((entry) {
                        final (index, dest) = entry;
                        final isSelected = index == selected;
                        // Active label+icon = WHITE (textPrimary); the gradient lives
                        // ONLY in the underline. Inactive tabs "light up" white on
                        // hover. Built inside the StatefulBuilder below so the hover
                        // colour can react to `lifted`.

                        // Design-system hover: an inactive tab lights up to white
                        // (textPrimary) and rises onto surfaceElevated + card shadow
                        // + a 1px lift.
                        // ponytail: hover state lives in this StatefulBuilder
                        // closure; a parent rebuild (route/theme change) resets it
                        // mid-hover -- rare and harmless. Upgrade path: extract a
                        // _DesktopNavTab StatefulWidget if it ever matters.
                        bool hovered = false;
                        final tabButton = StatefulBuilder(
                          builder: (context, setHover) {
                            final lifted = hovered && !isSelected;
                            // WHITE on active OR hover, muted otherwise. No gradient
                            // on the label -- the gradient is the underline only.
                            final labelColor = (isSelected || lifted)
                                ? gw.textPrimary
                                : gw.textSecondary;
                            final iconLabelRow = Row(
                              mainAxisSize: MainAxisSize.min,
                              spacing: 6,
                              children: [
                                Icon(
                                  dest.icon,
                                  size: kMobileNavIconSize,
                                  color: labelColor,
                                ),
                                if (!hideLabels)
                                  Text(
                                    dest.label,
                                    style: GeniusWalletTypography.labelMd
                                        .copyWith(color: labelColor),
                                  ),
                              ],
                            );
                            return Material(
                              color: Colors.transparent,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: GeniusWalletConsts.space4,
                                ),
                                child: InkWell(
                                  onTap: () => context.go(dest.path),
                                  onHover: (h) => setHover(() => hovered = h),
                                  borderRadius: BorderRadius.circular(
                                    GeniusWalletConsts.borderRadiusCard,
                                  ),
                                  mouseCursor: SystemMouseCursors.click,
                                  // We paint the D lift ourselves, so suppress InkWell's
                                  // own overlay splash across all states.
                                  overlayColor: const WidgetStatePropertyAll(
                                    Colors.transparent,
                                  ),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 120),
                                    // THE app-wide hover recipe (sketch 044 variant 3,
                                    // 2026-07-26): brand tint + brand hairline, no
                                    // geometry. Replaces this tab's own
                                    // surfaceElevated + card-shadow + 1px rise, which
                                    // was one of three disagreeing hovers. The lift
                                    // is gone on purpose -- see GWDecorations.hover.
                                    decoration: lifted
                                        ? GWDecorations.hover(
                                            radius: GeniusWalletConsts
                                                .borderRadiusCard,
                                          )
                                        : const BoxDecoration(),
                                    child: SizedBox(
                                      height: 44.0,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12.0,
                                        ),
                                        // IntrinsicWidth tracks the Column's content width;
                                        // CrossAxisAlignment.stretch makes the underline
                                        // span exactly the icon+label width -- same
                                        // content-tracking as before ("Transactions" long,
                                        // "Swap" short, icon-only when labels are hidden).
                                        child: IntrinsicWidth(
                                          // Design C center-fix: a Stack so the icon+label
                                          // centers on the TRUE box center (via Center),
                                          // INDEPENDENTLY of the underline. The old grouped
                                          // `Center(Column[Row, gap, underline])` centered
                                          // the whole [text + underline] block as one unit,
                                          // which pushed the icon+label ~3.5px ABOVE the box
                                          // center (extra space at the top). The underline is
                                          // now a `Positioned(bottom:4, left:0, right:0)`
                                          // child: positioned children do NOT contribute to
                                          // the Stack's intrinsic width, so IntrinsicWidth
                                          // still resolves the box width from the icon+label
                                          // Row (content-tracking preserved), and left:0/
                                          // right:0 stretches the underline to exactly that
                                          // width (icon-only when labels are hidden).
                                          child: Stack(
                                            children: [
                                              Center(child: iconLabelRow),
                                              // Underline rides ~3-4px beneath the centered
                                              // text (still close to the label, NOT spread to
                                              // the box bottom). bottom:4 leaves the blur-10
                                              // glow ~4px clearance to the box edge; any
                                              // downward bleed lands on the 12px of elevated
                                              // bar below the box (same behaviour as the prior
                                              // shipped layout, which also spilled) and stays
                                              // inside the bar -- so no ClipRect is added,
                                              // which would otherwise clip the horizontal glow
                                              // and regress it.
                                              Positioned(
                                                // Lowered 4 -> 2 so the underline clears
                                                // the icon (reported near-overlap).
                                                bottom: 2,
                                                left: 0,
                                                right: 0,
                                                child: AnimatedContainer(
                                                  duration: const Duration(
                                                    milliseconds: 200,
                                                  ),
                                                  height: 3,
                                                  decoration: BoxDecoration(
                                                    // 002-B: a thick 3px gradient bar with
                                                    // a rounded top and a soft
                                                    // brandPrimaryStrong glow. Selected
                                                    // uses the brand CTA gradient;
                                                    // unselected is flat transparent. A
                                                    // BoxDecoration cannot set both color
                                                    // and gradient, so each state uses
                                                    // exactly one.
                                                    gradient: isSelected
                                                        ? GeniusWalletGradient
                                                              .brandCta
                                                        : null,
                                                    color: isSelected
                                                        ? null
                                                        : Colors.transparent,
                                                    borderRadius:
                                                        const BorderRadius.vertical(
                                                          top: Radius.circular(
                                                            3,
                                                          ),
                                                        ),
                                                    boxShadow: isSelected
                                                        ? [
                                                            BoxShadow(
                                                              color: context
                                                                  .gw
                                                                  .brandPrimaryStrong
                                                                  .withValues(
                                                                    alpha: 0.5,
                                                                  ),
                                                              blurRadius: 10,
                                                            ),
                                                          ]
                                                        : null,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );

                        return hideLabels
                            ? Tooltip(message: dest.label, child: tabButton)
                            : tabButton;
                      }),
                    ],
                  ),
                ],
              ),
              Row(
                spacing: GeniusWalletConsts.space6,
                children: [
                  // Buy GNUS removed from the bar 2026-07-26 (sketch 042):
                  // it was the only element forcing a hierarchy on this side,
                  // and without it the cluster can read as one instrument
                  // rather than a row of buttons. `/buy` is still routed and
                  // still reachable - this drops the shortcut, not the feature.
                  ..._buildActionRowWidgets(context),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MobileOverlay extends StatelessWidget {
  final Widget child;
  const MobileOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        return Scaffold(
          // 24-09: FLAT `surfaceBase`, not `GWCanvasBackground`.
          //
          // Jakub on the 2026-08-06 walk: the home page reads "szarawy" (washed
          // grey) and should be one solid dark. `GWCanvasBackground` paints
          // three layers over the page - a 3-stop `canvas` gradient whose TOP
          // stop is `#14171E` (a lift of ~+9 L* over `surfaceBase` `#0B0D12`),
          // a `canvasTopLight` radial white-12% glow centred near the top, and
          // a 4% noise texture. On a 390px-wide phone the glow's radius covers
          // most of the visible width, so all three land in the same place: the
          // top third, exactly where the grey was seen.
          //
          // The fix is to stop painting them, not to retune them - so this uses
          // the component that was already here: `Scaffold.backgroundColor`
          // with `gw.surfaceBase`, the same line `DesktopOverlay` below already
          // carries, and the same value `theme.dart:66` sets as
          // `scaffoldBackgroundColor`.
          //
          // DESKTOP KEEPS THE CANVAS deliberately. The layered wash exists to
          // stop a very large dark fill reading as dead, which is a real
          // problem at 1400px and not one at 390px. Mobile-only per the
          // mobile-first rule now in force.
          backgroundColor: gw.surfaceBase,
          // 24-03: was an AppBar whose title was the literal string
          // "Genius Wallet" and whose actions held the desktop control track
          // inside a horizontal SingleChildScrollView. See MobileHeader.
          appBar: const MobileHeader(),
          // Single-child Stack kept deliberately (D-05, quick task
          // 260731-gow): the dev bubble that used to be this Stack's second
          // child now mounts above the root Navigator via
          // lib/dev/dev_tools_host.dart, so a drawer's ModalBarrier no
          // longer eats its taps. Scaffold lays its body out under LOOSE
          // constraints, so a Stack expands to the full body box while a
          // bare child may size to itself - dropping this Stack would
          // silently change body sizing for every page in the shell.
          body: Stack(children: [child]),
          bottomNavigationBar: const _MobileTabBar(),
        );
      },
    );
  }
}

class DesktopOverlay extends StatelessWidget {
  final Widget child;
  const DesktopOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    return Scaffold(
      backgroundColor: gw.surfaceBase,
      appBar: const _DesktopTopBar(),
      // Single-child Stack kept deliberately (D-05, quick task 260731-gow):
      // the dev bubble that used to be this Stack's second child now mounts
      // above the root Navigator via lib/dev/dev_tools_host.dart, so a
      // drawer's ModalBarrier no longer eats its taps. Scaffold lays its
      // body out under LOOSE constraints, so a Stack expands to the full
      // body box while a bare child may size to itself - dropping this
      // Stack would silently change body sizing for every page in the
      // shell.
      body: GWCanvasBackground(
        child: Stack(
          children: [
            BlocBuilder<AppBloc, AppState>(
              builder: (context, state) {
                return child;
              },
            ),
          ],
        ),
      ),
    );
  }
}
