// The flip control must sit on the SEAM between the two swap amount cards, in
// every state - not only when the two cards happen to render at the same
// height.
//
// The arithmetic of the bug this file exists for. The old layout was a
// `Stack(alignment: Alignment.center)` wrapping a `Column` of both cards, with
// the control as the Stack's second child. The Stack's height is therefore
// `payH + gap + receiveH`, so `Alignment.center` puts the control's centre at:
//
//     (payH + gap + receiveH) / 2
//
// The seam's own midpoint is:
//
//     payH + gap / 2
//
// Subtract one from the other and the drift is `(receiveH - payH) / 2`, exactly
// half the height difference. A taller PAY card therefore pulls the control UP,
// which is precisely what was reported on the 2026-07-31 walk
// ("zostaje w miejscu lub przesuwa sie do gory").
//
// What actually makes the pay card taller is token SELECTION, not typing. With
// `selectedToken != null` the token pill gains a 32x32 logo and the right-hand
// column overtakes the 38px hero amount slot; the MAX chip is pay-side-only by
// construction (`swap_field.dart:63`); and the fiat sub-line needs a token plus
// a known price. The `TextField` is single-line and scrolls horizontally, so
// the digits themselves change nothing. An amount is still typed below, because
// that is the state that was reported and it must be proven, not assumed away.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/ffi/trust_wallet_api_ffi.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/providers/network_tokens_provider.dart';
import 'package:genius_wallet/squid_router/swap_field.dart';
import 'package:genius_wallet/squid_router/swap_screen.dart';
import 'package:genius_wallet/squid_router/swap_seam.dart';
import 'package:genius_wallet/squid_router/token_flip_button.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';

