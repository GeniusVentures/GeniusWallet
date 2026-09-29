// Proves `ensureRunningAs` itself: the no-op when already running as the
// required account, the plain switch dialog and its Cancel, a confirmed
// switch that actually lands through a seeded AppBloc, a switch that never
// lands, and the refusal when the running account has its own pending
// child operation.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/ffi/genius_api_ffi.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/sgnus_connection.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/child_wallets/child_operation_switch_dialog.dart';
import 'package:genius_wallet/child_wallets/child_operations_cubit.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/dashboard/transactions/cubit/transactions_cubit.dart';
import 'package:genius_wallet/providers/network_provider.dart';
import 'package:genius_wallet/providers/network_tokens_provider.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:local_secure_storage/local_secure_storage.dart'
    show SDKAccountLink;

const _mainAddress = '0x1111111111111111111111111111111111aaaa';
const _otherAddress = '0x5555555555555555555555555555555555eeee';
const _childAddress = '0x2222222222222222222222222222222222bbbb';

/// `implements`, not `extends`: the real constructor dlopens the native SDK.
/// Answers the getters `AppBloc._onSelectSDKAccount` reads after a select,
/// and its own `selectCalls` proves the dispatch happened exactly once.
class _SwitchingApi implements GeniusApi {
  _SwitchingApi({
    this.landsAfterSelect = true,
    this.result = GeniusNodeReturnValue.GENIUS_NODE_RET_OK,
  });

  final bool landsAfterSelect;
  final GeniusNodeReturnValue result;
  final selectCalls = <String>[];
  String? _selected;

  @override
  Future<GeniusNodeReturnValue> selectGeniusAccountAsync(
    String publicAddress,
  ) async {
    selectCalls.add(publicAddress);
    if (landsAfterSelect) {
      _selected = publicAddress;
    }
    return result;
  }

  @override
  String? getSelectedAccountAddress() => _selected;

  // Comfortably above every amount the pending-lock tests submit.
  @override
  String getMinionsBalance([String? tokenId]) => '10000000';

  @override
  BigInt getChildBalance(String childAddress, {String? tokenId}) => BigInt.zero;

  @override
  GeniusNodeReturnValue fundChildGnus(String amountGnus, String childAddress) =>
      GeniusNodeReturnValue.GENIUS_NODE_RET_OK;

  @override
  String? getStartAccountAddress() => null;

  @override
  List<String> getAvailableAccounts() => const [];

  @override
  Future<Map<String, SDKAccountLink>> getSDKAccountLinks() async => {};

