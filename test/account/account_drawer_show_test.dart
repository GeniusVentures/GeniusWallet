// The seam plan 14-04 extracted: `AccountDrawer.show(context)` must work from
// ANY context, not just the header chip's own button -
// that is the whole reason the compute panel's *not linked* state (plan
// 14-08) has anywhere to send the user.
//
// Every test below opens the drawer from a plain `Builder`, never from
// `AccountSwitcher` itself - proving the entry point stands on its
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
import 'package:genius_api/ffi/genius_api_ffi.dart';
import 'package:genius_api/ffi/trust_wallet_api_ffi.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/sgnus_connection.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/account/account_drawer.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/components/cards/gw_select_row.dart';
import 'package:genius_wallet/components/toast/toast_manager.dart';
import 'package:genius_wallet/dashboard/transactions/cubit/transactions_cubit.dart';
import 'package:genius_wallet/hive/constants/cache.dart';
import 'package:genius_wallet/providers/network_provider.dart';
import 'package:genius_wallet/providers/network_tokens_provider.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:local_secure_storage/local_secure_storage.dart'
    show SDKAccountLink;

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

/// Tracks a delete so a test can prove the row menu's confirmed delete
/// reached the bloc's own call, not a bypassed one (D-12).
class _DeletingApi extends _FakeGeniusApi {
  String? deleted;
  bool? deletedWatchOnly;

  @override
  Future<void> deleteWallet(String address, {required bool watchOnly}) async {
    deleted = address;
    deletedWatchOnly = watchOnly;
  }

  @override
  Stream<SGNUSConnection> getSGNUSConnectionStream() =>
      Stream.value(SGNUSConnection.empty());

  @override
  String? getSelectedAccountAddress() => null;

  @override
  String? getStartAccountAddress() => null;

  @override
  List<String> getAvailableAccounts() => const [];

  @override
  Future<Map<String, SDKAccountLink>> getSDKAccountLinks() async => {};
}

/// Records a selection attempt and answers the getters `_onSelectSDKAccount`
/// reads afterwards. Its re-merge of `AppState.wallets` is not asserted on
/// below - the seeded bloc's own `_baseWallets` is empty, so a tap that
/// reaches the bloc rebuilds the row list from nothing. That is a fact about
/// this harness, not a defect; these tests assert on `WalletDetailsCubit`
/// and on [selectCalls] instead of on rows after a tap.
class _SelectingApi extends _FakeGeniusApi {
  final selectCalls = <String>[];

  @override
  Future<GeniusNodeReturnValue> selectGeniusAccountAsync(
    String publicAddress,
  ) async {
    selectCalls.add(publicAddress);
    return GeniusNodeReturnValue.GENIUS_NODE_RET_OK;
  }

  @override
  String? getSelectedAccountMnemonic() => null;

  @override
  String? getSelectedAccountAddress() => null;

  @override
  String? getStartAccountAddress() => null;

  @override
  List<String> getAvailableAccounts() => const [];

  @override
  Future<Map<String, SDKAccountLink>> getSDKAccountLinks() async => {};

