import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/genius_api.dart' show GeniusApi;
import 'package:genius_api/models/transaction.dart';
import 'package:genius_wallet/components/cards/gw_section_title.dart';
import 'package:genius_wallet/components/scaffold/gw_page_header.dart';
import 'package:genius_wallet/dashboard/home/view/dashboard_screen.dart';
import 'package:genius_wallet/dashboard/home/widgets/transactions_slim_view.dart';
import 'package:genius_wallet/dashboard/transactions/cubit/transactions_cubit.dart';
import 'package:genius_wallet/dashboard/transactions/transactions_screen.dart';
import 'package:genius_wallet/providers/network_tokens_provider.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/utils/breakpoints.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';

/// The `/transactions` PAGE FRAME: `GWPageHeader` + the `xl` width cap + the
/// gutter, as [TransactionsScreen] actually builds them.
///
/// **This file pumps the REAL screen**, not a hand-copied replica of its tree.
/// The plan proposed the replica — pump the frame's widgets directly with a
/// `TransactionsSlimView(page: true)` standing in for the bloc-fed branch — to
/// avoid the provider apparatus below. That was measured and rejected: a
/// replica cannot fail for the reason this file exists. With the replica in
/// place, changing `GeniusBreakpoints.xl` to `xxl` in `transactions_screen.dart`
/// leaves all four tests GREEN, because no test ever reads that file. The
/// apparatus that buys a real mutation is eleven lines ([_host]) and one stub
/// ([_UnusedApi]), and it also covers the two pass-throughs 15-05 added, which
/// the replica skipped entirely.
///
/// What this file still does NOT cover, for 15-06's walk to judge:
///
///  * **The SGNUS branch.** Every pump here leaves `selectedWallet` null, so
///    `isSgnusWallet` is false and [TransactionsStream] mounts. Reaching
///    [SgnusTransactionsScreen] needs an `AppBloc`, a `GeniusApi` in the tree
///    and a live stream controller — apparatus far past what a frame assertion
///    earns. Its `page` pass-through is unexercised by any automated test.
///  * **`RefreshIndicator`'s pull gesture.** Preserved untouched by this plan,
///    but which scrollable now captures the drag is a live-screen question.
///
/// Harness trap, the same one `transaction_filter_rail_test.dart` documents:
/// `flutter_test`'s surface is **800x600 logical** and nothing in this repo
/// changes it. This file's entire subject is a 1280 cap, so on the default
/// surface the content measures 776 — over `medium` (768) by 8px, entirely by
/// accident, which would let a loose "wider than medium" assertion pass against
/// a completely unmodified widget while `xl` and `xxl` stayed
/// indistinguishable. Every pump goes through [_surface], and its teardowns are
/// not optional: a leaked surface changes every file that runs after this one.

Transaction _tx({
  TransactionType? type,
  TransactionDirection direction = TransactionDirection.sent,
}) => Transaction(
  hash: '0xabc',
  fromAddress: '0x1111',
  recipients: [TransferRecipients(toAddr: '0x2222', amount: '1.0')],
  timeStamp: DateTime(2026, 7, 22),
  transactionDirection: direction,
  fees: '0.001',
  coinSymbol: 'ETH',
  transactionStatus: TransactionStatus.completed,
  type: type,
);

/// Three rows across three type filters — enough for a non-empty scope (which
/// is what makes the rail, and therefore the second card, appear) and short
/// enough not to fight the harness's wide fallback font at 360px.
List<Transaction> _some() => [
  _tx(type: TransactionType.transfer),
  _tx(type: TransactionType.mint),
  _tx(type: TransactionType.escrow),
];