/// `WalletDetailsCubit` takes a `GeniusApi` this screen never touches. The only
/// wallet state `SwapScreen` reads is `selectedWallet?.address` (force-unwrapped
/// in `_loadTokens`) and, inside the submit handler alone, `swapParams`. The
/// same four-line stand-in the coin-page and transactions-frame tests use: it
/// satisfies the type and throws loudly rather than returning a silent null.
class _UnusedApi implements GeniusApi {
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

/// Seeds `WalletDetailsCubit.state` directly after construction, the pattern
/// `test/dashboard/compute_panel_wiring_test.dart` established.
///
/// `selectedNetwork` is deliberately left null: `fetchBalances` ignores its
/// `chainIds` argument entirely and returns `mockSquidBalances` regardless, so
/// seeding a network would add a fixture the screen does not read.
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

Widget _host(Widget child) => BlocProvider<WalletDetailsCubit>(
  create: (_) => _SeededWalletDetailsCubit(
    geniusApi: _UnusedApi(),
    networkTokensProvider: NetworkTokensProvider(),
    selectedWallet: _wallet,
  ),
  child: MaterialApp(
    theme: ThemeData(extensions: [GWColors.dark()]),
    home: Scaffold(body: child),
  ),
);

/// A deterministic surface wide enough that the 560px capped column is not
/// squeezed and tall enough that the whole form fits without scrolling.
void _sizeSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(1200, 1400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

/// Mounts the screen and drives it past its `isLoading` gate with explicit
/// pumps. NOT `pumpAndSettle`: `Loading()` may animate forever, and
/// `pumpAndSettle` would hang the suite rather than fail it.
Future<void> _mount(WidgetTester tester, Widget screen) async {
  await tester.pumpWidget(_host(screen));
  await tester.pump();
  await tester.pump();
}

/// The midpoint of the gap between the two cards, measured from the real
/// laid-out rects rather than from any constant.
double _seamY(WidgetTester tester) {
  final pay = tester.getRect(find.byType(SwapField).at(0));
  final receive = tester.getRect(find.byType(SwapField).at(1));
  return (pay.bottom + receive.top) / 2;
}

/// The control's centre. Taken as a CENTRE, not a rect edge: `TokenFlipButton`
/// wraps its content in `AnimatedRotation`, and a rotation about the centre
/// leaves the centre fixed while it very much does move the corners.
double _controlCentreY(WidgetTester tester) =>
    tester.getCenter(find.byType(TokenFlipButton)).dy;

void main() {
  testWidgets('A: at rest the control is centred on the seam', (tester) async {
    _sizeSurface(tester);
    await _mount(tester, const SwapScreen());

    expect(find.byType(SwapField), findsNWidgets(2));
    expect(
      _controlCentreY(tester),
      closeTo(_seamY(tester), 0.5),
      reason:
          'With both cards empty they render at equal heights, so even the '
          'old bounding-box centring landed on the seam. This test passed '
          'before the fix and must keep passing after it.',
    );
  });

  testWidgets('B: with a pay token seated and an amount typed, the control is '
      'still centred on the seam', (tester) async {
    _sizeSurface(tester);
    // ETH on chainId 1 holds 1 ETH in `mockSquidBalances`, and
    // `resolvePreselection` seats a HELD token on the pay side.
    await _mount(
      tester,
      const SwapScreen(preselectSymbol: 'ETH', preselectChainId: 1),
    );

    // `.first` is the You Pay card's amount field - the two cards are built in
    // document order and the receive side has no `emptyPlaceholder` here
    // (`routeError` is false), so both render a real `TextField`.
    await tester.enterText(find.byType(TextField).first, '1.5');
    await tester.pump();
    // Past the 500ms `_debouncedFetchRoute` window, so the test does not end on
    // a pending timer. `_fetchRoute` returns early anyway (`canSwap` is false
    // with no receive token), so nothing below the cards changes.
    await tester.pump(const Duration(milliseconds: 600));

    final pay = tester.getRect(find.byType(SwapField).at(0));
    final receive = tester.getRect(find.byType(SwapField).at(1));

    // This assertion guards the test itself, and it runs BEFORE the centring
    // one on purpose.
    expect(
      pay.height,
      greaterThan(receive.height),
      reason:
          'The fixture failed to make the pay card taller than the receive '
          'card. Without an asymmetric pair this test is a duplicate of Test A '
          'and proves nothing whatsoever about the bug: the drift is exactly '
          'half the height difference, so at equal heights even a broken '
          'layout is centred on the seam. Fix the fixture before trusting a '
          'green result here.',
    );

    expect(
      _controlCentreY(tester),
      closeTo(_seamY(tester), 0.5),
      reason:
          'pay=${pay.height} receive=${receive.height} '
          'seam=${_seamY(tester)} control=${_controlCentreY(tester)}',
    );
  });

  testWidgets('C: the control is tappable 2px inside both its top and its '
      'bottom edge', (tester) async {
    // Passes BEFORE the fix as well. It is here because two of the three
    // approaches considered for the fix (an overflowing wrapper inside the
    // Column, a zero-height `Align`) would have silently made these two points
    // untappable: `RenderBox.hitTest` gates everything behind
    // `_size.contains(position)`, so a child painted outside its parent's box
    // answers no hit there, and `RenderFlex` would have handed the top 14px to
    // the pay card's `TextField` instead.
    _sizeSurface(tester);
    await _mount(
      tester,
      const SwapScreen(preselectSymbol: 'ETH', preselectChainId: 1),
    );
    await tester.enterText(find.byType(TextField).first, '1.5');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    String? symbolOn(int index) => tester
        .widget<SwapField>(find.byType(SwapField).at(index))
        .selectedToken
        ?.symbol;

    expect(symbolOn(0), 'ETH');
    expect(symbolOn(1), isNull);

    // Tap 2px below the top edge.
    final beforeFirst = tester.getRect(find.byType(TokenFlipButton));
    await tester.tapAt(beforeFirst.topCenter + const Offset(0, 2));
    await tester.pump();
    // Past the 400ms `AnimatedRotation` and the 500ms route debounce the flip
    // kicks off, so neither is left pending.
    await tester.pump(const Duration(milliseconds: 600));

    expect(
      symbolOn(0),
      isNull,
      reason: 'A tap 2px inside the top edge did not flip the tokens.',
    );
    expect(symbolOn(1), 'ETH');

    // Re-measure: the flip moved the token to the receive side, which under the
    // OLD layout also moved the control. Reusing the stale rect would test a
    // point that is no longer on the button.
    final beforeSecond = tester.getRect(find.byType(TokenFlipButton));
    await tester.tapAt(beforeSecond.bottomCenter - const Offset(0, 2));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(
      symbolOn(0),
      'ETH',
      reason: 'A tap 2px inside the bottom edge did not flip the tokens back.',
    );
    expect(symbolOn(1), isNull);
  });

  testWidgets('D: SwapSeam centres its control on the boundary at a 10x height '
      'difference', (tester) async {
    // A 40px card above a 400px card is not a realistic swap state, and that is
    // exactly the point: it is the case an offset tuned to today's cards cannot
    // survive. At equal heights every wrong layout looks right.
    _sizeSurface(tester);
    const payKey = Key('seam-pay');
    const receiveKey = Key('seam-receive');
    const controlKey = Key('seam-control');

    await tester.pumpWidget(
      _host(
        SwapSeam(
          gap: GeniusWalletConsts.space8,
          payCard: const SizedBox(key: payKey, height: 40),
          receiveCard: const SizedBox(key: receiveKey, height: 400),
          control: const SizedBox(key: controlKey, width: 44, height: 44),
        ),
      ),
    );

    final pay = tester.getRect(find.byKey(payKey));
    final receive = tester.getRect(find.byKey(receiveKey));
    expect(
      tester.getCenter(find.byKey(controlKey)).dy,
      closeTo((pay.bottom + receive.top) / 2, 0.5),
    );
  });
}
