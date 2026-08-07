/// Holds the ONE number scheme A costs, and the rhythm it buys.
///
/// Successor to `assets_header_scheme_c_test.dart`, deleted with the scheme it
/// named. That file's subject was a composition - a kicker over the total,
/// inside `GWSectionTitle`'s reservation - that no longer exists anywhere, so
/// every assertion in it was about a shape rather than about a number worth
/// keeping. Two things carried forward and both are load-bearing: the real
/// Inter loader below, and the split between wide HEIGHT probes and a
/// real-metrics WIDTH probe.
///
/// ---------------------------------------------------------------------
/// WHY 94, AND WHY IT IS FONT-INDEPENDENT
/// ---------------------------------------------------------------------
///
/// Scheme C put the total INSIDE the title and cost 46. Scheme A puts the
/// title back on the plain `String` path and gives the total a band of its
/// own, which costs 94:
///
///   title box   edgePad(2) + reservation(44) + bottomPad(16)  =  62
///   total band  numericHeadline's shipped 24/32 line box      =  32
///                                                       sum  =  94
///
/// **+48 against today's 46**, which is 4 LESS than the sketch's 52, for two
/// reasons that are decisions rather than roundings:
///
///   * no spacer between the band and the first `CoinCardRow` - that row's own
///     ~20px ListTile centring snap already IS the gap, and it is the same
///     total-to-row relationship scheme C shipped;
///   * the total stays at `numericHeadline`'s 24, not the sketch's untokened
///     28. Both have a 32px line box, so the on-token size is free, and the
///     scheme C `height: 28/24` override dies with the reservation that forced
///     it.
///
/// **If this file ever reads above 94, that is a STOP, not a number to
/// adjust.** The +48 budget is what Jakub is being shown; something else grew.
///
/// The `bottomPad` term is 16 and NOT 0 because `contentTopInset` went 20 -> 0
/// with the scheme. The 20 described a `CoinCardRow` ListTile snap, and that
/// row is no longer the first widget under the title; the band is, and it
/// paints at its own top pixel. That is what the RHYTHM case below proves
/// independently of the arithmetic.
///
/// Every height here is a DECLARED line box (`titleLg` 18/24, `numericHeadline`
/// 24/32) plus integer padding, and a declared `height` fixes the line box
/// whatever glyphs land in it. So the harness's fallback typeface cannot move
/// these numbers, which is why the heights are asserted and the widths are not.
///
/// The Row's height is font-independent too, and that is worth stating because
/// it is the one place it could fail to be: `CrossAxisAlignment.center` sizes
/// the Row to its TALLEST child, and both children carry a declared line box
/// (32 and 18), so the band measures the total's 32 in both balance states
/// whatever glyphs land in it.
///
/// ---------------------------------------------------------------------
/// WHY `center` AND NOT `baseline`, AND WHY IT IS MEASURED IN PIXELS
/// ---------------------------------------------------------------------
///
/// The band shipped on 2026-08-07 at `CrossAxisAlignment.baseline`, and Jakub
/// rejected it on device the same day: the percentage read LOW against the
/// total. That is what baseline alignment DOES to two very different sizes -
/// it pins a 13px label's baseline to a 24px number's baseline, so the small
/// label's figure body hangs off the bottom of the big one's mass rather than
/// crossing its middle. It is a correct typographic rule applied to the wrong
/// relationship.
///
/// The OPTICAL CENTRING case below does not take that on trust and does not
/// take the fix on trust either. It renders the band, reads back the PAINTED
/// PIXELS, and reports where each side's ink actually sits. Measured, real
/// Inter, figure bodies only:
///
///   baseline   percentage's figure centre  +4.13  below the total's
///   end                                    +5.63  below
///   center                                 +0.13
///
/// 0.13px is 0.39 of a device pixel at 3x. So `center` closes the whole defect
/// on its own and **there is no nudge token in the band, deliberately**: a
/// hand-tuned offset here would be an untokened literal standing in for a
/// residual nobody can see. If someone adds one, this case is where to prove
/// it was not needed.
///
/// The probe measures FIGURE BODIES (`0123456789` on both sides), not the
/// shipped strings, and that is load-bearing rather than convenient. The
/// shipped total carries a `$` and thousands separators; a comma descends
/// below the baseline and drags a naive full-string ink centre down by 1.13px
/// while moving no digit at all. Measured both ways during the fix: the same
/// `center` render reads 0.13 on figure bodies and -1.13 on `$1,234,567.89`.
/// The eye centres on the digits, so the digits are what is asserted.
///
/// ---------------------------------------------------------------------
/// WHY THE WIDTH PROBE LOADS A REAL FONT AND THE HEIGHT PROBES RUN WIDE
/// ---------------------------------------------------------------------
///
/// The harness's deterministic test typeface draws digits roughly 1.7x wider
/// than real Inter at the same size (measured in
/// `compute_balance_unit_track_test.dart`, which loads a real face for exactly
/// this reason). At the production 390pt width that fabricates an overflow that
/// does not exist on device, so:
///
///   - the HEIGHT cases run at a wide probe width, where nothing wraps or
///     overflows and the measurement is width-independent anyway
///     (`gw_section_title_rhythm_test.dart` runs its row probes wide on the
///     same reasoning);
///   - the WIDTH case runs at the real 390pt-equivalent width with real Inter
///     loaded, so the slack it reports is the device's, not the harness's.
library;

