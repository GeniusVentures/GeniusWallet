// The phone header, mounted on its own.
//
// Nothing asserted the header's structure before this file, and nothing
// could: it was a private `_MobileHeader` inside `responsive_overlay.dart`,
// unmountable without standing up the entire overlay. Extracting it to
// `mobile_header.dart` is what makes every assertion below possible, and that
// is half the reason the extraction happened.
//
// Two harness facts this file is built around:
//
//   * The test font is NOT Inter - `flutter_test` renders everything in
//     Ahem-like fallback metrics. So no absolute text width is asserted under
//     the harness face. Structure and invariants instead: both controls at
//     exactly 44 x 44, and brand-lockup width EQUAL across a short-name and a
//     long-name render. That last one is a font independent statement of "the
//     brand does not shrink", and it is the most valuable assertion in the
//     file.
//
//     ONE case departs from that, deliberately and with the escape hatch this
//     repo already uses elsewhere: the real-Inter test loads the actual faces
//     through a `FontLoader` before pumping, because the 2026-08-07 brand
//     growth raises a question that is purely about Inter's advances and the
//     harness face cannot answer it. Absolute widths there are device widths,
//     which is the point. Do not copy that pattern into the other cases.
//   * Both control sizes are asserted against the exported
//     `kHeaderControlSize`, never a typed 44, so the test and the widget
//     cannot drift apart. That rule was set by `kWalletPillMaxWidth`, which
//     sketch 183 scheme F deleted along with the pill it capped.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FontLoader, rootBundle;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/ffi/trust_wallet_api_ffi.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/network.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/components/overlay/mobile_header.dart';
import 'package:genius_wallet/components/overlay/more_sheet.dart';
import 'package:genius_wallet/components/overlay/nav_destinations.dart';
import 'package:genius_wallet/network/network_dropdown_selector.dart';
import 'package:genius_wallet/providers/network_tokens_provider.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/utils/wallet_utils.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';

