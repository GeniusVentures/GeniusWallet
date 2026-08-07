// The phone's navigation model, pinned for the first time.
//
// THE FINDING THAT JUSTIFIES THIS FILE, measured on 2026-08-07 before writing
// it: `grep -rln "responsive_overlay" test/` returned three files and NOT ONE
// of them asserted anything about the bar's destinations.
// `drawer_footer_inset_test.dart` used `kMaxBottomSafeInset` only,
// `dev_tools_bubble_persistence_test.dart` mentioned the file in a comment, and
// `mobile_header_brand_and_pill_test.dart` was about the header.
// `global_swap_fab_host_test.dart` asserted only that the FAB is ABSENT on the
// mobile shell. `find.text('Markets')`, `find.text('Activity')` and
// `find.text('More')` appeared nowhere in `test/`.
//
// So the bar's destination set could be re-pointed with a fully green suite,
// which is exactly what sketch 182 scheme S7 does. That is what this file
// closes, and it closes it for the NEXT change rather than this one.
//
// Every expected value below is written out in full. A change to the tab set
// is supposed to redden this file and force whoever made it to look at what it
// costs, which is the whole point.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FontLoader, rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/components/overlay/nav_destinations.dart';
import 'package:genius_wallet/components/overlay/responsive_overlay.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';

