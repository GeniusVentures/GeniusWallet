// The seam plan 14-04 extracted: `AccountDrawer.show(context)` must work from
// ANY context, not just `AccountDropdownSelector`'s former private method -
// that is the whole reason the compute panel's *not linked* state (plan
// 14-08) has anywhere to send the user.
//
// Every test below opens the drawer from a plain `Builder`, never from
// `AccountDropdownSelector` itself - proving the entry point stands on its
// own is the point of this file.
//
// Hive trap, recorded in
// `.planning/todos/pending/2026-07-29-real-hive-io-inside-testwidgets-hangs-forever.md`,
// and how this file actually gets past it (three prior agents stalled here):
//
// `testWidgets` runs inside `flutter_test`'s `FakeAsync` zone, and real disk
// I/O never completes there - `AccountDrawer.show`'s Hive write
// (`account_drawer.dart:70`), `AppBloc`'s internal event-stream teardown on
// `close()`, and even `Hive.close()`/`deleteBoxFromDisk` on a disk-backed box
// all hung indefinitely when driven through a live widget interaction in
// this environment, `tester.runAsync` notwithstanding - each attempt at
// wrapping specific calls in `runAsync` either could not interleave with the
// required `tester.tap`/`pumpAndSettle` calls (which must never themselves
// run inside `runAsync` - frame scheduling depends on the `FakeAsync` clock,
// which `runAsync`'s real zone does not drive) or simply moved the hang to
// the next real I/O call in the chain.
//
// The fix is hive_ce's own in-memory backend: `Hive.openBox(name,
// bytes: Uint8List(0))` selects `StorageBackendMemory`
// (`hive_ce-2.19.3/lib/src/backend/storage_backend_memory.dart`), whose
// `writeFrames`/`close` both return `Future.value()` - no real disk I/O, so
// no real async gap for `FakeAsync` to strand. `AccountDrawer.show` still
// calls the exact same public `Hive.box(walletBoxName).put(...)` it does in
// production; only the TEST'S box-opening call chooses the backend. This is
// not a production seam - `bytes:` is hive_ce's own public parameter on the
// same `Hive.openBox` call, used only from this test file.
//
// `deleteFromDisk()` throws `UnsupportedError` on the memory backend (by
// hive_ce's own design), so teardown below closes the box rather than
// deleting it from disk.
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/ffi/trust_wallet_api_ffi.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/account/account_drawer.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/dashboard/transactions/cubit/transactions_cubit.dart';
import 'package:genius_wallet/hive/constants/cache.dart';
import 'package:genius_wallet/providers/network_provider.dart';
import 'package:genius_wallet/providers/network_tokens_provider.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

