// The add-account dialog used to accept an empty or malformed secret and then
// report "Account added successfully" whatever the SDK said. Now the bloc
// reports exactly what happened to the pasted secret -- added, already one
// of the user's wallets, saved but pending its SDK link, or failed outright
// -- and this file pins each of those four messages, plus that a non-added
// outcome never reassigns the SDK account selection or the active wallet.
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
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/dashboard/transactions/cubit/transactions_cubit.dart';
import 'package:genius_wallet/providers/network_provider.dart';
import 'package:genius_wallet/providers/network_tokens_provider.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:local_secure_storage/local_secure_storage.dart';

const _validPhrase = 'a valid phrase';

const _activeWallet = Wallet(
  coinType: TWCoinType.TWCoinTypeEthereum,
  walletName: 'Main',
  currencySymbol: 'ETH',
  walletType: WalletType.privateKey,
  balance: 0,
  address: '0xACTIVE',
);

/// `implements`, not `extends`: the real constructor dlopens the native SDK.
/// [outcome] is what `addWalletFromSecret` reports; [addCalls] pins how many
/// times it was asked.
class _Api implements GeniusApi {
  _Api(this.outcome);

  final SDKAddOutcome outcome;
  int addCalls = 0;
  int selectCalls = 0;

  @override
  bool isValidMnemonic(String mnemonic) => mnemonic == _validPhrase;

  @override
  bool isValidPrivateKey(String privateKeyHex) => false;

  @override
  Future<SDKAddOutcome> addWalletFromSecret(
    String secret, {
    required bool isMnemonic,
  }) async {
    addCalls++;
    return outcome;
  }

  @override
  Stream<List<Wallet>> getWallets() => Stream.value(const []);

  @override
  List<String> getAvailableAccounts() => const ['0xAAAA'];

  @override
  Future<Map<String, SDKAccountLink>> getSDKAccountLinks() async => const {};

  @override
  Stream<SGNUSConnection> getSGNUSConnectionStream() =>
      Stream.value(SGNUSConnection.empty());

  @override
  String? getStartAccountAddress() => null;

  @override
  String? getSelectedAccountAddress() => null;

  @override
  Future<GeniusNodeReturnValue> selectGeniusAccountAsync(
    String publicAddress,
  ) async {
    selectCalls++;
    return GeniusNodeReturnValue.GENIUS_NODE_RET_OK;
  }

  @override
  String? getSelectedAccountMnemonic() => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _SeededAppBloc extends AppBloc {
  _SeededAppBloc({
    required super.api,
    required super.transactionsCubit,
    required super.walletDetailsCubit,
    required super.networkProvider,
  }) {
    emit(state.copyWith(sdkAccounts: const ['0xAAAA']));
  }
}

/// Counts calls to [selectWallet] rather than letting one through: D-04 says
/// adding through the SDK form never changes the active wallet, and the real
/// method writes to a Hive box this test never opens.
class _TrackingWalletDetailsCubit extends WalletDetailsCubit {
  _TrackingWalletDetailsCubit({
    required super.initialState,
    required super.geniusApi,
    required super.networkTokensProvider,
  });

  int selectCalls = 0;

  @override
  Future<void> selectWallet(Wallet wallet) async {
    selectCalls++;
  }
}

GWButton _addButton(WidgetTester tester) =>
    tester.widget<GWButton>(find.widgetWithText(GWButton, 'Add account').last);

/// Providers wrap `MaterialApp` itself - `ResponsiveDrawer.show` pushes on
/// the root navigator, so a provider read from inside the pushed route
/// resolves against a different subtree otherwise.
Widget _host(_SeededAppBloc bloc, WalletDetailsCubit details) =>
    MultiBlocProvider(
      providers: [
        BlocProvider<WalletDetailsCubit>.value(value: details),
        BlocProvider<AppBloc>.value(value: bloc),
      ],
      child: MaterialApp(
        theme: ThemeData.dark().copyWith(extensions: [GWColors.dark()]),
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => AccountDrawer.show(context),
              child: const Text('open drawer'),
            ),
          ),
        ),
      ),
    );