  @override
  Stream<SGNUSConnection> getSGNUSConnectionStream() =>
      Stream.value(SGNUSConnection.empty());
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
    Map<String, SDKAccountLink> sdkAccountLinks = const {},
    String? defaultSDKAccount,
    List<String> sdkAccounts = const [],
    String? selectedSDKAccount,
  }) {
    emit(
      state.copyWith(
        wallets: wallets,
        sdkAccountLinks: sdkAccountLinks,
        defaultSDKAccount: defaultSDKAccount,
        sdkAccounts: sdkAccounts,
        selectedSDKAccount: selectedSDKAccount,
      ),
    );
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

_Harness _build(
  List<Wallet> wallets, {
  Map<String, SDKAccountLink> sdkAccountLinks = const {},
  String? defaultSDKAccount,
  List<String> sdkAccounts = const [],
  String? selectedSDKAccount,
  GeniusApi? api,
}) {
  final walletDetailsCubit = WalletDetailsCubit(
    geniusApi: api ?? _FakeGeniusApi(),
    networkTokensProvider: NetworkTokensProvider(),
  );
  final appBloc = _SeededAppBloc(
    api: api ?? _FakeGeniusApi(),
    transactionsCubit: TransactionsCubit(),
    walletDetailsCubit: walletDetailsCubit,
    networkProvider: NetworkProvider(),
    wallets: wallets,
    sdkAccountLinks: sdkAccountLinks,
    defaultSDKAccount: defaultSDKAccount,
    sdkAccounts: sdkAccounts,
    selectedSDKAccount: selectedSDKAccount,
  );
  return _Harness(walletDetailsCubit, appBloc);
}

/// Holds the `Future` `AccountDrawer.show` returns, assigned SYNCHRONOUSLY
/// the moment the button is pressed (never awaited inline in `onPressed`) so
/// the test can await it directly.
class _Pending {
  Future<Wallet?>? future;
}

/// A plain context, deliberately NOT `AccountSwitcher` - a button on
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

        // Both sections are always present, each with its own label - the
        // switcher never leaves one implied by an absent header. The harness
        // has no SDK accounts and no default account, so the node section
        // shows its own explicit empty state rather than vanishing.
        expect(find.text('Accounts'), findsOneWidget);
        expect(find.text('SENDING FROM'), findsOneWidget);
        expect(find.text('NODE RUNNING AS'), findsOneWidget);
        expect(find.text('Node not running'), findsOneWidget);
        expect(find.text('Wallet A'), findsOneWidget);
        expect(find.text('Wallet B'), findsOneWidget);
        expect(find.text('Add wallet'), findsOneWidget);
      });
    },
  );

  group('walletSDKBadge', () {
    const links = <String, SDKAccountLink>{
      '0xsdk9999': (walletAddress: '0xaaaaaaaa', walletName: 'Main'),
    };

    test('a tracking (watch-only) wallet never carries a badge', () {
      const wallet = Wallet(
        coinType: TWCoinType.TWCoinTypeEthereum,
        walletName: 'Watched',
        currencySymbol: 'ETH',
        walletType: WalletType.tracking,
        balance: 0,
        address: '0xaaaaaaaa',
      );
      expect(
        walletSDKBadge(wallet, links, sdkRunning: true),
        WalletSDKBadge.none,
      );
    });

    test('an sgnus row never carries a badge - it already names its wallet '
        'itself', () {
      const wallet = Wallet(
        coinType: TWCoinType.TWCoinTypeEthereum,
        walletName: 'Main',
        currencySymbol: 'minions',
        walletType: WalletType.sgnus,
        balance: 0,
        address: '0xaaaaaaaa',
      );
      expect(
        walletSDKBadge(wallet, links, sdkRunning: false),
        WalletSDKBadge.none,
      );
    });

    test('a linked own wallet reads linked, matching case-insensitively', () {
      const wallet = Wallet(
        coinType: TWCoinType.TWCoinTypeEthereum,
        walletName: 'Main',
        currencySymbol: 'ETH',
        walletType: WalletType.privateKey,
        balance: 0,
        // Uppercase, against the link's lowercased walletAddress above.
        address: '0xAAAAAAAA',
      );
      expect(
        walletSDKBadge(wallet, links, sdkRunning: false),
        WalletSDKBadge.linked,
      );
    });

    test('an unlinked own wallet reads pending only while the SDK is not '
        'running', () {
      const wallet = Wallet(
        coinType: TWCoinType.TWCoinTypeEthereum,
        walletName: 'Not yet linked',
        currencySymbol: 'ETH',
        walletType: WalletType.privateKey,
        balance: 0,
        address: '0xdeadbeef',
      );
      expect(
        walletSDKBadge(wallet, links, sdkRunning: false),
        WalletSDKBadge.pending,
      );
      expect(
        walletSDKBadge(wallet, links, sdkRunning: true),
        WalletSDKBadge.none,
      );
    });
  });

  group('the wallet menu SDK badge and address-based selection', () {
    // Named identically to the real Wallet A below, but an sgnus row - which
    // never renders in "Sending from" at all, so it can never be the one
    // that lights up or duplicates the name.
    const sgnusRowNamedWalletA = Wallet(
      coinType: TWCoinType.TWCoinTypeEthereum,
      walletName: 'Wallet A',
      currencySymbol: 'minions',
      walletType: WalletType.sgnus,
      balance: 0,
      address: '0xCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC',
    );

    final links = <String, SDKAccountLink>{
      _walletA.address.toLowerCase(): (
        walletAddress: _walletA.address.toLowerCase(),
        walletName: 'Wallet A',
      ),
    };

    Future<void> pumpSelectedDrawer(
      WidgetTester tester,
      _Harness harness,
      _Pending pending,
    ) async {
      await harness.walletDetailsCubit.selectWallet(_walletA);
      await tester.pumpWidget(
        _openerHost(
          walletDetailsCubit: harness.walletDetailsCubit,
          appBloc: harness.appBloc,
          pending: pending,
        ),
      );
      await tester.tap(find.text('open drawer'));
      await tester.pumpAndSettle();
    }

    testWidgets(
      'with the SDK running: SDK shows once, SDK PENDING is absent, and '
      'Wallet A renders once - the same-named sgnus row is not shown',
      (tester) async {
        final box = await Hive.openBox(walletBoxName, bytes: Uint8List(0));
        final harness = _build(
          [sgnusRowNamedWalletA, _walletA, _walletB],
          sdkAccountLinks: links,
          defaultSDKAccount: '0xstart',
        );
        final pending = _Pending();
        try {
          await pumpSelectedDrawer(tester, harness, pending);

          expect(find.text('SDK'), findsOneWidget);
          expect(find.text('SDK PENDING'), findsNothing);
          expect(find.text('Wallet A'), findsOneWidget);

          final selectedRows = tester
              .widgetList<GWSelectRow>(find.byType(GWSelectRow))
              .where((r) => r.selected);
          expect(selectedRows, hasLength(1));
        } finally {
          await harness.dispose(tester);
          await box.close();
        }
      },
    );

    testWidgets(
      'with the SDK stopped: the still-unlinked wallet reads SDK PENDING',
      (tester) async {
        final box = await Hive.openBox(walletBoxName, bytes: Uint8List(0));
        final harness = _build(
          [sgnusRowNamedWalletA, _walletA, _walletB],
          sdkAccountLinks: links,
          // No default account: nothing has started the SDK yet.
        );
        final pending = _Pending();
        try {
          await pumpSelectedDrawer(tester, harness, pending);
          // Wallet B's row sits below the fold once the section headers and
          // Wallet A's row claim their height - the drawer's `ListView`
          // never builds a sliver child this far outside the viewport
          // until it is scrolled into range.
          await tester.scrollUntilVisible(find.text('Wallet B'), 200);

          expect(find.text('SDK PENDING'), findsOneWidget);
          expect(find.text('SDK'), findsOneWidget);
        } finally {
          await harness.dispose(tester);
          await box.close();
        }
      },
    );
  });

  group('the two selections stay independent', () {
    const sdkA = '0xAAAA000000000000000000000000000000000A';
    const sdkB = '0xBBBB000000000000000000000000000000000B';
    // Neither address matches a real wallet, so each name is honest about a
    // removed wallet rather than the shared 'Unlinked' string - which would
    // make the two rows indistinguishable by title.
    final sdkLinks = <String, SDKAccountLink>{
      sdkA.toLowerCase(): (walletAddress: '0xnope1', walletName: 'Alpha'),
      sdkB.toLowerCase(): (walletAddress: '0xnope2', walletName: 'Beta'),
    };

    testWidgets(
      'tapping an unselected SDK row calls the API and leaves the active '
      'wallet untouched',
      (tester) async {
        final api = _SelectingApi();
        final box = await Hive.openBox(walletBoxName, bytes: Uint8List(0));
        final harness = _build(
          [_walletA],
          sdkAccountLinks: sdkLinks,
          sdkAccounts: const [sdkA, sdkB],
          selectedSDKAccount: sdkA,
          api: api,
        );
        final pending = _Pending();
        try {
          await harness.walletDetailsCubit.selectWallet(_walletA);
          await tester.pumpWidget(
            _openerHost(
              walletDetailsCubit: harness.walletDetailsCubit,
              appBloc: harness.appBloc,
              pending: pending,
            ),
          );
          await tester.tap(find.text('open drawer'));
          await tester.pumpAndSettle();

          // BOUNDED: the row's own toast arms a 1s auto-dismiss Timer, and
          // the drawer stays open (no route pop here), so `pumpAndSettle`
          // would spin to the test timeout waiting on it.
          await tester.tap(find.text('Beta (wallet removed)'));
          await tester.pump();

          expect(api.selectCalls, [sdkB]);
          expect(harness.walletDetailsCubit.state.selectedWallet, _walletA);
        } finally {
          ToastManager.instance.disposeAll();
          await tester.pump(const Duration(milliseconds: 400));
          await harness.dispose(tester);
          await box.close();
        }
      },
    );

    testWidgets('re-tapping the already-selected SDK row calls nothing', (
      tester,
    ) async {
      final api = _SelectingApi();
      final box = await Hive.openBox(walletBoxName, bytes: Uint8List(0));
      final harness = _build(
        [_walletA],
        sdkAccountLinks: sdkLinks,
        sdkAccounts: const [sdkA, sdkB],
        selectedSDKAccount: sdkA,
        api: api,
      );
      final pending = _Pending();
      try {
        await tester.pumpWidget(
          _openerHost(
            walletDetailsCubit: harness.walletDetailsCubit,
            appBloc: harness.appBloc,
            pending: pending,
          ),
        );
        await tester.tap(find.text('open drawer'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Alpha (wallet removed)'));
        await tester.pump();

        expect(api.selectCalls, isEmpty);
      } finally {
        await harness.dispose(tester);
        await box.close();
      }
    });

    testWidgets(
      'tapping an own-wallet row changes the active wallet and calls the '
      'SDK API nothing',
      (tester) async {
        final api = _SelectingApi();
        final box = await Hive.openBox(walletBoxName, bytes: Uint8List(0));
        final harness = _build(
          [_walletA, _walletB],
          sdkAccountLinks: sdkLinks,
          sdkAccounts: const [sdkA, sdkB],
          selectedSDKAccount: sdkA,
          api: api,
        );
        final pending = _Pending();
        try {
          await harness.walletDetailsCubit.selectWallet(_walletA);
          await tester.pumpWidget(
            _openerHost(
              walletDetailsCubit: harness.walletDetailsCubit,
              appBloc: harness.appBloc,
              pending: pending,
            ),
          );
          await tester.tap(find.text('open drawer'));
          await tester.pumpAndSettle();

          await tester.tap(find.text('Wallet B'));
          await tester.pumpAndSettle();
          await pending.future;

          expect(harness.walletDetailsCubit.state.selectedWallet, _walletB);
          expect(api.selectCalls, isEmpty);
        } finally {
          await harness.dispose(tester);
          await box.close();
        }
      },
    );

    testWidgets('View balance selects the linked sgnus wallet, matched '
        'case-insensitively, and is disabled when the account has none', (
      tester,
    ) async {
      const sdkWithBalance = '0xcccc000000000000000000000000000000000c';
      const sdkWithoutBalance = '0xdddd000000000000000000000000000000000d';
      const sgnusWallet = Wallet(
        coinType: TWCoinType.TWCoinTypeEthereum,
        walletName: 'Node balance',
        currencySymbol: 'minions',
        walletType: WalletType.sgnus,
        balance: 0,
        // Uppercase, against the lowercase SDK account address above.
        address: '0xCCCC000000000000000000000000000000000C',
      );
      final api = _SelectingApi();
      final box = await Hive.openBox(walletBoxName, bytes: Uint8List(0));
      final harness = _build(
        [_walletA, sgnusWallet],
        sdkAccounts: const [sdkWithBalance, sdkWithoutBalance],
        api: api,
      );
      final pending = _Pending();
      try {
        await tester.pumpWidget(
          _openerHost(
            walletDetailsCubit: harness.walletDetailsCubit,
            appBloc: harness.appBloc,
            pending: pending,
          ),
        );
        await tester.tap(find.text('open drawer'));
        await tester.pumpAndSettle();

        // sdkAccounts order is [sdkWithBalance, sdkWithoutBalance]; only
        // the first's lowercased address matches the sgnus wallet above.
        await tester.tap(find.byTooltip('Account options').at(0));
        await tester.pumpAndSettle();
        await tester.tap(find.text('View balance'));
        await tester.pumpAndSettle();

        expect(harness.walletDetailsCubit.state.selectedWallet, sgnusWallet);

        await tester.tap(find.text('open drawer'));
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('Account options').at(1));
        await tester.pumpAndSettle();

        final disabled = tester.widget<MenuItemButton>(
          find.widgetWithText(MenuItemButton, 'View balance'),
        );
        expect(disabled.onPressed, isNull);
      } finally {
        await harness.dispose(tester);
        await box.close();
      }
    });

    testWidgets(
      'the wallet linked to the active SDK account shows ACTIVE ON NODE, '
      'not SDK',
      (tester) async {
        final box = await Hive.openBox(walletBoxName, bytes: Uint8List(0));
        final links = <String, SDKAccountLink>{
          sdkA.toLowerCase(): (
            walletAddress: _walletA.address.toLowerCase(),
            walletName: 'Wallet A',
          ),
        };
        final harness = _build(
          [_walletA],
          sdkAccountLinks: links,
          sdkAccounts: const [sdkA],
          selectedSDKAccount: sdkA,
          api: _SelectingApi(),
        );
        final pending = _Pending();
        try {
          await tester.pumpWidget(
            _openerHost(
              walletDetailsCubit: harness.walletDetailsCubit,
              appBloc: harness.appBloc,
              pending: pending,
            ),
          );
          await tester.tap(find.text('open drawer'));
          await tester.pumpAndSettle();

          expect(find.text('ACTIVE ON NODE'), findsOneWidget);
          expect(find.text('SDK'), findsNothing);
          expect(find.text('SDK PENDING'), findsNothing);
        } finally {
          await harness.dispose(tester);
          await box.close();
        }
      },
    );

    testWidgets(
      'a running node with zero accounts reads No SDK accounts yet, not '
      'Node not running',
      (tester) async {
        final box = await Hive.openBox(walletBoxName, bytes: Uint8List(0));
        final harness = _build([_walletA], defaultSDKAccount: '0xstart');
        final pending = _Pending();
        try {
          await tester.pumpWidget(
            _openerHost(
              walletDetailsCubit: harness.walletDetailsCubit,
              appBloc: harness.appBloc,
              pending: pending,
            ),
          );
          await tester.tap(find.text('open drawer'));
          await tester.pumpAndSettle();

          expect(find.text('No SDK accounts yet'), findsOneWidget);
          expect(find.text('Node not running'), findsNothing);
        } finally {
          await harness.dispose(tester);
          await box.close();
        }
      },
    );

    testWidgets(
      'a tracking wallet sharing the linked wallet\'s address does not '
      'also show ACTIVE ON NODE',
      (tester) async {
        const sharedAddress = '0xEEEE000000000000000000000000000000000E';
        const trackedTwin = Wallet(
          coinType: TWCoinType.TWCoinTypeEthereum,
          walletName: 'Watched twin',
          currencySymbol: 'ETH',
          walletType: WalletType.tracking,
          balance: 0,
          address: sharedAddress,
        );
        const ownedTwin = Wallet(
          coinType: TWCoinType.TWCoinTypeEthereum,
          walletName: 'Owned twin',
          currencySymbol: 'ETH',
          walletType: WalletType.privateKey,
          balance: 0,
          address: sharedAddress,
        );
        final box = await Hive.openBox(walletBoxName, bytes: Uint8List(0));
        final links = <String, SDKAccountLink>{
          sdkA.toLowerCase(): (
            walletAddress: sharedAddress.toLowerCase(),
            walletName: 'Owned twin',
          ),
        };
        final harness = _build(
          [trackedTwin, ownedTwin],
          sdkAccountLinks: links,
          sdkAccounts: const [sdkA],
          selectedSDKAccount: sdkA,
          api: _SelectingApi(),
        );
        final pending = _Pending();
        try {
          await tester.pumpWidget(
            _openerHost(
              walletDetailsCubit: harness.walletDetailsCubit,
              appBloc: harness.appBloc,
              pending: pending,
            ),
          );
          await tester.tap(find.text('open drawer'));
          await tester.pumpAndSettle();

          expect(find.text('ACTIVE ON NODE'), findsOneWidget);

          final trackedRow = find.ancestor(
            of: find.text('Watched twin'),
            matching: find.byType(GWSelectRow),
          );
          final ownedRow = find.ancestor(
            of: find.text('Owned twin'),
            matching: find.byType(GWSelectRow),
          );
          expect(
            find.descendant(
              of: trackedRow,
              matching: find.text('ACTIVE ON NODE'),
            ),
            findsNothing,
          );
          expect(
            find.descendant(
              of: ownedRow,
              matching: find.text('ACTIVE ON NODE'),
            ),
            findsOneWidget,
          );
        } finally {
          await harness.dispose(tester);
          await box.close();
        }
      },
    );
  });

  testWidgets(
    'the row menu, Delete, then confirm deletes Wallet B through the bloc '
    '(D-12)',
    (tester) async {
      final api = _DeletingApi();
      final box = await Hive.openBox(walletBoxName, bytes: Uint8List(0));
      final harness = _build([_walletA, _walletB], api: api);
      final pending = _Pending();
      try {
        await tester.pumpWidget(
          _openerHost(
            walletDetailsCubit: harness.walletDetailsCubit,
            appBloc: harness.appBloc,
            pending: pending,
          ),
        );

        await tester.tap(find.text('open drawer'));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(Icons.more_vert).at(1));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Delete'));
        await tester.pumpAndSettle();
        expect(find.text('Delete wallet'), findsOneWidget);
        await tester.tap(find.text('Delete'));
        await tester.pumpAndSettle();

        expect(api.deleted, _walletB.address);
        expect(api.deletedWatchOnly, isFalse);
      } finally {
        await harness.dispose(tester);
        await box.close();
      }
    },
  );
}