/// Hand-written fake for [GeniusApi] - `implements` + a `noSuchMethod`
/// forward, not `extends`, because the real `GeniusApi`'s constructor dlopens
/// the native SuperGenius framework and crashes `flutter test`'s host
/// environment. Same pattern established in `submit_job_errors_test.dart` and
/// `transactions_page_frame_test.dart`'s `_UnusedApi`.
///
/// Neither [WalletDetailsCubit] nor [AppBloc] reach a real method on this
/// fake in any test below: `WalletDetailsCubit.selectWallet` short-circuits
/// on a null `selectedNetwork` before touching `geniusApi`, and `AppBloc`'s
/// own polling calls (`getInitializationStatus`/`getProcessingStatus`) are
/// both wrapped in a `try`/`catch` that swallows the `NoSuchMethodError` this
/// throws - `app_bloc.dart:284-305` and `:345-361`.
class _FakeGeniusApi implements GeniusApi {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Seeds `AppBloc.state.wallets` directly, bypassing `LoadWallets` (which
/// reaches Hive boxes this test does not open and the real SGNUS merge path)
/// - the same seeding pattern `job_flow_test.dart`'s `_SeededSubmitJobCubit`
/// and `_SeededGnusCubit` use.
class _SeededAppBloc extends AppBloc {
  _SeededAppBloc({
    required super.api,
    required super.transactionsCubit,
    required super.walletDetailsCubit,
    required super.networkProvider,
    required List<Wallet> wallets,
  }) {
    emit(state.copyWith(wallets: wallets));
  }
}

const _walletA = Wallet(
  coinType: TWCoinType.TWCoinTypeEthereum,
  walletName: 'Wallet A',
  currencySymbol: 'ETH',
  walletType: WalletType.privateKey,
  balance: 0,
  address: '0xAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA',
);

const _walletB = Wallet(
  coinType: TWCoinType.TWCoinTypeEthereum,
  walletName: 'Wallet B',
  currencySymbol: 'ETH',
  walletType: WalletType.privateKey,
  balance: 1,
  address: '0xBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB',
);

class _Harness {
  _Harness(this.walletDetailsCubit, this.appBloc);

  final WalletDetailsCubit walletDetailsCubit;
  final AppBloc appBloc;

  /// `appBloc.close()` awaits its internal event-stream settling. `AppBloc`
  /// starts a real 3s poll `Timer` in its constructor (`_startInitPolling`),
  /// and even with nothing disk-backed anywhere in this file, closing that
  /// down still needs the same real-zone treatment the Hive write did, or it
  /// hangs the same way.
  Future<void> dispose(WidgetTester tester) async {
    await tester.runAsync(() => appBloc.close());
    await walletDetailsCubit.close();
  }
}

_Harness _build(List<Wallet> wallets) {
  final walletDetailsCubit = WalletDetailsCubit(
    geniusApi: _FakeGeniusApi(),
    networkTokensProvider: NetworkTokensProvider(),
  );
  final appBloc = _SeededAppBloc(
    api: _FakeGeniusApi(),
    transactionsCubit: TransactionsCubit(),
    walletDetailsCubit: walletDetailsCubit,
    networkProvider: NetworkProvider(),
    wallets: wallets,
  );
  return _Harness(walletDetailsCubit, appBloc);
}

/// Holds the `Future` `AccountDrawer.show` returns, assigned SYNCHRONOUSLY
/// the moment the button is pressed (never awaited inline in `onPressed`) so
/// the test can await it directly.
class _Pending {
  Future<Wallet?>? future;
}

/// A plain context, deliberately NOT `AccountDropdownSelector` - a button on
/// a bare `Builder` is the "any surface" this plan exists to make possible.
Widget _openerHost({
  required WalletDetailsCubit walletDetailsCubit,
  required AppBloc appBloc,
  required _Pending pending,
}) => MultiBlocProvider(
  // Providers wrap `MaterialApp` itself, not just `home` - `ResponsiveDrawer
  // .show` pushes on the ROOT navigator (`useRootNavigator: true`), and a
  // dialog/sheet route's content attaches to the Navigator's Overlay rather
  // than nesting inside `home`'s own subtree. `context.read<...>()` inside
  // the pushed drawer can only resolve providers that are ANCESTORS of the
  // Navigator, not siblings placed only around the page content.
  providers: [
    BlocProvider<WalletDetailsCubit>.value(value: walletDetailsCubit),
    BlocProvider<AppBloc>.value(value: appBloc),
  ],
  child: MaterialApp(
    theme: ThemeData.dark().copyWith(extensions: [GWColors.dark()]),
    home: Scaffold(
      body: Builder(
        builder: (context) => ElevatedButton(
          onPressed: () {
            pending.future = AccountDrawer.show(context);
          },
          child: const Text('open drawer'),
        ),
      ),
    ),
  ),
);

/// Opens the drawer and taps [walletName]'s row - ordinary `FakeAsync`
/// interaction, exactly as a human tap would drive it. With the box backed
/// by `StorageBackendMemory` (see file header), `AccountDrawer.show`'s Hive
/// write is an ordinary in-memory `Future`, so no real-zone gymnastics are
/// needed here - the usual `pumpAndSettle` is enough to flush it.
Future<void> _openAndTapRow(WidgetTester tester, String walletName) async {
  await tester.tap(find.text('open drawer'));
  await tester.pumpAndSettle();

  await tester.tap(find.text(walletName));
  await tester.pumpAndSettle();
}

/// Sets up an in-memory-backed Hive box at `walletBoxName` plus a fresh
/// [_Harness] and [_Pending], runs [body], then tears both down.
///
/// Disposal happens in `finally`, not `addTearDown` - `addTearDown`
/// callbacks run AFTER `flutter_test`'s own end-of-test invariant check (the
/// one asserting no `Timer` is left pending), so harness disposal has to
/// complete before the test body returns, or `AppBloc`'s pending init-poll
/// `Timer` trips it.
Future<void> _withDrawerHarness(
  WidgetTester tester,
  Future<void> Function(Box box, _Harness harness, _Pending pending) body,
) async {
  final box = await Hive.openBox(walletBoxName, bytes: Uint8List(0));

  final harness = _build([_walletA, _walletB]);
  final pending = _Pending();

  try {
    await body(box, harness, pending);
  } finally {
    await harness.dispose(tester);
    await box.close();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'opening the drawer from a bare context and tapping a row returns that '
    'wallet from show()',
    (tester) async {
      await _withDrawerHarness(tester, (box, harness, pending) async {
        await tester.pumpWidget(
          _openerHost(
            walletDetailsCubit: harness.walletDetailsCubit,
            appBloc: harness.appBloc,
            pending: pending,
          ),
        );

        await _openAndTapRow(tester, 'Wallet B');

        expect(await pending.future, _walletB);
      });
    },
  );

  testWidgets(
    'the selection reaches WalletDetailsCubit, not just the return value - a '
    'version that returns the right wallet but forgets to select it would '
    'ship a drawer that does nothing',
    (tester) async {
      await _withDrawerHarness(tester, (box, harness, pending) async {
        await tester.pumpWidget(
          _openerHost(
            walletDetailsCubit: harness.walletDetailsCubit,
            appBloc: harness.appBloc,
            pending: pending,
          ),
        );

        await _openAndTapRow(tester, 'Wallet B');
        await pending.future;

        expect(harness.walletDetailsCubit.state.selectedWallet, _walletB);
      });
    },
  );

  testWidgets(
    'the persisted selection is written to Hive - the write a missing '
    'caller-side call would only reveal on the next app launch',
    (tester) async {
      await _withDrawerHarness(tester, (box, harness, pending) async {
        await tester.pumpWidget(
          _openerHost(
            walletDetailsCubit: harness.walletDetailsCubit,
            appBloc: harness.appBloc,
            pending: pending,
          ),
        );

        await _openAndTapRow(tester, 'Wallet B');
        await pending.future;

        expect(box.get(selectedWalletKey), _walletB.address);
      });
    },
  );

  testWidgets(
    'the guard: a drawer opened from a bare context - one that is not the '
    'dropdown selector - still renders its rows',
    (tester) async {
      await _withDrawerHarness(tester, (box, harness, pending) async {
        await tester.pumpWidget(
          _openerHost(
            walletDetailsCubit: harness.walletDetailsCubit,
            appBloc: harness.appBloc,
            pending: pending,
          ),
        );

        await tester.tap(find.text('open drawer'));
        await tester.pumpAndSettle();

        // 24-02: the drawer now holds TWO sections, so its title dropped the
        // "Your" - that word moved down onto the section header which actually
        // owns those rows. Both are asserted, which is strictly stronger than
        // the single title check this replaced: it pins the split itself, not
        // just that something rendered.
        expect(find.text('Accounts'), findsOneWidget);
        expect(find.text('YOUR ACCOUNTS'), findsOneWidget);
        // The harness has no sgnus wallets and an empty `sdkAccounts`, so the
        // SDK section must NOT be drawn at all - an empty box above the user's
        // own wallets is exactly what the conditional in the drawer prevents.
        expect(find.text('SDK ACCOUNTS'), findsNothing);
        expect(find.text('Wallet A'), findsOneWidget);
        expect(find.text('Wallet B'), findsOneWidget);
        expect(find.text('Add Wallet'), findsOneWidget);
      });
    },
  );
}