import 'dart:typed_data' show ByteData;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderRepaintBoundary;
import 'package:flutter/services.dart' show FontLoader, rootBundle;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/genius_api.dart' show GeniusApi;
import 'package:genius_api/models/coin.dart';
import 'package:genius_wallet/components/cards/gw_section_title.dart';
import 'package:genius_wallet/components/cards/gw_view_all_link.dart';
import 'package:genius_wallet/components/coins/view/coin_card_row.dart';
import 'package:genius_wallet/components/coins/view/coins_screen.dart';
import 'package:genius_wallet/dashboard/home/view/dashboard_screen.dart';
import 'package:genius_wallet/providers/network_tokens_provider.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/theme/theme.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:intl/intl.dart';

/// `edgePad(2) + reservation(44) + bottomPad(16)`, at `contentTopInset: 0`.
const double kAssetsTitleBoxHeight =
    kGWSectionTitleEdgePad +
    kGWSectionTitleHeaderHeight +
    (kGWSectionTitleRenderedGap - kGWSectionTitleSlack);

/// `numericHeadline` ships `height: 32 / 24`, so the band is one 32px line box.
const double kAssetsTotalBandHeight = 32;

/// The whole Assets panel header under scheme A. Built from the exported
/// constants, never typed as 94, so the test and the component cannot drift.
const double kAssetsHeaderCost = kAssetsTitleBoxHeight + kAssetsTotalBandHeight;

/// What the same header cost under scheme C, kept as the thing the delta is
/// measured against rather than as a live assertion.
const double kSchemeCHeaderCost =
    kGWSectionTitleEdgePad + kGWSectionTitleHeaderHeight;

/// The dashboard's real outer width at 390pt, minus the ListView's `space3`
/// padding on each side. The `DashboardScrollContainer` then charges
/// `space6 + 1px border` per side and `GWSectionTitle` another `space4`, which
/// is what lands both the title row and the band on a 336px content box.
const double kPhoneContainerWidth = 390 - 2 * GeniusWalletConsts.space3;

/// Wide enough that the fallback typeface never forces a wrap or an overflow.
/// The heights under test are width-independent; see the library doc.
const double _kHeightProbeWidth = 900;

/// The widest total the README judged realistic, the one the width budget in
/// `coins_screen.dart` is derived against.
const double _kWorstRealisticTotal = 1234567.89;

/// Loads the real Inter faces so the WIDTH probe measures production metrics.
///
/// Precedent and reasoning: `compute_balance_unit_track_test.dart`, which
/// measured the same string at 316px under the fallback face and 178.7px under
/// real Inter-Bold. All four bundled weights are loaded here rather than one,
/// because this band mixes a w700 total and a w500 percentage and the title row
/// beside it draws a w600 label.
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

String _formatted(double total) =>
    NumberFormat.currency(symbol: r'$').format(total);

String _pctLabel(double pct) =>
    '${pct >= 0 ? '+' : ''}${pct.toStringAsFixed(2)}%';

