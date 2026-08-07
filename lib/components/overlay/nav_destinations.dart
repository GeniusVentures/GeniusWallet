import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

/// One navigable destination: a route, a label and a glyph.
///
/// Lifted out of `responsive_overlay.dart` on 2026-08-07 and made public. Two
/// things needed it: the phone header's hamburger has to open the sheet this
/// model derives, and `responsive_overlay.dart` already imports
/// `mobile_header.dart`, so importing back would have been a cycle. Public also
/// means a test can reach the model without mounting the whole shell, which is
/// the same reason `MobileHeader` was extracted before it.
class NavDestination {
  final String path;
  final String label;
  final IconData icon;
  final bool visible;

  const NavDestination({
    required this.path,
    required this.label,
    required this.icon,
    this.visible = true,
  });
}

/// Every destination the app knows about, in bar order.
///
/// THIS LIST DRIVES THE DESKTOP BAR. `_DesktopTopBar` renders one tab per
/// visible entry, so adding an entry here adds a desktop tab. That is why
/// `/assets` is NOT here even though it is on the phone bar as of sketch 182
/// scheme S7: adding it would take desktop from eight tabs to nine, and the
/// desktop bar is explicitly out of scope for that change. The consequence of
/// leaving it out is real and is recorded on [kNonDerivableMobilePaths].
final List<NavDestination> allDestinations = [
  const NavDestination(
    path: '/dashboard',
    label: 'Dashboard',
    icon: Icons.dashboard_outlined,
  ),
  NavDestination(
    path: '/transactions',
    label: 'Transactions',
    icon: FontAwesomeIcons.clock.data,
  ),
  const NavDestination(
    path: '/swap',
    label: 'Swap',
    icon: Icons.swap_horiz_outlined,
  ),
  const NavDestination(
    path: '/markets',
    label: 'Markets',
    icon: Icons.show_chart,
  ),
  const NavDestination(
    path: '/news',
    label: 'News',
    icon: Icons.article_outlined,
  ),
  NavDestination(
    path: '/web',
    label: 'Web',
    icon: FontAwesomeIcons.globe.data,
    visible: !Platform.isLinux,
  ),
  const NavDestination(
    path: '/logs',
    label: 'Feedback',
    icon: Icons.chat_bubble_outline,
  ),
  const NavDestination(
    path: '/settings',
    label: 'Settings',
    icon: Icons.settings_outlined,
  ),
];

List<NavDestination> get visibleDestinations =>
    allDestinations.where((d) => d.visible).toList();

/// Index of the destination matching the current route, or **-1** when none
/// does.
///
/// 24-05: this used to `return 0` on no match, which silently lit up Dashboard
/// on every route inside the shell that is not itself a destination. `/buy`
/// (moved into the shell 2026-07-31) and `/token-info` (2026-07-28) are exactly
/// that: you could stand on the Buy form and the bar would claim you were on
/// Dashboard. -1 is honest, and every caller already handles it - the desktop
/// bar compares `index == selected` (false for all) and the mobile bar checks
/// membership rather than indexing.
///
/// PURE, and that is why it is separate from [currentIndex] below: the whole
/// route-to-tab ledger can be asserted without pumping a router, which is what
/// `mobile_nav_destinations_test.dart` does.
int navIndexForLocation(String location, List<NavDestination> among) {
  for (var i = 0; i < among.length; i++) {
    if (location.startsWith(among[i].path)) {
      return i;
    }
  }
  return -1;
}

/// [navIndexForLocation] against the route the given context is standing on.
int currentIndex(BuildContext context, List<NavDestination> among) =>
    navIndexForLocation(GoRouterState.of(context).uri.path, among);

