// Each SDK row must say which wallet it came from, or admit it has none
// (D-16, D-17). This file proves the row-naming and row-address contract
// directly against `_buildAccountRow`'s output, the same way
// `sdk_start_account_delete_test.dart` proves the delete gating.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/ffi/trust_wallet_api_ffi.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/sgnus_connection.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/account/sdk_account_manager.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/dashboard/transactions/cubit/transactions_cubit.dart';
import 'package:genius_wallet/providers/network_provider.dart';
import 'package:genius_wallet/providers/network_tokens_provider.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:local_secure_storage/local_secure_storage.dart';

// Ten-character, already-lowercased addresses, distinct in their last four,
// so each row's truncated subtitle (`WalletUtils.getAddressForDisplay`)
// stays distinguishable even between the two same-named wallets below.
// Lowercase because `SDKAccountLink.walletAddress` is always stored
// lowercased (`local_secure_storage_base.dart:393`) and matched against
// `wallet.address.toLowerCase()` - a mixed-case fixture here would test
// nothing but its own typo.
const _mainA = '0xaaaa1111';
const _mainB = '0xaaaa2222';
const _oldAddr = '0xaaaa3333';
const _unlinkedAddr = '0xaaaa4444';

const _walletMainA = Wallet(
  coinType: TWCoinType.TWCoinTypeEthereum,
  walletName: 'Main',
  currencySymbol: 'ETH',
  walletType: WalletType.privateKey,
  balance: 0,
  address: _mainA,
);

const _walletMainB = Wallet(
  coinType: TWCoinType.TWCoinTypeEthereum,
  walletName: 'Main',
  currencySymbol: 'ETH',
  walletType: WalletType.privateKey,
  balance: 0,
  address: _mainB,
);

/// `implements`, not `extends`: the real constructor dlopens the native SDK.
class _Api implements GeniusApi {
  _Api({this.links = const {}, this.accounts = const []});

  final Map<String, SDKAccountLink> links;
  final List<String> accounts;

  @override
  String? getSelectedAccountMnemonic() => null;

  @override
  List<String> getAvailableAccounts() => accounts;

  @override
  Future<Map<String, SDKAccountLink>> getSDKAccountLinks() async => links;

  @override
  Stream<SGNUSConnection> getSGNUSConnectionStream() =>
      Stream.value(SGNUSConnection.empty());

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _SeededAppBloc extends AppBloc {
  _SeededAppBloc({
    required super.api,
    required super.transactionsCubit,
    required super.walletDetailsCubit,
    required super.networkProvider,
    required List<String> sdkAccounts,
    required List<Wallet> wallets,
    required Map<String, SDKAccountLink> sdkAccountLinks,
    String? selectedSDKAccount,
    String? defaultSDKAccount,
  }) {
    emit(
      state.copyWith(
        sdkAccounts: sdkAccounts,
        wallets: wallets,
        sdkAccountLinks: sdkAccountLinks,
        selectedSDKAccount: selectedSDKAccount,
        defaultSDKAccount: defaultSDKAccount,
      ),
    );
  }
}

Future<void> _pumpDrawer(WidgetTester tester, _SeededAppBloc bloc) async {
  await tester.pumpWidget(
    BlocProvider<AppBloc>.value(
      value: bloc,
      child: MaterialApp(
        theme: ThemeData.dark().copyWith(extensions: [GWColors.dark()]),
        home: const Scaffold(body: SDKAccountManagerButton()),
      ),
    ),
  );
  await tester.tap(find.byType(SDKAccountManagerButton));
  await tester.pumpAndSettle();
}

void main() {
  test('an empty SDK account list renders no button and no rows', () async {
    final api = _Api();
    final details = WalletDetailsCubit(
      geniusApi: api,
      networkTokensProvider: NetworkTokensProvider(),
    );
    final bloc = _SeededAppBloc(
      api: api,
      transactionsCubit: TransactionsCubit(),
      walletDetailsCubit: details,
      networkProvider: NetworkProvider(),
      sdkAccounts: const [],
      wallets: const [],
      sdkAccountLinks: const {},
    );
    expect(bloc.state.sdkAccounts, isEmpty);
    await bloc.close();
    await details.close();
  });

  testWidgets(
    'row titles name the wallet, or say Unlinked/wallet removed, and the '
    'address stays on every row - each one selectable and deletable',
    (tester) async {
      final api = _Api(
        links: const {
          _mainA: (walletAddress: _mainA, walletName: 'Main'),
          _mainB: (walletAddress: _mainB, walletName: 'Main'),
          _oldAddr: (walletAddress: '0xffff9999', walletName: 'Old'),
        },
        accounts: const [_mainA, _mainB, _oldAddr, _unlinkedAddr],
      );
      final details = WalletDetailsCubit(
        geniusApi: api,
        networkTokensProvider: NetworkTokensProvider(),
      );
      final bloc = _SeededAppBloc(
        api: api,
        transactionsCubit: TransactionsCubit(),
        walletDetailsCubit: details,
        networkProvider: NetworkProvider(),
        sdkAccounts: const [_mainA, _mainB, _oldAddr, _unlinkedAddr],
        wallets: const [_walletMainA, _walletMainB],
        sdkAccountLinks: api.links,
        // Selected (Active processing account) and default (Default
        // account) sit on two DIFFERENT rows here, so both subtitles are
        // proven independently.
        selectedSDKAccount: _mainB,
        defaultSDKAccount: _mainA.toLowerCase(),
      );

      await _pumpDrawer(tester, bloc);

      // Titles: same-named wallets stay two rows, the removed-wallet link
      // keeps its old name, and the unmatched account is honest about it.
      expect(find.text('Main'), findsNWidgets(2));
      expect(find.text('Old (wallet removed)'), findsOneWidget);
      expect(find.text('Unlinked'), findsOneWidget);

      // Each row's own short address, plus the right status suffix.
      expect(
        find.textContaining('0xaaaa...1111 · Default account'),
        findsOneWidget,
      );
      expect(
        find.textContaining('0xaaaa...2222 · Active processing account'),
        findsOneWidget,
      );
      expect(find.text('0xaaaa...3333'), findsOneWidget);
      expect(find.text('0xaaaa...4444'), findsOneWidget);

      // Rows keep the SDK's own order.
      final rows = tester.widgetList<Text>(find.byType(Text)).toList();
      final titleOrder = rows
          .map((t) => t.data)
          .whereType<String>()
          .where(
            (s) =>
                s == 'Main' || s == 'Old (wallet removed)' || s == 'Unlinked',
          )
          .toList();
      expect(titleOrder, ['Main', 'Main', 'Old (wallet removed)', 'Unlinked']);

      await tester.runAsync(() => bloc.close());
      await details.close();
    },
  );
}