/// The total band, built exactly as `coins_screen.dart` builds its private
/// `_AssetsTotalBand`.
///
/// A `StatelessWidget`, not a `_build...()` helper - AGENTS.md. The band is
/// private at the call site because nothing else may mount it, so the
/// composition is restated here for the parameterised probes. That duplication
/// is the reason the LAST case in this file mounts the real `CoinsScreen` and
/// measures the real call site: a fixture alone would stay green through a
/// regression that only touched `coins_screen.dart`.
class AssetsTotalBand extends StatelessWidget {
  const AssetsTotalBand({super.key, required this.total, this.pctOfTotal = 0});

  final double total;
  final double pctOfTotal;

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: GeniusWalletConsts.space4,
      ),
      child: Row(
        // Mirrors `_AssetsTotalBand` exactly, INCLUDING the 2026-08-07 switch
        // off `CrossAxisAlignment.baseline`. See OPTICAL CENTRING below for
        // the measurement that forced it.
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            _formatted(total),
            // No `height` override, deliberately. Scheme C carried 28/24 to
            // squeeze a two-line block into the 44px reservation; there is no
            // reservation here, so the shipped 32/24 governs.
            style: GeniusWalletTypography.numericHeadline.copyWith(
              fontWeight: FontWeight.w700,
              color: gw.textPrimary,
            ),
          ),
          if (total > 0) ...[
            const SizedBox(width: GeniusWalletConsts.space4),
            Text(
              _pctLabel(pctOfTotal),
              style: GeniusWalletTypography.labelMd.copyWith(
                color: pctOfTotal >= 0 ? gw.statusSuccess : gw.statusError,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

Widget _assetsHeader({required double total, required double width}) =>
    MaterialApp(
      theme: getThemeData(),
      home: Scaffold(
        body: SingleChildScrollView(
          child: SizedBox(
            width: width,
            child: DashboardScrollContainer(
              child: Column(
                children: [
                  GWSectionTitle(
                    title: 'Assets',
                    trailing: GWViewAllLink(onTap: () {}),
                  ),
                  AssetsTotalBand(
                    total: total,
                    pctOfTotal: total > 0 ? 12.34 : 0,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

/// [WalletDetailsCubit] takes a [GeniusApi] `CoinsScreen` only touches through
/// `getCoins()`, which nothing here triggers. Same apparatus
/// `dashboard_section_caps_test.dart` uses, and it throws loudly rather than
/// returning a silent null if that ever stops being true.
class _UnusedApi implements GeniusApi {
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

Coin _coin(String symbol, {required double balance}) =>
    Coin(name: symbol, symbol: symbol, iconPath: '', balance: balance);

Widget _realDashboardAssets() => MaterialApp(
  theme: getThemeData(),
  home: Scaffold(
    body: SingleChildScrollView(
      child: SizedBox(
        width: _kHeightProbeWidth,
        child: DashboardScrollContainer(
          child: BlocProvider<WalletDetailsCubit>(
            create: (_) => WalletDetailsCubit(
              initialState: WalletDetailsState(
                coins: [_coin('GNUS', balance: 5), _coin('BTC', balance: 3)],
                coinsStatus: WalletStatus.successful,
              ),
              geniusApi: _UnusedApi(),
              networkTokensProvider: NetworkTokensProvider(),
            ),
            child: const CoinsScreen(),
          ),
        ),
      ),
    ),
  ),
);

/// The two sides of the band drawn in the band's real styles, over strings the
/// caller chooses.
///
/// The OPTICAL CENTRING case feeds this PURE DIGITS rather than the shipped
/// `$1,234,567.89` / `+12.34%`, for the reason in the library doc: a comma
/// descends and moves an ink centre without moving a digit. The styles and the
/// `space4` gap are the band's own, and the alignment is read off the real
/// widget rather than typed here, so this composition cannot claim a centring
/// the shipping band does not have.
class _FigureProbe extends StatelessWidget {
  const _FigureProbe({required this.alignment});

  final CrossAxisAlignment alignment;

  static const String digits = '0123456789';

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    return Row(
      crossAxisAlignment: alignment,
      // Kept even though the shipping band no longer needs it, and NOT dead
      // config: `alignment` is read off the real widget, so when this case is
      // doing its job - catching a revert to `CrossAxisAlignment.baseline` -
      // the Row asserts on a null `textBaseline` before it can measure
      // anything. Removing this turns an informative 4.13px failure into a
      // framework assertion about a missing argument.
      textBaseline: TextBaseline.alphabetic,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          digits,
          style: GeniusWalletTypography.numericHeadline.copyWith(
            fontWeight: FontWeight.w700,
            color: gw.textPrimary,
          ),
        ),
        const SizedBox(width: GeniusWalletConsts.space4),
        Text(
          digits,
          style: GeniusWalletTypography.labelMd.copyWith(
            color: gw.statusSuccess,
          ),
        ),
      ],
    );
  }
}

/// Whether column [x] of an RGBA buffer holds ink.
///
/// Alpha > 128 rather than > 0 so an antialiasing fringe does not count as a
/// glyph edge. Both sides get the same threshold, so whatever bias it carries
/// cancels in the delta that is actually asserted.
bool _columnHasInk(ByteData px, int w, int h, int x) {
  for (int y = 0; y < h; y++) {
    if (px.getUint8((y * w + x) * 4 + 3) > 128) {
      return true;
    }
  }
  return false;
}

/// The vertical midpoint of the ink in columns `[fromX, toX)`, in logical px.
double _inkMidY(ByteData px, int w, int h, int fromX, int toX, double ratio) {
  int? top;
  int? bottom;
  for (int y = 0; y < h; y++) {
    for (int x = fromX; x < toX; x++) {
      if (px.getUint8((y * w + x) * 4 + 3) > 128) {
        top ??= y;
        bottom = y;
        break;
      }
    }
  }
  if (top == null || bottom == null) {
    fail('no ink found in columns [$fromX, $toX) - the probe painted nothing');
  }
  return (top + bottom + 1) / 2 / ratio;
}

void main() {
  // BOTH balance states, because the percentage is guarded by `total > 0` and a
  // band that only holds its height in one of them is not stable.
  for (final ({String name, double total}) c
      in const <({String name, double total})>[
        (name: 'funded', total: _kWorstRealisticTotal),
        (name: 'all-zero', total: 0),
      ]) {
    testWidgets('HEIGHT - the Assets header costs 94 (${c.name})', (
      tester,
    ) async {
      await tester.pumpWidget(
        _assetsHeader(total: c.total, width: _kHeightProbeWidth),
      );
      await tester.pump();

      final double title = tester.getSize(find.byType(GWSectionTitle)).height;
      final double band = tester.getSize(find.byType(AssetsTotalBand)).height;
      debugPrint(
        'SCHEME A | ${c.name.padRight(10)} title=$title band=$band '
        'total=${title + band} (scheme C was $kSchemeCHeaderCost)',
      );

      expect(
        title + band,
        kAssetsHeaderCost,
        reason:
            'the Assets panel header must cost exactly $kAssetsHeaderCost, a '
            '+${kAssetsHeaderCost - kSchemeCHeaderCost} delta against scheme '
            "C's $kSchemeCHeaderCost. Anything ABOVE this is a STOP, not a "
            'number to adjust: the budget Jakub is being shown slipped and '
            'something grew. The two likeliest causes are a spacer added '
            'between the band and the first row, and the total being pushed '
            'to the untokened 28 the sketch drew.',
      );

      // Stated separately so a failure says WHICH half moved.
      expect(
        title,
        kAssetsTitleBoxHeight,
        reason:
            'the title box must be edgePad + the reservation + a FULL '
            '${kGWSectionTitleRenderedGap - kGWSectionTitleSlack} bottom pad. '
            'A smaller box means `contentTopInset` was left at the 20 that '
            'described the old first-content widget, and the band is paying '
            'for slack it does not have.',
      );
      expect(
        band,
        kAssetsTotalBandHeight,
        reason:
            "the band is one numericHeadline line box. A 28 here is scheme C's "
            '`height: 28 / 24` override surviving the scheme that needed it',
      );
    });

    testWidgets('RHYTHM - the gap under the Assets title is 26 (${c.name})', (
      tester,
    ) async {
      await tester.pumpWidget(
        _assetsHeader(total: c.total, width: _kHeightProbeWidth),
      );
      await tester.pump();

      // Line box to first painted ink, the same convention
      // `gw_section_title_rhythm_test.dart` measures every other section by.
      // The total's `Text` is BOTH the band's topmost painted object and its
      // own layout-box top - the band has no centring snap of its own, which is
      // the whole claim `contentTopInset: 0` makes - so a plain rect read here
      // is the same number that file's `firstPaintedTopBelow` would return.
      final Rect titleBox = tester.getRect(find.text('Assets'));
      final Rect firstInk = tester.getRect(find.text(_formatted(c.total)));
      final double r2 = firstInk.top - titleBox.bottom;
      debugPrint('SCHEME A | ${c.name.padRight(10)} R2=$r2');

      expect(
        r2,
        kGWSectionTitleRenderedGap,
        reason:
            'Assets must render the shared $kGWSectionTitleRenderedGap gap that '
            'Markets, Transactions and Compute render. 30 here means '
            '`contentTopInset: 20` was left behind on the title; 20 means '
            'scheme C is still mounted.',
      );

      // R1, frozen at 12 by Jakub's 2026-08-06 constraint and untouched by
      // everything in this change. Re-checked because a change to the title's
      // left side is exactly what could move it.
      expect(
        titleBox.top - tester.getRect(find.byType(GWSectionTitle)).top,
        kGWSectionTitleEdgePad + kGWSectionTitleSlack,
      );
    });

    testWidgets('WIDTH - the band fits at 390pt with real Inter (${c.name})', (
      tester,
    ) async {
      // The device's metrics, not the harness's. See the library doc.
      await _loadInter();

      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        _assetsHeader(total: c.total, width: kPhoneContainerWidth),
      );
      await tester.pump();

      final double content =
          tester.getSize(find.byType(AssetsTotalBand)).width -
          2 * GeniusWalletConsts.space4;
      final double totalWidth = tester
          .getSize(find.text(_formatted(c.total)))
          .width;
      final double pctWidth = c.total > 0
          ? tester.getSize(find.text(_pctLabel(12.34))).width +
                GeniusWalletConsts.space4
          : 0;
      final double slack = content - totalWidth - pctWidth;

      // Logged, not asserted to a figure: the open follow-up is whether to
      // restore the dollar day-change the scheme C header dropped for want of
      // width. Whoever opens that decision needs a real measured number, and
      // this is where it comes from.
      debugPrint(
        'SCHEME A | ${c.name.padRight(10)} 390pt content=$content '
        'total=$totalWidth pct=$pctWidth slack=$slack',
      );

      expect(
        tester.takeException(),
        isNull,
        reason: 'an overflow here is the stripe Jakub would see on the phone',
      );
      expect(
        slack,
        greaterThan(0),
        reason:
            'the band must keep positive slack at the worst realistic total. '
            'The band has the full content box to itself - no `View all` '
            'competes with it, which is precisely what scheme A bought and '
            'scheme C did not have',
      );
    });
  }

  testWidgets(
    'THE REAL CALL SITE - CoinsScreen renders Assets through the plain String '
    'path and pays the same 94',
    (tester) async {
      // The fixture cases above restate the band, so they would stay green
      // through a regression that only touched `coins_screen.dart`. This case
      // mounts the real screen so the call site itself is covered: no market
      // data ever arrives in this harness, so it exercises the all-zero band.
      await tester.pumpWidget(_realDashboardAssets());
      await tester.pump();

      // What Jakub actually asked for, asserted as a property rather than as a
      // pixel: the section paints its NAME, in the one style `GWSectionTitle`
      // gives all eight sections. `titleLg` at 18, `textPrimary`.
      final Text title = tester.widget<Text>(find.text('Assets'));
      expect(title.style?.fontSize, GeniusWalletTypography.titleLg.fontSize);
      expect(title.style?.color, GWColors.dark().textPrimary);

      // And the header still costs 94 at the real call site: title box top to
      // the first row's top is the title plus the band, with nothing between.
      final double headerCost =
          tester.getRect(find.byType(CoinCardRow).first).top -
          tester.getRect(find.byType(GWSectionTitle)).top;
      debugPrint('SCHEME A | real CoinsScreen header=$headerCost');
      expect(
        headerCost,
        kAssetsHeaderCost,
        reason:
            'a spacer between the band and the first CoinCardRow would show up '
            'here and nowhere else. There must not be one: the row brings its '
            "own ~20px ListTile snap and that IS the gap, byte-for-byte what "
            'scheme C shipped between the total and the first row',
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    "OPTICAL CENTRING - the percentage's figure body sits on the total's "
    'middle, measured in painted pixels',
    (tester) async {
      // The device's metrics, not the harness's: this case is entirely about
      // where real Inter puts real ink. See the library doc.
      await _loadInter();

      // ---- 1. Read the alignment off the SHIPPING widget -----------------
      //
      // Not typed here. The probe below is a restatement of the band, and a
      // restatement asserts nothing about `coins_screen.dart` unless it is fed
      // from it. Feeding it this way is what makes a revert to `baseline` fail
      // as a 4px measurement rather than as a string comparison.
      await tester.pumpWidget(_realDashboardAssets());
      await tester.pump();

      final Finder band = find.byWidgetPredicate(
        (Widget w) => w.runtimeType.toString() == '_AssetsTotalBand',
      );
      expect(
        band,
        findsOneWidget,
        reason:
            'the private `_AssetsTotalBand` in `coins_screen.dart` was renamed '
            'or removed. Repoint this finder rather than deleting the case: '
            'without it the probe below stops testing the shipping band and '
            'starts testing itself',
      );
      final CrossAxisAlignment shipped = tester
          .widget<Row>(find.descendant(of: band, matching: find.byType(Row)))
          .crossAxisAlignment;

      // ---- 2. Paint the figure bodies at that alignment and scan them -----
      const double ratio = 4;
      const GlobalKey probeKey = GlobalObjectKey('figure-probe');
      await tester.pumpWidget(
        MaterialApp(
          theme: getThemeData(),
          home: Scaffold(
            body: Center(
              child: RepaintBoundary(
                key: probeKey,
                child: _FigureProbe(alignment: shipped),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      final RenderRepaintBoundary rb =
          probeKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      late ByteData px;
      late ui.Image image;
      // `toImage` is genuinely async and cannot run on the fake async zone.
      await tester.runAsync(() async {
        image = await rb.toImage(pixelRatio: ratio);
        px = (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
      });
      addTearDown(image.dispose);

      final int w = image.width;
      final int h = image.height;

      // The `space4` gap is the LAST blank column run, so walk in from the
      // right edge over the percentage's ink and stop at the first blank.
      int x = w - 1;
      while (x >= 0 && !_columnHasInk(px, w, h, x)) {
        x--;
      }
      while (x >= 0 && _columnHasInk(px, w, h, x)) {
        x--;
      }
      final int splitX = x + 1;
      expect(
        splitX,
        greaterThan(0),
        reason: 'the two Texts did not resolve into two ink runs',
      );

      final double totalMid = _inkMidY(px, w, h, 0, splitX, ratio);
      final double pctMid = _inkMidY(px, w, h, splitX, w, ratio);
      final double drop = pctMid - totalMid;

      debugPrint(
        'SCHEME A | optical ${shipped.name} boxH=${h / ratio} '
        'totalMid=$totalMid pctMid=$pctMid drop=$drop',
      );

      // Stated first so a revert reads as the decision it undid, not as a
      // number to widen the tolerance around.
      expect(
        shipped,
        CrossAxisAlignment.center,
        reason:
            'the Assets total band must align its children on their line-box '
            'CENTRES. `baseline` is what Jakub rejected on device on '
            '2026-08-07 - it drops the percentage 4.13px below the total\'s '
            'figure centre - and `end` is worse at 5.63',
      );
      expect(
        drop.abs(),
        lessThanOrEqualTo(0.5),
        reason:
            "the percentage's figure body must sit on the total's optical "
            'middle, and it measures $drop px off. Positive means LOW, which '
            'is exactly the complaint this case exists for. `center` measured '
            '0.13 when this was written, at a 0.25 probe granularity; a '
            'reading near 4 means the Row went back to `baseline`. Do NOT '
            'close a regression here with a nudge in the band - there is no '
            'offset token in it on purpose, and a residual this small cannot '
            'be what a human is seeing',
      );

      // The whole change is worthless if it bought height: the band is the
      // 32 of the 94px header Jakub approved on 2026-08-07.
      expect(
        h / ratio,
        kAssetsTotalBandHeight,
        reason:
            'the alignment change must not resize the band. `center` sizes a '
            'Row to its tallest child, and the total keeps its 32px line box',
      );
      expect(tester.takeException(), isNull);
    },
  );
}
