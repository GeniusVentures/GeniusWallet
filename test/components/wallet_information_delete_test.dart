// `wallet_information.dart`'s "More Options" delete used to call
// `geniusApi.deleteWallet` directly, skipping AppBloc's last-wallet guard
// entirely (D-12). This pins the fixed path: More -> Delete Wallet reaches
// the bloc, which enforces the same rule every other delete surface does.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/ffi/trust_wallet_api_ffi.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/sgnus_connection.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/components/wallet_information.dart';
import 'package:genius_wallet/dashboard/transactions/cubit/transactions_cubit.dart';
import 'package:genius_wallet/providers/network_provider.dart';
import 'package:genius_wallet/providers/network_tokens_provider.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:local_secure_storage/local_secure_storage.dart'
    show SDKAccountLink;
import 'package:provider/provider.dart';

const _addrA = '0xAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA';
const _addrB = '0xBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB';

Wallet _eth(String name, String address) => Wallet(
  coinType: TWCoinType.TWCoinTypeEthereum,
  walletName: name,
  currencySymbol: 'ETH',
  walletType: WalletType.privateKey,
  balance: 0,
  address: address,
);

/// `implements`, not `extends`: the real constructor dlopens the native SDK.
class _Api implements GeniusApi {
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
  String getMinionsBalance([String? tokenId]) => '0';

  @override
  String? getSelectedAccountAddress() => null;

  @override
  String? getStartAccountAddress() => null;

  @override
  List<String> getAvailableAccounts() => const [];

  @override
  Future<Map<String, SDKAccountLink>> getSDKAccountLinks() async => {};

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _SeededAppBloc extends AppBloc {
  _SeededAppBloc({
    required super.api,
    required super.walletDetailsCubit,
    required List<Wallet> wallets,
  }) : super(
         transactionsCubit: TransactionsCubit(),
         networkProvider: NetworkProvider(),
       ) {
    emit(state.copyWith(wallets: wallets));
  }
}

Future<void> _pumpWalletInformation(
  WidgetTester tester, {
  required _Api api,
  required WalletDetailsCubit cubit,
  required AppBloc appBloc,
}) => tester.pumpWidget(
  MultiBlocProvider(
    providers: [
      BlocProvider<WalletDetailsCubit>.value(value: cubit),
      BlocProvider<AppBloc>.value(value: appBloc),
    ],
    child: Provider<GeniusApi>.value(
      value: api,
      child: MaterialApp(
        theme: ThemeData.dark().copyWith(extensions: [GWColors.dark()]),
        home: Scaffold(
          body: WalletInformation(
            const BoxConstraints(),
            ovrAddressField: cubit.state.selectedWallet?.address ?? '',
            walletType: WalletType.privateKey,
          ),
        ),
      ),
    ),
  ),
);

Future<void> _openMoreAndTapDelete(WidgetTester tester) async {
  await tester.tap(find.text('More'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Delete Wallet'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'with two wallets, More then Delete Wallet reaches the bloc\'s delete '
    'exactly once',
    (tester) async {
      final main = _eth('Main wallet', _addrA);
      final api = _Api();
      final cubit = WalletDetailsCubit(
        initialState: WalletDetailsState(selectedWallet: main),
        geniusApi: api,
        networkTokensProvider: NetworkTokensProvider(),
      );
      final appBloc = _SeededAppBloc(
        api: api,
        walletDetailsCubit: cubit,
        wallets: [main, _eth('Savings', _addrB)],
      );
      try {
        await _pumpWalletInformation(
          tester,
          api: api,
          cubit: cubit,
          appBloc: appBloc,
        );

        await _openMoreAndTapDelete(tester);

        expect(api.deleted, _addrA);
        expect(api.deletedWatchOnly, isFalse);
      } finally {
        await tester.runAsync(() => appBloc.close());
        await cubit.close();
      }
    },
  );

  testWidgets('with one wallet, the warning shows and nothing is deleted', (
    tester,
  ) async {
    final main = _eth('Main wallet', _addrA);
    final api = _Api();
    final cubit = WalletDetailsCubit(
      initialState: WalletDetailsState(selectedWallet: main),
      geniusApi: api,
      networkTokensProvider: NetworkTokensProvider(),
    );
    final appBloc = _SeededAppBloc(
      api: api,
      walletDetailsCubit: cubit,
      wallets: [main],
    );
    try {
      await _pumpWalletInformation(
        tester,
        api: api,
        cubit: cubit,
        appBloc: appBloc,
      );

      await _openMoreAndTapDelete(tester);

      expect(find.text('You must keep at least one wallet.'), findsOneWidget);
      expect(api.deleted, isNull);
    } finally {
      await tester.runAsync(() => appBloc.close());
      await cubit.close();
    }
  });
}