/// The MOBILE bar's own destination set - four tabs plus a centre dock.
///
/// Deliberately NOT [allDestinations]. That list has eight entries, and on a
/// 390pt phone eight fixed tabs get 48.7pt each, which truncated "Dashboard",
/// "Transactions" and "Feedback" to ellipses on a real device (reported from
/// Jakub's iPhone, 2026-08-06). Material's own guidance for a fixed bottom bar
/// is 3-5 destinations.
///
/// The four that dropped out are NOT gone - News, Web, Feedback and Settings
/// live in the More sheet below, which keeps the Phase 4 criterion that every
/// route reachable before the port stays reachable. The desktop bar still reads
/// [allDestinations] and is untouched by any of this.
///
/// 2026-08-07, sketch 182 scheme S7, picked by Jakub: Markets left the bar for
/// Assets, and the `More` slot left it for News. `More` was the one slot on the
/// bar that was not a place, and the hamburger in the header took its job in
/// the same change. Markets moved into the sheet with NO second edit, because
/// [moreDestinations] is derived from what this list does not show - that
/// derivation is the property that makes a tab-set change safe.
///
/// The bar's horizontal label ceiling ROSE as a result, from 1.93x (Markets,
/// the binding label before) to 2.06x (Activity). Measured at real Inter in
/// `mobile_nav_destinations_test.dart`, which also records the ceiling that
/// actually binds: the slot overflows VERTICALLY at about 1.23x, far below any
/// label's horizontal limit. That is pre-existing geometry and is filed as a
/// todo rather than fixed inside a navigation change.
final List<NavDestination> mobileDestinations = [
  const NavDestination(
    path: '/dashboard',
    label: 'Home',
    icon: Icons.dashboard_outlined,
  ),
  const NavDestination(
    path: '/assets',
    label: 'Assets',
    // The app's ESTABLISHED holdings glyph, not a new one: `assets_screen.dart`
    // (line 481) and `coins_screen.dart` (line 231) both already draw it for
    // the "No coins yet" state, so the bar tab and the pages it opens agree by
    // construction. The More sheet's `Accounts` row uses the same glyph, and
    // the two are never adjacent - one is on the bar, the other is a sheet
    // away - so reusing the app's own holdings glyph beat inventing a second
    // one for the sake of uniqueness.
    icon: Icons.account_balance_wallet_outlined,
  ),
  NavDestination(
    path: '/transactions',
    label: 'Activity',
    icon: FontAwesomeIcons.clock.data,
  ),
  const NavDestination(
    path: '/news',
    label: 'News',
    // Copied from [allDestinations]'s own News entry, so the bar and the sheet
    // cannot disagree about what News looks like if it ever moves between them.
    icon: Icons.article_outlined,
  ),
];

/// What the More sheet holds: everything in [allDestinations] that the mobile
/// bar does not show, minus Swap, which is the dock.
///
/// DERIVED, not written, and that is the whole safety argument for changing the
/// bar. Under sketch 182 scheme S7 this resolves to exactly Markets
/// `/markets`, Web `/web`, Feedback `/logs` and Settings `/settings` on a
/// non-Linux host, and `MoreSheetBody` appends an `Accounts` row by hand after
/// them.
///
/// The property that matters: editing [mobileDestinations] edits this sheet
/// with no second edit, so a destination taken off the bar cannot be dropped by
/// accident. `mobile_nav_destinations_test.dart` asserts the UNION of bar and
/// sheet paths equals every visible destination minus `/swap`, as set equality,
/// so a stranded route reddens the suite. The one path that derivation cannot
/// cover is named on [kNonDerivableMobilePaths].
List<NavDestination> get moreDestinations => allDestinations
    .where(
      (d) =>
          d.visible &&
          d.path != '/swap' &&
          !mobileDestinations.any((m) => m.path == d.path),
    )
    .toList();

/// Mobile bar paths that are NOT members of [allDestinations], so the
/// derived [moreDestinations] sheet cannot catch them if they ever leave
/// the bar. Each entry names the ONE entrance it falls back to.
const Map<String, String> kNonDerivableMobilePaths = {
  '/assets':
      'the dashboard Assets panel View all link '
      '(coins_screen.dart), and nothing else in the app',
};