/// `(label, path)` pairs, so a failure prints both and not an object identity.
List<(String, String)> _pairs(List<NavDestination> destinations) =>
    destinations.map((d) => (d.label, d.path)).toList();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('the bar and the sheet, exactly', () {
    test('the mobile bar is Home, Assets, Activity, News, in that order', () {
      // Sketch 182 scheme S7, picked by Jakub on 2026-08-07. Equality on the
      // whole ordered list, not `contains`: the ORDER is what puts the Swap
      // dock between Assets and Activity, and a reorder that kept the same
      // members would move the dock without anyone noticing.
      expect(_pairs(mobileDestinations), const <(String, String)>[
        ('Home', '/dashboard'),
        ('Assets', '/assets'),
        ('Activity', '/transactions'),
        ('News', '/news'),
      ]);
    });

    test('the derived More sheet is Markets, Web, Feedback, Settings', () {
      // The label says Feedback and the ROUTE says `/logs`. Someone will
      // assume `/feedback`; there is no such route, and a tab pointing at one
      // would be a dead control that looks live.
      final expected = <(String, String)>[
        ('Markets', '/markets'),
        if (!Platform.isLinux) ('Web', '/web'),
        ('Feedback', '/logs'),
        ('Settings', '/settings'),
      ];
      expect(_pairs(moreDestinations), expected);
    });

    test('REACHABILITY: bar paths union sheet paths equals every visible '
        'destination except /swap', () {
      // THE MOST VALUABLE ASSERTION IN THIS FILE. `More` left the bar in the
      // same change that added the header's hamburger, and if those two had
      // been separate steps then Markets, Web, Feedback and Settings would
      // have been unreachable on the phone in between - Settings included.
      //
      // SET EQUALITY, never containment: `expected ⊆ reachable` alone would
      // pass happily while something was stranded in the other direction,
      // and it is a weaker statement than this model can support.
      //
      // TWO paths are subtracted from the left before comparing, and BOTH
      // subtractions are bounded by an assertion elsewhere in this file
      // rather than being a hole:
      //
      //   * `/swap` reaches the user through the centre dock
      //     (`_MobileSwapDock`, `context.go('/swap')`), which is neither a
      //     tab nor a sheet row. `moreDestinations` excludes it by name.
      //   * `/assets` is on the bar and is NOT a member of allDestinations,
      //     so it cannot appear on the right-hand side at all - see the
      //     `/assets trap` group, which pins that fact AND pins
      //     kNonDerivableMobilePaths to exactly {'/assets'}. Subtracting the
      //     map's keys therefore cannot silently widen: adding a key to it
      //     reddens that group.
      final reachable = {
        ...mobileDestinations.map((d) => d.path),
        ...moreDestinations.map((d) => d.path),
      }..removeWhere(kNonDerivableMobilePaths.containsKey);

      final expected = visibleDestinations
          .map((d) => d.path)
          .where((p) => p != '/swap')
          .toSet();

      expect(
        reachable,
        expected,
        reason:
            'symmetric difference: '
            '${reachable.difference(expected).union(expected.difference(reachable))}. '
            'A path on NEITHER side is unreachable on the phone - there is '
            'no third entrance, and that is precisely what taking `More` off '
            'the bar without landing the hamburger would have done to '
            'Markets, Web, Feedback and Settings. A path on both is harmless '
            'but means the derivation in moreDestinations stopped excluding '
            'the bar',
      );
    });
  });

  group('the /assets trap', () {
    test('allDestinations still has exactly eight entries and no /assets', () {
      // A CURRENT FACT, asserted so it is a LOUD one. `/assets` cannot be
      // added to this list without giving the DESKTOP bar a ninth tab, which
      // is out of scope for every change that has touched the phone bar.
      expect(allDestinations.length, 8);
      expect(allDestinations.map((d) => d.path).toList(), const <String>[
        '/dashboard',
        '/transactions',
        '/swap',
        '/markets',
        '/news',
        '/web',
        '/logs',
        '/settings',
      ]);
      expect(allDestinations.any((d) => d.path == '/assets'), isFalse);
    });

    test(
      'every bar path outside allDestinations names its fallback entrance',
      () {
        for (final dest in mobileDestinations) {
          final derivable = allDestinations.any((d) => d.path == dest.path);
          if (derivable) {
            continue;
          }
          expect(
            kNonDerivableMobilePaths.containsKey(dest.path),
            isTrue,
            reason:
                '${dest.path} is on the phone bar and is NOT a member of '
                'allDestinations, so the derived More sheet can never catch '
                'it. Taking it off the bar returns it to whatever entrance is '
                'named in kNonDerivableMobilePaths - and for /assets today '
                'that is ONE View all link on one panel of the dashboard. Add '
                'the path to that map with its fallback named, or give the '
                'route a real second entrance',
          );
        }
        // The map is not allowed to rot in the other direction either.
        expect(kNonDerivableMobilePaths.keys.toSet(), {'/assets'});
      },
    );
  });

  group('every bar and sheet path is a real route', () {
    // Source scan, the pattern `freeze_rule_test.dart` already uses. A tab
    // pointing nowhere is worse than no tab: it looks live and does nothing.
    test('router.dart declares a route for each of them', () {
      final router = File('lib/navigation/router.dart');
      expect(
        router.existsSync(),
        isTrue,
        reason:
            'the router has moved - fix this path rather than letting the '
            'guard silently scan nothing',
      );

      final source = router.readAsStringSync();
      for (final path in <String>[
        ...mobileDestinations.map((d) => d.path),
        ...moreDestinations.map((d) => d.path),
      ]) {
        expect(
          source.contains("path: '$path'"),
          isTrue,
          reason:
              '$path is on the bar or in the More sheet but no GoRoute '
              'declares it. That is a dead control that looks live',
        );
      }
    });
  });

  group('the route-to-tab ledger', () {
    test('navIndexForLocation answers exactly this for every shell route', () {
      // 24-05: this function used to `return 0` on no match, which lit
      // Dashboard while you stood on the Buy form. -1 is the honest answer and
      // it is the shipped one; every -1 below is deliberate, not a gap.
      const ledger = <String, int>{
        '/dashboard': 0,
        '/assets': 1,
        '/transactions': 2,
        '/news': 3,
        // Moved into the More sheet by scheme S7, so it lights no tab. That is
        // already the shipped behaviour for the three below it.
        '/markets': -1,
        '/web': -1,
        '/logs': -1,
        '/settings': -1,
        // In the shell, never destinations. These are the two 24-05 was about.
        '/buy': -1,
        '/token-info': -1,
        // The dock glows on its own, separately from the index.
        '/swap': -1,
      };

      ledger.forEach((location, expected) {
        expect(
          navIndexForLocation(location, mobileDestinations),
          expected,
          reason: '$location should map to tab $expected',
        );
      });
    });

    test('no mobile path is a prefix of another', () {
      // `startsWith` is the matcher, so a prefix pair would make the ledger
      // above depend on list ORDER rather than on the route.
      for (final a in mobileDestinations) {
        for (final b in mobileDestinations) {
          if (identical(a, b)) {
            continue;
          }
          expect(
            a.path.startsWith(b.path),
            isFalse,
            reason:
                '${a.path} starts with ${b.path}, so startsWith is '
                'ambiguous and the lit tab depends on list order',
          );
        }
      }
    });
  });

  group('the bar fits, measured at real Inter', () {
    test('all four labels fit their slot at 390pt', () async {
      await _loadInter();

      // The Row lays four Expanded tabs around one fixed dock slot, and
      // `_MobileBarSlot` adds VERTICAL padding only, so the label gets the
      // whole slot width with nothing taken off it.
      const double slot = (390 - kMobileDockSlotWidth) / 4;
      expect(slot, 76.50);

      // w600 is the ACTIVE weight and the wider of the two the slot renders.
      final style = GeniusWalletTypography.labelMd.copyWith(
        fontSize: 10,
        fontWeight: FontWeight.w600,
      );

      for (final dest in mobileDestinations) {
        final painter = TextPainter(
          text: TextSpan(text: dest.label, style: style),
          textDirection: TextDirection.ltr,
        )..layout();
        final width = painter.width;
        debugPrint(
          'BAR LABEL | ${dest.label} w600=${width.toStringAsFixed(2)} '
          'slot=$slot horizontalCeiling=${(slot / width).toStringAsFixed(2)}x',
        );
        expect(
          width,
          lessThan(slot),
          reason:
              '${dest.label} does not fit the ${slot}px slot at Inter '
              'SemiBold 10 and would ellipsize on the bar',
        );
      }
      // MEASURED on 2026-08-07: Home 28.46, Assets 33.04, Activity 37.21,
      // News 27.24. The binding label is Activity at a 2.06x horizontal
      // ceiling, UP from Markets' 1.93x before scheme S7 - so S7 RAISED this
      // ceiling rather than lowering it. See the vertical case below for the
      // ceiling that actually binds, which is far lower and which no label
      // ever reaches.
    });

    test('the slot stack fits the bar height, with the slack printed', () {
      // Computed from the real constants, never from a literal, so a change to
      // any term moves this rather than silently eating the slack.
      const double padding = 2 * GeniusWalletConsts.space4;
      final double labelLine = 10 * GeniusWalletTypography.labelMd.height!;
      final double total =
          padding + kMobileNavIconSize + GeniusWalletConsts.space2 + labelLine;
      final double slack = kMobileBarHeight - total;
      debugPrint(
        'BAR VERTICAL | padding=$padding icon=$kMobileNavIconSize '
        'gap=${GeniusWalletConsts.space2} label=$labelLine '
        'total=$total bar=$kMobileBarHeight slack=$slack',
      );

      expect(total, lessThanOrEqualTo(kMobileBarHeight));

      // THE CEILING THAT ACTUALLY BINDS, recorded here because nothing had
      // recorded it. The stack measures 56.85 against a 60.00 bar, so there is
      // 3.15 of slack, and the 13.85px label line is the ONLY term that
      // scales. The column overflows once `13.846 * s > 17.00`, which is
      // textScaler above about 1.23x - far below every label's horizontal
      // ceiling of 2.06x or better, so NO LABEL EVER TRUNCATES. The bar
      // overflows vertically first.
      //
      // This is PRE-EXISTING: today's bar has identical geometry, and sketch
      // 182 scheme S7 neither causes it nor worsens it. It is out of scope for
      // a navigation change - fixing it means clamping textScaler on the bar
      // or restyling the slot, which is a design decision - and is filed as
      // `.planning/todos/pending/2026-08-07-mobile-bar-overflows-vertically-at-1.23x-dynamic-type.md`.
      // This assertion exists so it cannot quietly get WORSE.
      expect(slack, moreOrLessEquals(3.15, epsilon: 0.01));
    });
  });
}

/// Loads the real Inter faces, the same escape hatch
/// `mobile_header_brand_and_pill_test.dart` and
/// `assets_header_scheme_a_test.dart` use. The label widths are the whole
/// question here and the harness face cannot answer it.
Future<void> _loadInter() async {
  final loader = FontLoader('Inter');
  for (final String asset in const <String>[
    'assets/fonts/Inter-Regular.ttf',
    'assets/fonts/Inter-Medium.ttf',
    'assets/fonts/Inter-SemiBold.ttf',
    'assets/fonts/Inter-Bold.ttf',
  ]) {
    loader.addFont(rootBundle.load(asset));
  }
  await loader.load();
}
