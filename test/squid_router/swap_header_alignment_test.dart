// The `/swap` page header is centred at every width. Its settings glyph sits
// on the title's line, in a tap target that is 48x48 on touch platforms and
// 48x32 with a mouse, pinned to the top-right of the title+subtitle block so
// the header does not grow. The real Swap and Assets screens are pumped
// because a hand-copied replica cannot fail when the frame changes.
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/ffi/trust_wallet_api_ffi.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/coin.dart';
import 'package:genius_api/models/network.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/components/scaffold/gw_page_header.dart';
import 'package:genius_wallet/dashboard/assets/assets_screen.dart';
import 'package:genius_wallet/providers/network_tokens_provider.dart';
import 'package:genius_wallet/squid_router/swap_screen.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';

import '../swap/fake_swap_provider.dart';

const String _title = 'Swap';
const String _subtitle = 'Trade any token across chains';

/// `WalletDetailsCubit` needs a `GeniusApi` neither screen touches; this
/// satisfies the type and throws loudly rather than returning a silent null.
class _UnusedApi implements GeniusApi {
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

/// The catalogue is empty: this file measures the header, not the form.
class _EmptySwapProvider extends FakeSwapProvider {
  const _EmptySwapProvider();
}

/// Seeds `WalletDetailsCubit.state` after construction. `SwapScreen._loadTokens`
/// force-unwraps `selectedWallet!.address`, so a wallet is not optional here.
class _SeededWalletDetailsCubit extends WalletDetailsCubit {
  _SeededWalletDetailsCubit({
    required super.geniusApi,
    required super.networkTokensProvider,
    required Wallet selectedWallet,
  }) {
    emit(
      state.copyWith(
        selectedWallet: selectedWallet,
        selectedNetwork: const Network(
          name: 'Ethereum',
          symbol: 'ETH',
          chainId: 1,
        ),
      ),
    );
  }
}

const _wallet = Wallet(
  coinType: TWCoinType.TWCoinTypeEthereum,
  walletName: 'Swap Wallet',
  currencySymbol: 'ETH',
  walletType: WalletType.mnemonic,
  balance: 0,
  address: '0xSWAPSWAPSWAPSWAPSWAPSWAPSWAPSWAPSWAPSWAP',
);

class _SwapHost extends StatelessWidget {
  const _SwapHost();

  @override
  Widget build(BuildContext context) => BlocProvider<WalletDetailsCubit>(
    create: (_) => _SeededWalletDetailsCubit(
      geniusApi: _UnusedApi(),
      networkTokensProvider: NetworkTokensProvider(),
      selectedWallet: _wallet,
    ),
    child: MaterialApp(
      theme: ThemeData(extensions: [GWColors.dark()]),
      home: const Scaffold(
        body: SwapScreen(swapAvailable: true, provider: _EmptySwapProvider()),
      ),
    ),
  );
}

/// The `/assets` page, the reference every other page title is measured
/// against, with one coin so the header sits above a funded wallet.
class _AssetsHost extends StatelessWidget {
  const _AssetsHost();

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => WalletDetailsCubit(
      initialState: const WalletDetailsState(
        coins: [
          Coin(name: 'GeniusAI', symbol: 'GNUS', iconPath: '', balance: 1),
        ],
        coinsStatus: WalletStatus.successful,
      ),
      geniusApi: _UnusedApi(),
      networkTokensProvider: NetworkTokensProvider(),
    ),
    child: MaterialApp(
      theme: ThemeData(extensions: [GWColors.dark()]),
      home: AssetsScreen(resolveMarketData: (_) async => const {}),
    ),
  );
}