/// See `account_drawer_show_test.dart` for why this is `implements` plus a
/// `noSuchMethod` forward: the real `GeniusApi`'s constructor dlopens the
/// native SuperGenius framework and kills the test host.
class _FakeGeniusApi implements GeniusApi {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _network = Network(
  name: 'Testchain',
  symbol: 'TST',
  chainId: 90001,
  rpcUrl: 'https://testchain.invalid',
  iconPath: 'assets/images/crypto/eth.png',
);

Wallet _wallet(String name) => Wallet(
  coinType: TWCoinType.TWCoinTypeEthereum,
  walletName: name,
  currencySymbol: 'ETH',
  walletType: WalletType.privateKey,
  balance: 0,
  address: '0xAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA',
);

/// Mounts [MobileHeader] in the appBar slot of a real `Scaffold` at a 390x844
/// phone surface - the geometry every width assertion below is about.
Future<WalletDetailsCubit> _pumpHeader(
  WidgetTester tester, {
  Wallet? wallet,
  Network? network = _network,
  double textScale = 1.0,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final cubit = WalletDetailsCubit(
    initialState: WalletDetailsState(
      selectedWallet: wallet,
      selectedNetwork: network,
    ),
    geniusApi: _FakeGeniusApi(),
    networkTokensProvider: NetworkTokensProvider(),
  );
  addTearDown(cubit.close);

  await tester.pumpWidget(
    BlocProvider<WalletDetailsCubit>.value(
      value: cubit,
      child: MaterialApp(
        theme: ThemeData.dark().copyWith(extensions: [GWColors.dark()]),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: const Scaffold(appBar: MobileHeader()),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return cubit;
}

/// The whole right-hand cluster's width: wallet + `space6` + hamburger.
///
/// Derived from the two controls' painted boxes rather than from a literal, so
/// it stays true if either control moves.
double _clusterWidth(WidgetTester tester) {
  final wallet = tester.getRect(find.byType(WalletPill));
  final menu = tester.getRect(find.byType(HeaderMenuButton));
  return menu.right - wallet.left;
}

/// The wallet control's semantic label - the only place this header names a
/// wallet or a chain in words since scheme F removed the name column.
String _walletSemanticLabel(WidgetTester tester) {
  final labelled = tester
      .widgetList<Semantics>(
        find.descendant(
          of: find.byType(WalletPill),
          matching: find.byType(Semantics),
        ),
      )
      .where((s) => s.properties.label != null);
  return labelled.first.properties.label!;
}

/// The brand mark, found by the asset it actually loads rather than by
/// position - so swapping the image out is a deliberate act that fails here.
Finder get _markFinder => find.byWidgetPredicate(
  (w) =>
      w is Image &&
      w.image is AssetImage &&
      (w.image as AssetImage).assetName.contains('geniusappbarlogo.png'),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('the wordmark renders exactly once, as live text', (
    tester,
  ) async {
    await _pumpHeader(tester, wallet: _wallet('Main'));

    // GNUS.AI, matching the splash and wallet-creation screens, which render
    // the same string from `logo_and_title.png` and are untouched by this
    // change. One brand string across the app, by construction.
    expect(find.text('GNUS.AI'), findsOneWidget);
  });

  testWidgets('the brand mark renders exactly once', (tester) async {
    await _pumpHeader(tester, wallet: _wallet('Main'));

    expect(_markFinder, findsOneWidget);
  });

  testWidgets(
    'NO network dropdown is mounted in the phone header. Two affordances for '
    'one question become one; the network moved inside the sheet the pill '
    'opens',
    (tester) async {
      await _pumpHeader(tester, wallet: _wallet('Main'));

      expect(find.byType(NetworkDropdownSelector), findsNothing);
      // TWO controls remain as of sketch 183 scheme F - the wallet chip and
      // the hamburger - and the point that survives the count change is that
      // NEITHER of them is a second network affordance. The network is named
      // in the wallet control's semantic label and shown as text on the chips
      // inside the sheet it opens; nothing in this bar duplicates it.
      expect(find.byType(WalletPill), findsOneWidget);
      expect(find.byType(HeaderMenuButton), findsOneWidget);
    },
  );

  testWidgets(
    'BOTH header controls measure exactly 44 x 44, despite carrying different '
    'decorations. This is the assertion sketch 183 asked for and the one 181 '
    'could not make, because before scheme F there was only one treatment',
    (tester) async {
      await _pumpHeader(tester, wallet: _wallet('Main'));

      expect(
        tester.getSize(find.byType(WalletPill)),
        const Size.square(kHeaderControlSize),
      );
      expect(
        tester.getSize(find.byType(HeaderMenuButton)),
        const Size.square(kHeaderControlSize),
        reason:
            'Material 3 gives IconButton a 48px minimum AND '
            'MaterialTapTargetSize.padded. A 48 here is one of those defaults '
            'coming back, and it breaks the cluster at 112 instead of 100',
      );
    },
  );

  testWidgets('THE BRAND DOES NOT SHRINK: the lockup is the same width under a '
      '4-character name and a 60-character one, and under scheme F the whole '
      'right-hand cluster is name-INDEPENDENT. If the brand shrank, GNUS.AI '
      'would truncate to GNUS... and read as broken', (tester) async {
    await _pumpHeader(tester, wallet: _wallet('Main'));
    final shortBrand = tester.getSize(find.byType(BrandLockup)).width;
    final shortPill = tester.getSize(find.byType(WalletPill)).width;
    final shortCluster = _clusterWidth(tester);

    await _pumpHeader(tester, wallet: _wallet('N' * 60));
    final longBrand = tester.getSize(find.byType(BrandLockup)).width;
    final longPill = tester.getSize(find.byType(WalletPill)).width;
    final longCluster = _clusterWidth(tester);

    expect(longBrand, shortBrand);

    // STRICTER THAN WHAT IT REPLACED, and worth being explicit about. This
    // pair used to read `pill <= kWalletPillMaxWidth` plus
    // `longPill > shortPill`: the pill GREW with the name and the test
    // proved it stopped at a ceiling. Scheme F removed the name, so the
    // right side no longer varies with it AT ALL, and that is a stronger
    // statement of the same invariant - the brand cannot be squeezed by a
    // name because a name can no longer take any width.
    expect(shortPill, kHeaderControlSize);
    expect(longPill, kHeaderControlSize);
    expect(shortCluster, moreOrLessEquals(100.0, epsilon: 0.01));
    expect(longCluster, moreOrLessEquals(100.0, epsilon: 0.01));
  });

  testWidgets(
    'the header prints NO address. A wallet whose NAME is an address renders '
    'that string once, as an odd name, instead of twice as a bug - the old '
    'header printed walletName over the truncated address, and on a wallet '
    'imported through the free-text name field those were the same value',
    (tester) async {
      const address = '0xAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA';
      await _pumpHeader(tester, wallet: _wallet(address));

      // The truncated display form is what the second line used to render.
      final truncated = WalletUtils.getAddressForDisplay(address);
      expect(truncated, '0xAAAA...AAAA');
      expect(find.text(truncated), findsNothing);
      expect(find.textContaining('...'), findsNothing);
      // Scheme F makes this pass trivially - the header prints no name at
      // all now - so the case is strengthened rather than left to rot: NO
      // Text widget whatsoever is mounted inside the wallet control.
      expect(
        find.descendant(
          of: find.byType(WalletPill),
          matching: find.byType(Text),
        ),
        findsNothing,
        reason:
            'any text back inside this control is the name column returning, '
            'and with it the address-shaped-name defect scheme F removed from '
            'the bar',
      );
    },
  );

  testWidgets(
    'with no wallet the control shows the plus glyph and is still tappable, '
    'because the sheet it opens is where Add Wallet lives. The "No wallet" '
    'STRING is gone with scheme F, so the semantic label carries it instead',
    (tester) async {
      await _pumpHeader(tester, wallet: null);

      expect(
        find.descendant(
          of: find.byType(WalletPill),
          matching: find.byIcon(Icons.add),
        ),
        findsOneWidget,
      );

      final inkWell = tester.widget<InkWell>(
        find.descendant(
          of: find.byType(WalletPill),
          matching: find.byType(InkWell),
        ),
      );
      expect(inkWell.onTap, isNotNull);

      // THE ONLY TEXTUAL IDENTITY LEFT IN THIS HEADER, which is why all three
      // branches are pinned here rather than sampled. A sighted user now reads
      // a picture; a VoiceOver user still hears the wallet and the chain. If
      // this string drifts, the header identifies nothing to anyone.
      expect(
        _walletSemanticLabel(tester),
        'No wallet selected. Opens wallet and network',
      );
    },
  );

  testWidgets(
    'the semantic label names the wallet when there is no network, and both '
    'the wallet and the chain when there is',
    (tester) async {
      await _pumpHeader(tester, wallet: _wallet('Main'), network: null);
      expect(_walletSemanticLabel(tester), 'Main. Opens wallet and network');

      await _pumpHeader(tester, wallet: _wallet('Main'));
      expect(
        _walletSemanticLabel(tester),
        'Main, on Testchain. Opens wallet and network',
      );
    },
  );

  testWidgets('the app bar has a real bottom edge: 1px borderStrong, not 0.5px '
      'borderSubtle. A brand block turns the bar into a band, and a band with '
      'no edge floats', (tester) async {
    await _pumpHeader(tester, wallet: _wallet('Main'));

    final appBar = tester.widget<AppBar>(find.byType(AppBar));
    final border = appBar.shape as Border;
    expect(border.bottom.width, 1.0);
    expect(border.bottom.color, GWColors.dark().borderStrong);
    // The token it is NOT, and must not become: borderControl is reserved
    // by its own doc for the edge of a control whose fill cannot identify
    // it. That is the pill, not a decorative separator.
    expect(border.bottom.color, isNot(GWColors.dark().borderControl));
  });

  // -------------------------------------------------------------------------
  // The 2026-08-07 growth: mark 24 -> 28, wordmark 15 -> 18.
  //
  // Jakub asked for the brand to be bigger and for NOTHING else in the header
  // to move: make only the logo and the wordmark bigger for now, leave the
  // wallet and the alignment alone. These cases pin the two sizes so an
  // accidental revert to 24/15, or a creep to 32/20, fails loudly instead of
  // silently.
  // -------------------------------------------------------------------------

  testWidgets('the mark renders at 28, the ceiling this 38px asset supports', (
    tester,
  ) async {
    await _pumpHeader(tester, wallet: _wallet('Main'));

    expect(
      tester.widget<Image>(_markFinder).height,
      28,
      reason:
          'a 24 here is the 2026-08-07 growth reverted; a 32 is a 2.53x '
          'upscale from the 38px source, which is where the smear on an '
          'intricate line drawing stops reading as antialiasing. Going past 28 '
          'needs the 114x114 re-export first, not a bigger number',
    );
  });

  testWidgets('the wordmark grows WITH the mark, at 18', (tester) async {
    await _pumpHeader(tester, wallet: _wallet('Main'));

    // A mark that outgrows its text is the failure mode the proportional bump
    // exists to prevent, so the two are asserted together. 18 is also a step ON
    // the type scale (`titleLg`'s size), which 17 is not.
    expect(tester.widget<Text>(find.text('GNUS.AI')).style?.fontSize, 18);
    expect(tester.widget<Image>(_markFinder).height, 28);
  });

  testWidgets('the wallet control is still exactly 44 x 44 after the growth', (
    tester,
  ) async {
    await _pumpHeader(tester, wallet: _wallet('Main'));

    final Size pill = tester.getSize(find.byType(WalletPill));
    final double lockup = tester.getSize(find.byType(BrandLockup)).width;
    // Observable in CI output rather than only in a plan document. The LOCKUP
    // here is a HARNESS width, not a device width - the test font is not Inter
    // - so it is printed and not asserted. The control's own size is
    // font-independent, so it is asserted.
    debugPrint('HEADER | harness lockup=$lockup pill=${pill.width}');

    expect(pill, const Size.square(kHeaderControlSize));
  });

  testWidgets(
    'REAL INTER, 390pt: the lockup measures 106.06 and the F cluster measures '
    'exactly 100.00, leaving 135.94 free where the pill left 12.00',
    (tester) async {
      // The one place this file departs from its no-absolute-widths rule, and
      // it earns the exception: the whole question the 2026-08-07 growth raises
      // is a question about Inter's advances, which the harness face cannot
      // answer. Loading the real faces is the same escape hatch
      // `assets_header_scheme_a_test.dart` and
      // `compute_balance_unit_track_test.dart` use.
      //
      // A 60-character name, so if ANY part of the right side still varied
      // with the name the equalities below would catch it.
      await _loadInter();
      await _pumpHeader(tester, wallet: _wallet('N' * 60));

      final double lockup = tester.getSize(find.byType(BrandLockup)).width;
      final double pill = tester.getSize(find.byType(WalletPill)).width;
      final double menu = tester.getSize(find.byType(HeaderMenuButton)).width;
      final double cluster = _clusterWidth(tester);
      final double gap =
          tester.getRect(find.byType(HeaderMenuButton)).left -
          tester.getRect(find.byType(WalletPill)).right;

      // `AppBar` charges `titleSpacing` on BOTH sides of the title:
      // `NavigationToolbar` lays its middle slot out at
      // `width - leading - trailing - middleSpacing * 2`. Getting this wrong by
      // one titleSpacing is what made an earlier budget for this header read
      // 16px too generous, so the term is spelled out rather than folded in.
      const double titleRow = 390 - 2 * GeniusWalletConsts.space8 - 16;
      // Everything in the title Row that is neither the lockup nor the
      // cluster. It INCLUDES the space6 separator between them, which is the
      // same definition sketch 183's held-constant table uses: the pill era
      // measured `342 - 106.06 - 223.94` = 12.00, all separator and no slack.
      final double free = titleRow - lockup - cluster;
      debugPrint(
        'HEADER | real Inter 390pt lockup=$lockup titleRow=$titleRow '
        'pill=$pill menu=$menu gap=$gap cluster=$cluster free=$free',
      );

      expect(
        lockup,
        moreOrLessEquals(106.06, epsilon: 0.05),
        reason:
            'mark box (29/38 * 28 = 21.37) + space4 + GNUS.AI at Inter Bold 18 '
            '(76.69). A 90.23 here is the growth reverted to 24/15; a 109.11 '
            'is the mark crept to 32',
      );

      // THE BUDGET UNDER SCHEME F, as equalities where the pill era had
      // inequalities. The right side is a fixed 100.00 and the free space in
      // the title Row grew from 12.00 to 135.94.
      expect(pill, kHeaderControlSize);
      expect(menu, kHeaderControlSize);
      expect(gap, moreOrLessEquals(GeniusWalletConsts.space6, epsilon: 0.01));
      expect(
        cluster,
        moreOrLessEquals(100.0, epsilon: 0.01),
        reason:
            '44 + space6 + 44. A 112 here is a second space6 added after the '
            'hamburger, which sketch 183 does NOT have - its held-constant '
            'table pins the cluster at 100.00 and the free space at 135.94',
      );
      expect(
        free,
        moreOrLessEquals(135.94, epsilon: 0.05),
        reason:
            'was 12.00 under the pill, which was 12.00 of separator and zero '
            'slack. 135.94 is 12.00 of separator plus 123.94 of genuine slack',
      );

      // WHERE `expect(pill, greaterThan(180))` STOOD, and why it is not here.
      //
      // Its stated reason was "the pill must stay wide enough to be the header
      // control it is: avatar + a readable name + the chevron". Scheme F
      // deletes the name and the chevron, so the assertion's SUBJECT no longer
      // exists - keeping it would mean keeping a 180px control that F was
      // picked to remove. It is not relaxed, skipped or weakened; it is the
      // only deletion in this change, and `expect(pill, kHeaderControlSize)`
      // above is its stricter replacement in form though a different statement
      // in substance.
    },
  );

  // -------------------------------------------------------------------------
  // Sketch 183 scheme F: the two treatments, and what the hamburger reaches.
  // -------------------------------------------------------------------------

  testWidgets(
    'NEITHER CONTROL CARRIES A CONTAINER: scheme C, so the wallet and the '
    'hamburger are both bare and the glyphs alone carry 1.4.11',
    (tester) async {
      await _pumpHeader(tester, wallet: _wallet('Main'));

      // The wallet's chip went on 2026-08-07. What did NOT go is the Material
      // itself: with a transparent colour it still clips the InkWell ripple,
      // and dropping it would paint the splash as an unclipped rectangle. So
      // this asserts "transparent and round", not "absent" - the distinction
      // is the whole reason the widget survives its own decoration.
      final material = tester.widget<Material>(
        find
            .descendant(
              of: find.byType(WalletPill),
              matching: find.byType(Material),
            )
            .first,
      );
      expect(material.color, Colors.transparent, reason: _splitReason);
      expect(material.clipBehavior, Clip.antiAlias);
      final shape = material.shape;
      expect(shape, isA<CircleBorder>(), reason: _splitReason);
      expect(
        (shape as OutlinedBorder).side.style,
        BorderStyle.none,
        reason: _splitReason,
      );

      // The hamburger paints NOTHING of its own. Its `Material` is
      // `MaterialType.transparency` with a null colour and no border side, and
      // there is no Container or DecoratedBox inside it.
      expect(
        find.descendant(
          of: find.byType(HeaderMenuButton),
          matching: find.byType(Container),
        ),
        findsNothing,
        reason: _splitReason,
      );
      expect(
        find.descendant(
          of: find.byType(HeaderMenuButton),
          matching: find.byType(DecoratedBox),
        ),
        findsNothing,
        reason: _splitReason,
      );
      for (final m in tester.widgetList<Material>(
        find.descendant(
          of: find.byType(HeaderMenuButton),
          matching: find.byType(Material),
        ),
      )) {
        expect(
          m.color == null || m.color == Colors.transparent,
          isTrue,
          reason: _splitReason,
        );
        final s = m.shape;
        if (s is OutlinedBorder) {
          expect(s.side.style, BorderStyle.none, reason: _splitReason);
        }
      }
    },
  );

  testWidgets(
    'THE HAMBURGER REACHES WHAT LEFT THE BAR. `More` was removed from the '
    'bottom bar in the SAME change that added this button, and these four '
    'rows are exactly what would otherwise have been stranded on the phone - '
    'Settings included',
    (tester) async {
      await _pumpHeader(tester, wallet: _wallet('Main'));

      await tester.tap(find.byType(HeaderMenuButton));
      await tester.pumpAndSettle();

      expect(find.byType(MoreSheetBody), findsOneWidget);

      // Read the labels from `moreDestinations` rather than typing them out.
      // The literal list this used to hold said `Web`, which does not exist on
      // every platform - `nav_destinations.dart:67` declares it
      // `visible: !Platform.isLinux`, and CI's quality job runs on Linux. The
      // test passed on a Mac and failed in CI for a reason that was about the
      // runner, not the code.
      //
      // A `if (!Platform.isLinux)` guard would also have worked and is what
      // `mobile_nav_destinations_test.dart` does, but that spreads one
      // platform rule across two files. Deriving keeps the rule in one place:
      // if another destination ever becomes conditional, this assertion
      // follows it with no edit, while still failing loudly if the SHEET stops
      // showing what the model says it holds.
      for (final label in moreDestinations.map((d) => d.label)) {
        expect(
          find.text(label),
          findsOneWidget,
          reason:
              '$label is in moreDestinations but the sheet did not render it. '
              'On the phone this sheet is the ONLY entrance to these, so a '
              'missing row is a stranded destination, not a cosmetic gap',
        );
      }
      // Settings is named explicitly on top of the loop above. It is the one
      // whose loss would be worst and the one the whole change exists to keep
      // reachable, so it gets an assertion that does not depend on the
      // derivation being right.
      expect(find.text('Settings'), findsOneWidget);
      // The row the sheet body appends by hand, which is not derived.
      expect(find.text('Accounts'), findsOneWidget);
    },
  );

  testWidgets('the hamburger glyph is Icons.menu at 24', (tester) async {
    await _pumpHeader(tester, wallet: _wallet('Main'));

    final icon = tester.widget<Icon>(
      find.descendant(
        of: find.byType(HeaderMenuButton),
        matching: find.byType(Icon),
      ),
    );
    expect(icon.icon, Icons.menu);
    // Raised 18 to 24 on device, 2026-08-07: Jakub asked to keep the larger
    // menu glyph and change nothing else. The original 18 was matched to the
    // caret scheme F had just deleted from the wallet control, so it was sized
    // against a glyph that no longer exists.
    //
    // This DOES move sketch 183's ink-gap figure, and the move is intended
    // rather than overlooked: the gap is `(44 - glyph) / 2`, so the glyph
    // stops 10 inside its box rather than 13 and F's apparent separation is
    // `12 + 10 = 22` rather than 25. What must NOT move is the hit box or the
    // cluster, both asserted elsewhere in this file at 44 and 100.00.
    expect(icon.size, 24);
  });

  testWidgets(
    'DYNAMIC TYPE: the header raises no overflow at textScaler 1.0, 2.0, 2.5 '
    'or 3.0',
    (tester) async {
      // The cluster is a FIXED 100 and non-flex, so on paper the Expanded
      // holding it starves once the lockup passes 230 - wordmark > 200.63, or
      // textScaler above 2.616x, which iOS AX5 reaches. Before scheme F that
      // could not happen: the pill WAS the Expanded and absorbed shrink down
      // to its own chrome, producing an ellipsis rather than an overflow.
      //
      // MEASURED, AND THE PREDICTION DID NOT HOLD. `AppBar` clamps its title's
      // text scaling at 1.34x (`app_bar.dart:1098`, `_kMaxTitleTextScaleFactor
      // = 1.34`), so the wordmark tops out at 76.69 * 1.34 = 102.77 and the
      // lockup at 132.14. The Expanded therefore receives 197.86 against the
      // 100 the cluster needs, at every ambient scale. Probed at 1.0 / 1.34 /
      // 2.0 / 2.5 / 3.0 / 3.5 with the cap at BOTH 216 and 196: no overflow at
      // any step under either, and the effective scaler inside the title reads
      // 1.34x from 1.34 upward. The cap stayed at 216 on that evidence.
      //
      // This case is therefore a guard on the clamp as much as on the cluster:
      // it reddens if the lockup is ever mounted outside an `AppBar.title`.
      await _loadInter();
      for (final scale in const <double>[1.0, 2.0, 2.5, 3.0]) {
        await _pumpHeader(tester, wallet: _wallet('Main'), textScale: scale);

        expect(
          tester.takeException(),
          isNull,
          reason: 'the header overflowed at textScaler $scale',
        );
        // The clamp itself, asserted rather than relied on silently.
        expect(
          MediaQuery.of(
            tester.element(find.text('GNUS.AI')),
          ).textScaler.scale(100),
          lessThanOrEqualTo(134.0),
          reason:
              'AppBar clamps the title at 1.34x. Without that clamp the '
              'lockup passes 230 at about 2.616x and the fixed 100px cluster '
              'starves the Expanded',
        );
        // Both controls hold their box at every scale, which is the other way
        // this could have failed: a scaling glyph growing inside a fixed 44.
        expect(
          tester.getSize(find.byType(WalletPill)),
          const Size.square(kHeaderControlSize),
        );
        expect(
          tester.getSize(find.byType(HeaderMenuButton)),
          const Size.square(kHeaderControlSize),
        );
      }
    },
  );
}

/// Why the hamburger has no container, quoted at every assertion that pins it
/// so a "consistency" edit reads the reason in the failure output.
const String _splitReason =
    'NEITHER control carries a container - sketch 183 scheme C, chosen on '
    'device 2026-08-07. Adding a stadium here is scheme A, which lost because '
    'two identical stadiums 12px apart read as a SEGMENTED CONTROL - one '
    'object with two halves rather than two objects. Scheme F, the shipped '
    'predecessor, kept a chip on the WALLET only; C removes that one too and '
    'never adds one here';

/// Loads the real Inter faces for the one case that measures device widths.
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
