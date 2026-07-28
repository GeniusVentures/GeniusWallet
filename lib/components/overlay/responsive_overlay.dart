import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/account/account_dropdown_selector.dart';
import 'package:genius_wallet/account/sdk_account_manager.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/dashboard/transactions/cubit/transactions_cubit.dart';
import 'package:genius_wallet/dev/dev_flags.dart';
import 'package:genius_wallet/dev/dev_tools_bubble.dart';
import 'package:genius_wallet/network/network_dropdown_selector.dart';
import 'package:genius_wallet/reown/reown_connect_button.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_decorations.dart';
import 'package:genius_wallet/theme/genius_wallet_gradient.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/utils/breakpoints.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:go_router/go_router.dart';

class _TabDestination {
  final String path;
  final String label;
  final IconData icon;
  final bool visible;

  const _TabDestination({
    required this.path,
    required this.label,
    required this.icon,
    this.visible = true,
  });
}

final List<_TabDestination> _allDestinations = [
  const _TabDestination(
    path: '/dashboard',
    label: 'Dashboard',
    icon: Icons.dashboard_outlined,
  ),
  _TabDestination(
    path: '/transactions',
    label: 'Transactions',
    icon: FontAwesomeIcons.clock.data,
  ),
  const _TabDestination(
    path: '/swap',
    label: 'Swap',
    icon: Icons.swap_horiz_outlined,
  ),
  const _TabDestination(
    path: '/markets',
    label: 'Markets',
    icon: Icons.show_chart,
  ),
  const _TabDestination(
    path: '/news',
    label: 'News',
    icon: Icons.article_outlined,
  ),
  _TabDestination(
    path: '/web',
    label: 'Web',
    icon: FontAwesomeIcons.globe.data,
    visible: !Platform.isLinux,
  ),
  const _TabDestination(
    path: '/logs',
    label: 'Feedback',
    icon: Icons.chat_bubble_outline,
  ),
  const _TabDestination(
    path: '/settings',
    label: 'Settings',
    icon: Icons.settings_outlined,
  ),
];

List<_TabDestination> get _visibleDestinations =>
    _allDestinations.where((d) => d.visible).toList();

int _currentIndex(BuildContext context) {
  final location = GoRouterState.of(context).uri.path;
  final visible = _visibleDestinations;
  for (var i = 0; i < visible.length; i++) {
    if (location.startsWith(visible[i].path)) {
      return i;
    }
  }
  return 0;
}

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
          AccountDropdownSelector(),
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

const _kIconSize = 23.0;

class _MobileTabBar extends StatelessWidget {
  const _MobileTabBar();

  @override
  Widget build(BuildContext context) {
    // Fail-soft GWColors read (04-02 const-widget live-flip pattern) --
    // this widget is const-instanced (`bottomNavigationBar: const
    // _MobileTabBar()`), so appearance-aware tokens must come from the
    // Theme.of(context) InheritedWidget dependency, not a static getter.
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final destinations = _visibleDestinations;
    final selected = _currentIndex(context);

    // Background: GWDecorations.surfaceSheen (Gen-B's token vocabulary,
    // §2.5) -- a top-lit gradient consistent with the rest of the redesign's
    // elevated surfaces, rather than a flat transparent fill. Safe to read
    // directly (not gated through `gw`): it is itself appearance-aware
    // (GWAppearance.isLight) and, because this Container lives inside
    // _MobileTabBar's build(), it is only ever evaluated on a build() call
    // already forced by the `gw` read above.
    return Container(
      decoration: BoxDecoration(
        gradient: GWDecorations.surfaceSheen,
        border: Border(top: BorderSide(color: gw.borderSubtle, width: 0.5)),
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        currentIndex: selected,
        onTap: (index) => context.go(destinations[index].path),
        selectedItemColor: GeniusWalletColors.brandPrimaryStrong,
        unselectedItemColor: gw.textSecondary,
        selectedIconTheme: const IconThemeData(
          color: GeniusWalletColors.brandPrimaryStrong,
        ),
        unselectedIconTheme: IconThemeData(color: gw.textSecondary),
        selectedLabelStyle: GeniusWalletTypography.labelMd.copyWith(
          color: GeniusWalletColors.brandPrimaryStrong,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GeniusWalletTypography.labelMd.copyWith(
          color: gw.textSecondary,
          fontWeight: FontWeight.w500,
        ),
        items: destinations
            .map(
              (d) => BottomNavigationBarItem(
                icon: Icon(d.icon),
                activeIcon: Icon(d.icon),
                label: d.label,
                tooltip: d.label,
              ),
            )
            .toList(),
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
    final destinations = _visibleDestinations;
    final selected = _currentIndex(context);
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
                                  size: _kIconSize,
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
                                                              color: GeniusWalletColors
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
                  // still reachable — this drops the shortcut, not the feature.
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
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Genius Wallet"),
            actions: [
              Flexible(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    spacing: GeniusWalletConsts.space6,
                    children: [..._buildActionRowWidgets(context)],
                  ),
                ),
              ),
            ],
          ),
          body: Stack(
            children: [
              child,
              if (kDebugMode && kShowDevTools) const DevToolsBubble(),
            ],
          ),
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
      body: Stack(
        children: [
          BlocBuilder<AppBloc, AppState>(
            builder: (context, state) {
              return child;
            },
          ),
          if (kDebugMode && kShowDevTools) const DevToolsBubble(),
        ],
      ),
    );
  }
}