/// [WalletDetailsCubit] takes a [GeniusApi] it never touches on this screen —
/// the only call is `getCoins()` behind the pull-to-refresh, which no test here
/// triggers. `noSuchMethod` forwarding to `super` satisfies the type with four
/// lines and no test dependency, and throws loudly if that ever stops being
/// true rather than returning a silent null.
class _UnusedApi implements GeniusApi {
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

/// The real screen, with the two blocs its `BlocBuilder`s demand.
///
/// `selectedWallet` is left null, so the branch is the non-SGNUS one — see the
/// coverage note in the header comment.
Widget _host({List<Transaction>? txs}) => MultiBlocProvider(
  providers: [
    BlocProvider(
      create: (_) => WalletDetailsCubit(
        geniusApi: _UnusedApi(),
        networkTokensProvider: NetworkTokensProvider(),
      ),
    ),
    BlocProvider(create: (_) => TransactionsCubit(initial: txs ?? _some())),
  ],
  child: MaterialApp(
    theme: ThemeData(extensions: [GWColors.dark()]),
    home: const TransactionsScreen(),
  ),
);

/// Sets the window to [width] x [height] LOGICAL pixels and tears it back down.
void _surface(WidgetTester tester, double width, [double height = 900]) {
  tester.view.physicalSize = Size(width * 3, height * 3); // logical x dpr
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

/// The frame's content box, measured at BOTH ends of its `Column`: the header
/// above and the branch below. Both are direct children of the stretched
/// `Column` inside the `ConstrainedBox`, so both report the capped width — and
/// reading both means a cap applied to only one of them cannot hide.
double _contentWidth(WidgetTester tester) {
  final header = tester.getSize(find.byType(GWPageHeader)).width;
  final body = tester.getSize(find.byType(TransactionsSlimView)).width;
  expect(body, header, reason: 'header and branch must share one content box');
  return header;
}

void main() {
  testWidgets('the page is titled once, at page weight', (tester) async {
    _surface(tester, 1600);
    await tester.pumpWidget(_host());
    await tester.pumpAndSettle();

    expect(find.byType(GWPageHeader), findsOneWidget);
    // The panel's 18px section title must NOT reach the page. If it does, the
    // `page` flag failed somewhere along TransactionsScreen -> TransactionsStream
    // -> TransactionsSlimView, which is the single most likely wiring mistake
    // in this plan, and the user sees the word twice at two sizes.
    expect(find.byType(GWSectionTitle), findsNothing);
    expect(find.text('Transactions'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the content stops at the xl cap', (tester) async {
    _surface(tester, 1600);
    await tester.pumpWidget(_host());
    await tester.pumpAndSettle();

    // EXACTLY xl, not merely "wider than medium". The loose form cannot tell
    // 1280 from 1536 and, on the uncorrected 800px surface, passes at 776
    // against an entirely unmodified widget.
    //
    // 1280 and not 1280-24: the Padding is OUTSIDE the ConstrainedBox, so the
    // cap binds the CONTENT and the 12px gutter is additive on top of it (1304
    // of the 1600 window used, 148 dead each side). Nested the other way this
    // would read 1256, which is what makes this number the order test.
    expect(
      _contentWidth(tester),
      closeTo(GeniusBreakpoints.xl, 1),
      reason: 'expected the 1280 cap to bind at a 1600px window',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('below the cap the content follows the viewport', (tester) async {
    _surface(tester, 1000);
    await tester.pumpWidget(_host());
    await tester.pumpAndSettle();

    // The other end of the same property: a max-width constrains only a WIDER
    // viewport, so at 1000 the ConstrainedBox does nothing and the content is
    // viewport minus the two 12px gutters. A frame that measured 1280 here
    // would be overflowing the window, not filling it.
    expect(
      _contentWidth(tester),
      closeTo(1000 - 24, 1),
      reason: 'expected viewport minus the 12px gutters at a 1000px window',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('a narrow viewport keeps its gutter', (tester) async {
    _surface(tester, 360, 800);
    // EMPTY scope here, and the reason is a measurement rather than a
    // convenience. Below 768 the page hands off to the PANEL, whose title row
    // (`GWSectionTitle` + the compact filter bar) does not fit a narrow harness
    // window: measured through this very host at 320/328/336/344/360/380/400 it
    // overflows by 93/85/77/69/53/33/13 — exactly 1:1 with width, clearing at
    // **413**. That is `_panel`'s row, which this plan does not touch, and it
    // is a harness-font artifact: the fallback font draws roughly one em per
    // character, so 'Transactions' costs ~216px here against real Inter's ~110.
    // It also got 8px BETTER under this plan, not worse — the old
    // `EdgeInsets.all(16)` left 328px of content and overflowed by 85.
    // An empty scope drops the filter bar entirely (15-03's `scoped.isEmpty`
    // guard), which removes that unrelated red without weakening anything
    // below: the gutter is measured on `GWPageHeader`, which sits ABOVE the
    // branch and renders identically either way. Logged for 15-06 in
    // `deferred-items.md`.
    await tester.pumpWidget(_host(txs: const []));
    await tester.pumpAndSettle();

    // At 360 the 1280 cap is inert, so this 12px is the Padding's alone. Delete
    // the Padding and the content sits on the window bezel — the defect the
    // 06-01 walk found in `wallet_creation_screen.dart`.
    expect(
      tester.getTopLeft(find.byType(GWPageHeader)).dx,
      closeTo(12, 0.01),
      reason: 'expected the 12px gutter to survive a viewport under the cap',
    );
    expect(_contentWidth(tester), closeTo(360 - 24, 1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('rows sit on a card, not on raw surface-base', (tester) async {
    _surface(tester, 1600);
    await tester.pumpWidget(_host());
    await tester.pumpAndSettle();

    // Two: the filter rail's card and the list's card. On the dashboard the
    // identical slim view is wrapped by dashboard_screen.dart's own container;
    // on the page the wrapping is the slim view's own, and a page that renders
    // it bare hangs rows on raw surface-base (the ROADMAP's defect #3).
    expect(find.byType(DashboardScrollContainer), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });
}