  @override
  Stream<SGNUSConnection> getSGNUSConnectionStream() =>
      Stream.value(SGNUSConnection.empty());

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Seeds `AppBloc.state` directly, bypassing `InitializeSDK` (which would
/// reach the real SDK) -- the same pattern `account_drawer_show_test.dart`'s
/// `_SeededAppBloc` uses. Not imported from there: each test file copies the
/// shape rather than importing across test files.
class _SeededAppBloc extends AppBloc {
  _SeededAppBloc({
    required super.api,
    required super.transactionsCubit,
    required super.walletDetailsCubit,
    required super.networkProvider,
    String? selectedSDKAccount,
  }) {
    emit(state.copyWith(selectedSDKAccount: selectedSDKAccount));
  }
}

/// Builds a seeded [AppBloc] over [api], already running as
/// [selectedSDKAccount].
AppBloc _buildAppBloc({required GeniusApi api, String? selectedSDKAccount}) =>
    _SeededAppBloc(
      api: api,
      transactionsCubit: TransactionsCubit(),
      walletDetailsCubit: WalletDetailsCubit(
        geniusApi: api,
        networkTokensProvider: NetworkTokensProvider(),
      ),
      networkProvider: NetworkProvider(),
      selectedSDKAccount: selectedSDKAccount,
    );

/// Pumps a bare `Builder` with a button that guards a marker dialog behind
/// `ensureRunningAs` -- the "action" every real call site (Fund/Recover/
/// Revoke) stands in for here. [appBloc] is optional: omitting it proves the
/// already-running-as-required path never reads `AppBloc` at all.
Future<void> _pumpHarness(
  WidgetTester tester, {
  required ChildOperationsCubit registry,
  AppBloc? appBloc,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(extensions: [GWColors.dark()]),
      home: MultiBlocProvider(
        providers: [
          BlocProvider<ChildOperationsCubit>.value(value: registry),
          if (appBloc != null) BlocProvider<AppBloc>.value(value: appBloc),
        ],
        child: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () async {
                final ok = await ensureRunningAs(context, _mainAddress);
                if (ok && context.mounted) {
                  await showDialog<void>(
                    // ignore: use_build_context_synchronously
                    context: context,
                    builder: (_) =>
                        const AlertDialog(title: Text('ACTION OPENED')),
                  );
                }
              },
              child: const Text('start'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

Future<void> _tapStart(WidgetTester tester) async {
  await tester.tap(find.text('start'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'already running as the required account opens the action with no '
    'dialog and no AppBloc read',
    (tester) async {
      final api = _SwitchingApi();
      final registry = ChildOperationsCubit(
        api: api,
        readAppState: () => const AppState(selectedSDKAccount: _mainAddress),
      );
      // No AppBloc provided at all: a read would throw ProviderNotFoundError.
      await _pumpHarness(tester, registry: registry);

      await _tapStart(tester);

      expect(find.text('ACTION OPENED'), findsOneWidget);
      expect(api.selectCalls, isEmpty);

      await registry.close();
    },
  );

  testWidgets('running as another account with nothing pending shows the '
      'switch dialog; Cancel dispatches nothing and opens nothing', (
    tester,
  ) async {
    final api = _SwitchingApi();
    final registry = ChildOperationsCubit(
      api: api,
      readAppState: () => const AppState(selectedSDKAccount: _otherAddress),
    );
    final appBloc = _buildAppBloc(api: api, selectedSDKAccount: _otherAddress);
    await _pumpHarness(tester, registry: registry, appBloc: appBloc);

    await _tapStart(tester);

    expect(find.text('Switch to 0x1111...aaaa?'), findsOneWidget);
    expect(
      find.text(
        'This action needs to run as 0x1111...aaaa, not the account '
        'currently earning.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.widgetWithText(GWButton, 'Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('ACTION OPENED'), findsNothing);
    expect(api.selectCalls, isEmpty);

    await registry.close();
    await tester.runAsync(() => appBloc.close());
  });

  testWidgets(
    "'Switch and continue' dispatches one select, then opens the action "
    'once the switch actually lands',
    (tester) async {
      final api = _SwitchingApi();
      final registry = ChildOperationsCubit(
        api: api,
        readAppState: () => const AppState(selectedSDKAccount: _otherAddress),
      );
      final appBloc = _buildAppBloc(
        api: api,
        selectedSDKAccount: _otherAddress,
      );
      await _pumpHarness(tester, registry: registry, appBloc: appBloc);

      await _tapStart(tester);
      await tester.tap(find.widgetWithText(GWButton, 'Switch and continue'));
      await tester.pumpAndSettle();

      expect(api.selectCalls, [_mainAddress]);
      expect(find.text('ACTION OPENED'), findsOneWidget);

      await registry.close();
      await tester.runAsync(() => appBloc.close());
    },
  );

  testWidgets(
    'a switch that never lands times out to an error toast, no action opens',
    (tester) async {
      final api = _SwitchingApi(landsAfterSelect: false);
      final registry = ChildOperationsCubit(
        api: api,
        readAppState: () => const AppState(selectedSDKAccount: _otherAddress),
      );
      final appBloc = _buildAppBloc(
        api: api,
        selectedSDKAccount: _otherAddress,
      );
      await _pumpHarness(tester, registry: registry, appBloc: appBloc);

      await _tapStart(tester);
      await tester.tap(find.widgetWithText(GWButton, 'Switch and continue'));
      await tester.pump();

      // Advance the fake clock past the switch timeout to fire it.
      await tester.pump(const Duration(seconds: 31));
      await tester.pumpAndSettle();

      expect(api.selectCalls, [_mainAddress]);
      expect(
        find.text(
          "Couldn't switch earning to 0x1111...aaaa. Nothing was sent.",
        ),
        findsOneWidget,
      );
      expect(find.text('ACTION OPENED'), findsNothing);

      await registry.close();
      await tester.runAsync(() => appBloc.close());
    },
  );

  testWidgets(
    'a switch the node refuses fails at once instead of waiting out the '
    'timeout, and no action opens',
    (tester) async {
      final api = _SwitchingApi(
        landsAfterSelect: false,
        result: GeniusNodeReturnValue.GENIUS_NODE_ERROR_NOT_INITIALIZED,
      );
      final registry = ChildOperationsCubit(
        api: api,
        readAppState: () => const AppState(selectedSDKAccount: _otherAddress),
      );
      final appBloc = _buildAppBloc(
        api: api,
        selectedSDKAccount: _otherAddress,
      );
      await _pumpHarness(tester, registry: registry, appBloc: appBloc);

      await _tapStart(tester);
      await tester.tap(find.widgetWithText(GWButton, 'Switch and continue'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(
        find.text(
          "Couldn't switch earning to 0x1111...aaaa. Nothing was sent.",
        ),
        findsOneWidget,
      );
      expect(find.text('ACTION OPENED'), findsNothing);

      await tester.pumpAndSettle();
      await registry.close();
      await tester.runAsync(() => appBloc.close());
    },
  );

  testWidgets(
    'a switch the node confirms only after a while opens the action then, '
    'not while it still reports no account',
    (tester) async {
      final api = _SwitchingApi(landsAfterSelect: false);
      final registry = ChildOperationsCubit(
        api: api,
        readAppState: () => const AppState(selectedSDKAccount: _otherAddress),
      );
      final appBloc = _buildAppBloc(
        api: api,
        selectedSDKAccount: _otherAddress,
      );
      await _pumpHarness(tester, registry: registry, appBloc: appBloc);

      await _tapStart(tester);
      await tester.tap(find.widgetWithText(GWButton, 'Switch and continue'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 7));
      expect(find.text('ACTION OPENED'), findsNothing);

      api._selected = _mainAddress;
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      expect(find.text('ACTION OPENED'), findsOneWidget);

      await registry.close();
      await tester.runAsync(() => appBloc.close());
    },
  );

  testWidgets(
    "the running account's own pending operation refuses the switch with a "
    'single OK and zero select calls',
    (tester) async {
      final api = _SwitchingApi();
      final registry = ChildOperationsCubit(
        api: api,
        readAppState: () => const AppState(selectedSDKAccount: _otherAddress),
      );
      registry.submit(
        kind: ChildOperationKind.fund,
        target: _childAddress,
        main: _otherAddress,
        amountMinions: BigInt.from(1000000),
      );
      final appBloc = _buildAppBloc(
        api: api,
        selectedSDKAccount: _otherAddress,
      );
      await _pumpHarness(tester, registry: registry, appBloc: appBloc);

      await _tapStart(tester);

      expect(find.text("Can't switch right now"), findsOneWidget);
      expect(
        find.text(
          'Waiting for a child operation from 0x5555...eeee to confirm.',
        ),
        findsOneWidget,
      );
      expect(find.widgetWithText(GWButton, 'OK'), findsOneWidget);

      await tester.tap(find.widgetWithText(GWButton, 'OK'));
      await tester.pumpAndSettle();

      expect(api.selectCalls, isEmpty);
      expect(find.text('ACTION OPENED'), findsNothing);

      await registry.close();
      await tester.runAsync(() => appBloc.close());
    },
  );

  testWidgets(
    'a pending operation belonging to the required account does not block '
    'the switch',
    (tester) async {
      final api = _SwitchingApi();
      // Mutable: the op must be submitted while the registry still reads the
      // node as running FROM the required account, then the node "moves" to
      // the other account for the actual `ensureRunningAs` call below.
      var appState = const AppState(selectedSDKAccount: _mainAddress);
      final registry = ChildOperationsCubit(
        api: api,
        readAppState: () => appState,
      );
      registry.submit(
        kind: ChildOperationKind.fund,
        target: _childAddress,
        main: _mainAddress,
        amountMinions: BigInt.from(1000000),
      );
      appState = const AppState(selectedSDKAccount: _otherAddress);
      final appBloc = _buildAppBloc(
        api: api,
        selectedSDKAccount: _otherAddress,
      );
      await _pumpHarness(tester, registry: registry, appBloc: appBloc);

      await _tapStart(tester);

      expect(find.text('Switch to 0x1111...aaaa?'), findsOneWidget);

      await tester.tap(find.widgetWithText(GWButton, 'Switch and continue'));
      await tester.pumpAndSettle();

      expect(api.selectCalls, [_mainAddress]);
      expect(find.text('ACTION OPENED'), findsOneWidget);

      await registry.close();
      await tester.runAsync(() => appBloc.close());
    },
  );
}
