// The `/swap` PAGE HEADER: the only centred one in the app, and the only one
// whose trailing rides the title's line rather than the whole identity block.
//
// Two decisions live in this file and neither may quietly eat the other.
//
//  * **Jakub, 2026-07-26 - CENTRED, at every width.** The form sits in a 560px
//    column; a title in the page's left gutter agreed with nothing on screen.
//    Left-alignment on the phone was tried on 2026-08-10 - the argument being
//    that at 390 the column IS the page, and that every other tab reads left -
//    and rejected on device the same hour, subtitle included. The centring
//    cases below are the successor to that experiment's assertions: if they
//    fail because someone re-inset the title, the answer is that it was
//    already tried.
//  * **Jakub, 2026-08-10 - the settings glyph on the TITLE's line**, the way
//    `/transactions` puts its filter trigger on the "Transactions" line. That
//    request was never withdrawn and survives the revert above.
//
// **Measured, not eyeballed**, because both are the kind of defect that looks
// fine in a screenshot: before the fix the glyph's centre sat at y=62 against
// a title centre of y=40 - 22px low, because `GWPageHeader` lays a plain
// `trailing` out beside the WHOLE identity block (title + `space2` + subtitle)
// rather than on the title's own line.
//
// **This file pumps the REAL screens**, both of them, for the reason
// `transactions_page_frame_test.dart` states: a hand-copied replica of the
// frame cannot fail when the frame changes.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/ffi/trust_wallet_api_ffi.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/coin.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/components/scaffold/gw_page_header.dart';
import 'package:genius_wallet/dashboard/assets/assets_screen.dart';
import 'package:genius_wallet/providers/network_tokens_provider.dart';
import 'package:genius_wallet/squid_router/swap_screen.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';

const String _title = 'Swap';
const String _subtitle = 'Trade any token across chains';

/// `WalletDetailsCubit` takes a `GeniusApi` neither screen here touches - the
/// same four-line stand-in `swap_flip_centring_test.dart` and
/// `transactions_page_frame_test.dart` both use. It satisfies the type and
/// throws loudly rather than returning a silent null.
class _UnusedApi implements GeniusApi {
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

/// Seeds `WalletDetailsCubit.state` after construction, the pattern
/// `swap_flip_centring_test.dart` established. `SwapScreen._loadTokens`
/// force-unwraps `selectedWallet!.address`, so a wallet is not optional here.
class _SeededWalletDetailsCubit extends WalletDetailsCubit {
  _SeededWalletDetailsCubit({
    required super.geniusApi,
    required super.networkTokensProvider,
    required Wallet selectedWallet,
  }) {
    emit(state.copyWith(selectedWallet: selectedWallet));
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

Widget _swapHost() => BlocProvider<WalletDetailsCubit>(
  create: (_) => _SeededWalletDetailsCubit(
    geniusApi: _UnusedApi(),
    networkTokensProvider: NetworkTokensProvider(),
    selectedWallet: _wallet,
  ),
  child: MaterialApp(
    theme: ThemeData(extensions: [GWColors.dark()]),
    home: const SwapScreen(),
  ),
);

/// The `/assets` page, the reference every other page title is measured
/// against - the same host `transactions_page_frame_test.dart` uses for the
/// same comparison, one coin so the header sits above a funded wallet.
Widget _assetsHost() => BlocProvider(
  create: (_) => WalletDetailsCubit(
    initialState: const WalletDetailsState(
      coins: [Coin(name: 'GeniusAI', symbol: 'GNUS', iconPath: '', balance: 1)],
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
  await tester.pumpWidget(_swapHost());
  await tester.pump();
  await tester.pump();
}

Rect _header(WidgetTester tester) => tester.getRect(find.byType(GWPageHeader));

/// The settings control's box. `IconButton`, not the glyph: the box is the tap
/// target and the thing the header's `Stack` actually lays out, and the glyph
/// is centred in it either way.
Rect _trigger(WidgetTester tester) => tester.getRect(find.byType(IconButton));

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
  // "centred over the form" means, and it is what the 2026-07-26 decision
  // bought. A title inset into the column's left edge - the 2026-08-10
  // experiment - puts `title.center.dx` roughly a third of the way across and
  // fails here, which is the point.
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
  // Was 62 against a title centre of 40. Within a pixel, not "roughly": both
  // sit in one `Alignment.centerRight` Stack over the title line now, so they
  // are equal by construction and any drift means the trailing left it.
  expect(
    trigger.center.dy,
    moreOrLessEquals(title.center.dy, epsilon: 1),
    reason: 'trigger=${trigger.center.dy} title=${title.center.dy} at $where',
  );

  // And it must not have bought that by growing the header. A `Stack` is as
  // tall as its tallest child, so a 48-tall trigger would centre on the title
  // just as well while making the title line 48 and pushing "Swap" 8px down
  // its own header - measured exactly that: a 108px header with its title at
  // y=32, against 92 and y=24 here.
  expect(title.top, header.top, reason: 'the title owns the header top');
  expect(trigger.size, const Size(48, 32), reason: 'trigger box at $where');

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
    // is genuinely narrower than the frame - the situation the 2026-07-26
    // centring decision was about. Nothing in this header switches on the
    // width any more, and these assertions are how that stays true.
    _surface(tester, 1400, 1000);
    await _mountSwap(tester);

    _expectCentredHeaderWithGlyphOnTitle(tester, '1400');
    expect(tester.takeException(), isNull);
  });

  testWidgets('phone: the title sits at the same Y as the Assets title', (
    tester,
  ) async {
    // **Jakub, 2026-08-10, the load-bearing half of this file.** The title
    // must land on the same line as every other page's, and Swap is the one
    // page that could miss: it is the only header with a subtitle AND a
    // trailing, so anything that grows its title line moves the title down
    // while Assets and Transactions stay put. The 48x48 trigger did exactly
    // that - Swap's title at y=32 against Assets' y=24.
    //
    // Both screens are pumped HERE rather than the number being copied from
    // `transactions_page_frame_test.dart`, so this is a comparison and not two
    // literals that can drift apart silently. It is the ABSOLUTE y, not an
    // offset into the header: the two pages share a gutter
    // (`GeniusBreakpoints.pageTitleGap`) and the whole question is whether
    // they still land on the same screen pixel through it.
    _surface(tester, 390);
    await _mountSwap(tester);
    final Rect swapTitle = tester.getRect(find.text(_title));

    await tester.pumpWidget(_assetsHost());
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