/// Opens the switcher drawer and its "Add from phrase or key" dialog. A tall
/// view so the node section's secondary button always builds without a
/// scroll, reset in the caller's `finally`.
Future<void> _openAddDialog(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1200, 2000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  await tester.tap(find.text('open drawer'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Add from phrase or key'));
  await tester.pumpAndSettle();
}

/// Opens the drawer's add dialog, types [_validPhrase] and submits it, then
/// settles the resulting toast.
Future<void> _submitValidPhrase(WidgetTester tester) async {
  await _openAddDialog(tester);

  await tester.enterText(find.byType(TextField), _validPhrase);
  await tester.pump();
  expect(_addButton(tester).onPressed, isNotNull);

  await tester.tap(find.widgetWithText(GWButton, 'Add account').last);
  // A 200ms step settles the toast's entry animation without a step wide
  // enough to straddle the shortest (1s) auto-dismiss duration.
  await tester.pumpAndSettle(const Duration(milliseconds: 200));
}

void main() {
  testWidgets('A refusal is reported as one, not a success', (tester) async {
    final api = _Api(SDKAddOutcome.failed);
    final details = WalletDetailsCubit(
      geniusApi: api,
      networkTokensProvider: NetworkTokensProvider(),
    );
    final bloc = _SeededAppBloc(
      api: api,
      transactionsCubit: TransactionsCubit(),
      walletDetailsCubit: details,
      networkProvider: NetworkProvider(),
    );
    try {
      await tester.pumpWidget(_host(bloc, details));
      await _openAddDialog(tester);

      expect(_addButton(tester).onPressed, isNull, reason: 'empty input');
      await tester.enterText(find.byType(TextField), 'not a phrase');
      await tester.pump();
      expect(_addButton(tester).onPressed, isNull, reason: 'malformed input');

      await tester.enterText(find.byType(TextField), _validPhrase);
      await tester.pump();
      expect(_addButton(tester).onPressed, isNotNull);

      await tester.tap(find.widgetWithText(GWButton, 'Add account').last);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(api.addCalls, 1);
      expect(find.text('That account could not be added.'), findsOneWidget);
      expect(find.textContaining('added successfully'), findsNothing);
      await tester.pumpAndSettle(const Duration(seconds: 5));
    } finally {
      await tester.runAsync(() => bloc.close());
      await details.close();
    }
  });

  testWidgets(
    'A wallet already in the app is reported, not duplicated, and selection '
    'is untouched',
    (tester) async {
      final api = _Api(SDKAddOutcome.alreadyThere);
      final details = _TrackingWalletDetailsCubit(
        initialState: const WalletDetailsState(selectedWallet: _activeWallet),
        geniusApi: api,
        networkTokensProvider: NetworkTokensProvider(),
      );
      final bloc = _SeededAppBloc(
        api: api,
        transactionsCubit: TransactionsCubit(),
        walletDetailsCubit: details,
        networkProvider: NetworkProvider(),
      );
      try {
        await tester.pumpWidget(_host(bloc, details));
        await _submitValidPhrase(tester);

        expect(api.addCalls, 1);
        expect(find.text('That wallet is already in the app.'), findsOneWidget);
        expect(api.selectCalls, 0);
        expect(details.selectCalls, 0);
        expect(details.state.selectedWallet, _activeWallet);
      } finally {
        await tester.runAsync(() => bloc.close());
        await details.close();
      }
    },
  );

  testWidgets('A saved wallet with no SDK account yet is reported pending', (
    tester,
  ) async {
    final api = _Api(SDKAddOutcome.pending);
    final details = WalletDetailsCubit(
      geniusApi: api,
      networkTokensProvider: NetworkTokensProvider(),
    );
    final bloc = _SeededAppBloc(
      api: api,
      transactionsCubit: TransactionsCubit(),
      walletDetailsCubit: details,
      networkProvider: NetworkProvider(),
    );
    try {
      await tester.pumpWidget(_host(bloc, details));
      await _submitValidPhrase(tester);

      expect(api.addCalls, 1);
      expect(
        find.text(
          'Wallet saved. Its SDK account is pending and will be added once '
          'the node is running.',
        ),
        findsOneWidget,
      );
    } finally {
      await tester.runAsync(() => bloc.close());
      await details.close();
    }
  });

  testWidgets('A new wallet is reported added, and selection is untouched', (
    tester,
  ) async {
    final api = _Api(SDKAddOutcome.added);
    final details = _TrackingWalletDetailsCubit(
      initialState: const WalletDetailsState(selectedWallet: _activeWallet),
      geniusApi: api,
      networkTokensProvider: NetworkTokensProvider(),
    );
    final bloc = _SeededAppBloc(
      api: api,
      transactionsCubit: TransactionsCubit(),
      walletDetailsCubit: details,
      networkProvider: NetworkProvider(),
    );
    try {
      await tester.pumpWidget(_host(bloc, details));
      await _submitValidPhrase(tester);

      expect(api.addCalls, 1);
      expect(find.text('Account added'), findsOneWidget);
      expect(api.selectCalls, 0);
      expect(details.selectCalls, 0);
      expect(details.state.selectedWallet, _activeWallet);
    } finally {
      await tester.runAsync(() => bloc.close());
      await details.close();
    }
  });

  testWidgets('Switching method swaps the form and clears the field', (
    tester,
  ) async {
    final api = _Api(SDKAddOutcome.failed);
    final details = WalletDetailsCubit(
      geniusApi: api,
      networkTokensProvider: NetworkTokensProvider(),
    );
    final bloc = _SeededAppBloc(
      api: api,
      transactionsCubit: TransactionsCubit(),
      walletDetailsCubit: details,
      networkProvider: NetworkProvider(),
    );
    try {
      await tester.pumpWidget(_host(bloc, details));
      await _openAddDialog(tester);

      const phraseHint = 'Paste 12 or 24 words, separated by spaces';
      const keyHint = 'Paste the Ethereum private key (hex)';
      expect(find.text(phraseHint), findsOneWidget);
      await tester.enterText(find.byType(TextField), _validPhrase);

      await tester.tap(find.text('Private key'));
      await tester.pumpAndSettle();
      expect(find.text(keyHint), findsOneWidget);
      expect(find.text(phraseHint), findsNothing);
      expect(find.text(_validPhrase), findsNothing, reason: 'field cleared');

      await tester.tap(find.text('Recovery phrase').first);
      await tester.pumpAndSettle();
      expect(find.text(phraseHint), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
    } finally {
      await tester.runAsync(() => bloc.close());
      await details.close();
    }
  });
}