/// Sets the window to [width] x [height] LOGICAL pixels and tears it back
/// down. A leaked surface changes every file that runs after this one.
void _surface(WidgetTester tester, double width, [double height = 844]) {
  tester.view.physicalSize = Size(width * 3, height * 3);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

/// Mounts Swap and drives it past its `isLoading` gate with explicit pumps.
/// NOT `pumpAndSettle`: `Loading()` may animate forever, and `pumpAndSettle`
/// would hang the suite rather than fail it.
Future<void> _mountSwap(WidgetTester tester) async {
  await tester.pumpWidget(const _SwapHost());
  await tester.pump();
  await tester.pump();
}

Rect _header(WidgetTester tester) => tester.getRect(find.byType(GWPageHeader));

/// The settings control's box. `IconButton`, not the glyph: the box is the tap
/// target and the thing the header's `Stack` actually lays out, and the glyph
/// is centred in it either way.
Rect _trigger(WidgetTester tester) =>
    tester.getRect(find.widgetWithIcon(IconButton, Icons.tune));

/// The three relationships the header owes at EVERY width, asserted against
/// one pumped Swap screen. [where] names the width in every failure message,
/// because the same three run at 390 and at 1400.
void _expectCentredHeaderWithGlyphOnTitle(WidgetTester tester, String where) {
  final Rect header = _header(tester);
  final Rect title = tester.getRect(find.text(_title));
  final Rect subtitle = tester.getRect(find.text(_subtitle));
  final Rect trigger = _trigger(tester);

  // ── 1. CENTRED, both lines ───────────────────────────────────────────────
  //
  // Against the header's own box, which is the focused column: that is what
  // "centred over the form" means. A title inset into the column's left edge
  // puts `title.center.dx` roughly a third of the way across and fails here.
  expect(
    title.center.dx,
    moreOrLessEquals(header.center.dx, epsilon: 0.5),
    reason: 'the title left the centre at $where',
  );
  expect(
    subtitle.center.dx,
    moreOrLessEquals(header.center.dx, epsilon: 0.5),
    reason: 'the subtitle left the centre at $where',
  );
  // The trailing must not have paid for the centring by stealing width: the
  // title centres on the FULL line, so it stays clear of the glyph.
  expect(title.right, lessThan(trigger.left), reason: 'crowded at $where');

  // ── 2. The glyph on the title's LINE ─────────────────────────────────────
  //
  // The glyph, not its 48x48 tap target, is what sits on the title line.
  final Rect glyph = tester.getRect(find.byIcon(Icons.tune));
  expect(
    glyph.center.dy,
    moreOrLessEquals(title.center.dy, epsilon: 1),
    reason: 'glyph=${glyph.center.dy} title=${title.center.dy} at $where',
  );

  // The full-size target must not push the title down its own header.
  expect(title.top, header.top, reason: 'the title owns the header top');
  // A touch target on phones; a mouse keeps the slimmer box.
  final touch = defaultTargetPlatform == TargetPlatform.android;
  expect(
    trigger.size,
    Size(48, touch ? 48 : 32),
    reason: 'tap target at $where',
  );

  // ── 3. The right EDGE, not "somewhere after the title" ───────────────────
  //
  // The centred form is not inset (`gwPageHeaderContentInset`'s own doc calls
  // this out), so the edge here is the column's own.
  expect(
    trigger.right,
    moreOrLessEquals(header.right, epsilon: 0.5),
    reason: 'the glyph left the column edge at $where',
  );
}

void main() {
  testWidgets('phone: centred title and subtitle, glyph on the title line', (
    tester,
  ) async {
    _surface(tester, 390);
    await _mountSwap(tester);

    _expectCentredHeaderWithGlyphOnTitle(tester, '390');
    expect(tester.takeException(), isNull);
  });

  testWidgets('desktop: the same three, unchanged by the width', (
    tester,
  ) async {
    // 1400: over `medium` (768), and wide enough that the 560px focused column
    // is genuinely narrower than the frame. Nothing in this header switches on
    // the width, and these assertions are how that stays true.
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    _surface(tester, 1400, 1000);
    await _mountSwap(tester);

    _expectCentredHeaderWithGlyphOnTitle(tester, '1400');
    expect(tester.takeException(), isNull);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('phone: the title sits at the same Y as the Assets title', (
    tester,
  ) async {
    // The title must land on the same line as every other page's. Swap is the
    // only header with a subtitle AND a trailing, so anything that grows its
    // title line (a full 48x48 trigger, say) moves the title down while Assets
    // stays put.
    //
    // Both screens are pumped here so this is a comparison, not two literals
    // that can drift apart. It is the ABSOLUTE y: the pages share a gutter
    // (`GeniusBreakpoints.pageTitleGap`) and must land on the same pixel.
    _surface(tester, 390);
    await _mountSwap(tester);
    final Rect swapTitle = tester.getRect(find.text(_title));

    await tester.pumpWidget(const _AssetsHost());
    await tester.pumpAndSettle();
    final Rect assetsTitle = tester.getRect(find.text('Assets'));

    expect(
      swapTitle.top,
      moreOrLessEquals(assetsTitle.top, epsilon: 0.5),
      reason: 'swap=${swapTitle.top} assets=${assetsTitle.top}',
    );
    expect(
      swapTitle.center.dy,
      moreOrLessEquals(assetsTitle.center.dy, epsilon: 0.5),
      reason: 'the two title lines must share a vertical centre',
    );
    // And the absolute number, so a change that moved BOTH pages together
    // still reddens: `pageTitleGap` on the phone, with the title on the
    // header's own first pixel.
    expect(swapTitle.top, 24);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the phone band holds, and the title yields rather than '
      'overflowing', (tester) async {
    // 767 is the last width below `medium`, 360 the narrowest phone this app
    // targets.
    //
    // The band starts at 360 and NOT at 320, and that is a measurement rather
    // than a convenience: at 320 this screen already overflows by 5.8px, in
    // the CTA's `Row` (`swap_screen.dart`), under the harness's wide fallback
    // font. Verified pre-existing by re-pumping the OLD header at 320 - same
    // 5.8px, same Row. It is not the header's, this task did not touch it, and
    // swallowing it here would hide a real one.
    for (final double width in <double>[360, 390, 430, 767]) {
      _surface(tester, width);
      await _mountSwap(tester);

      expect(tester.takeException(), isNull, reason: 'overflow at $width');
      _expectCentredHeaderWithGlyphOnTitle(tester, '$width');
    }
  });
}
