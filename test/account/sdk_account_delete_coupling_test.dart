// Deleting an SDK account takes its linked wallet with it (D-10), refuses
// while that wallet is active or is the last one (D-11), and a plain wallet
// delete never reaches an SDK account at all (D-08).
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/ffi/genius_api_ffi.dart';
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
import 'package:local_secure_storage/local_secure_storage.dart'
    show SDKAccountLink;

const _sdkAddr = '0xSDK';
const _walletAddr = '0xWALLET';

Wallet _eth(String name, String address) => Wallet(
  coinType: TWCoinType.TWCoinTypeEthereum,
  walletName: name,
  currencySymbol: 'ETH',
  walletType: WalletType.privateKey,
  balance: 0,
  address: address,
);

final _link = <String, SDKAccountLink>{
  _sdkAddr.toLowerCase(): (
    walletAddress: _walletAddr.toLowerCase(),
    walletName: 'Main',
  ),
};

/// `implements`, not `extends`: the real constructor dlopens the native SDK.
/// No wallet in this file's bloc-level tests is the default account -
/// [AppBloc.sdkDeleteBlock]'s own unit tests above cover that branch.
class _Api implements GeniusApi {
  GeniusNodeReturnValue deleteAccountResult =
      GeniusNodeReturnValue.GENIUS_NODE_RET_OK;

  final deletedAccounts = <String>[];
  final removedLinks = <String>[];
  String? deletedWallet;
  bool? deletedWatchOnly;

  @override
  String? getStartAccountAddress() => null;

  @override
  String? getSelectedAccountAddress() => null;

  @override
  String? getSelectedAccountMnemonic() => null;

  @override
  List<String> getAvailableAccounts() => const [];

  @override
  Future<Map<String, SDKAccountLink>> getSDKAccountLinks() async => {};

  @override
  Stream<SGNUSConnection> getSGNUSConnectionStream() =>
      Stream.value(SGNUSConnection.empty());

  @override
  GeniusNodeReturnValue deleteAccount(String publicAddress) {
    deletedAccounts.add(publicAddress);
    return deleteAccountResult;
  }

  @override
  Future<void> removeSDKAccountLink(String sdkAddress) async {
    removedLinks.add(sdkAddress);
  }

  @override
  Future<void> deleteWallet(String address, {required bool watchOnly}) async {
    deletedWallet = address;
    deletedWatchOnly = watchOnly;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _SeededAppBloc extends AppBloc {
  _SeededAppBloc({
    required super.api,
    required super.walletDetailsCubit,
    required List<Wallet> wallets,
    Map<String, SDKAccountLink> sdkAccountLinks = const {},
    List<String> sdkAccounts = const [],
  }) : super(
         transactionsCubit: TransactionsCubit(),
         networkProvider: NetworkProvider(),
       ) {
    emit(
      state.copyWith(
        wallets: wallets,
        sdkAccountLinks: sdkAccountLinks,
        sdkAccounts: sdkAccounts,
      ),
    );
  }
}

void main() {
  final wallet = _eth('Main', _walletAddr);
  final other = _eth('Savings', '0xOTHER');

  group('AppBloc.sdkDeleteBlock', () {
    test(
      'the default account is always blocked, matched case-insensitively',
      () {
        expect(
          AppBloc.sdkDeleteBlock(
            sdkAddress: _sdkAddr,
            defaultAccount: _sdkAddr.toUpperCase(),
            links: _link,
            wallets: [wallet, other],
            activeWallet: null,
          ),
          SDKDeleteBlock.defaultAccount,
        );
      },
    );

    test('an unlinked account is never blocked', () {
      expect(
        AppBloc.sdkDeleteBlock(
          sdkAddress: '0xUNLINKED',
          defaultAccount: null,
          links: _link,
          wallets: [wallet, other],
          activeWallet: null,
        ),
        isNull,
      );
    });

    test('a linked account whose wallet is active is blocked', () {
      expect(
        AppBloc.sdkDeleteBlock(
          sdkAddress: _sdkAddr,
          defaultAccount: null,
          links: _link,
          wallets: [wallet, other],
          activeWallet: wallet,
        ),
        SDKDeleteBlock.activeWallet,
      );
    });

    test('a same-address SDK row being active does not count as its wallet '
        'being active', () {
      final sdkTwin = wallet.copyWith(walletType: WalletType.sgnus);
      expect(
        AppBloc.sdkDeleteBlock(
          sdkAddress: _sdkAddr,
          defaultAccount: null,
          links: _link,
          wallets: [wallet, other],
          activeWallet: sdkTwin,
        ),
        isNull,
      );
    });

    test('a linked account is blocked as the last wallet', () {
      expect(
        AppBloc.sdkDeleteBlock(
          sdkAddress: _sdkAddr,
          defaultAccount: null,
          links: _link,
          wallets: [wallet],
          activeWallet: null,
        ),
        SDKDeleteBlock.lastWallet,
      );
    });

    test('a linked account with another wallet left, and not active, is '
        'allowed', () {
      expect(
        AppBloc.sdkDeleteBlock(
          sdkAddress: _sdkAddr,
          defaultAccount: null,
          links: _link,
          wallets: [wallet, other],
          activeWallet: other,
        ),
        isNull,
      );
    });
  });

  group('DeleteSDKAccount', () {
    test('linked and not active deletes the account, the link and the '
        'wallet', () async {
      final api = _Api();
      final details = WalletDetailsCubit(
        initialState: WalletDetailsState(selectedWallet: other),
        geniusApi: api,
        networkTokensProvider: NetworkTokensProvider(),
      );
      final bloc = _SeededAppBloc(
        api: api,
        walletDetailsCubit: details,
        wallets: [wallet, other],
        sdkAccountLinks: _link,
      );

      bloc.add(DeleteSDKAccount(_sdkAddr));
      await bloc.close();
      await details.close();

      expect(api.deletedAccounts, [_sdkAddr]);
      expect(api.removedLinks, [_sdkAddr]);
      expect(api.deletedWallet, _walletAddr);
      expect(api.deletedWatchOnly, isFalse);
    });

    test('linked to the active wallet deletes nothing', () async {
      final api = _Api();
      final details = WalletDetailsCubit(
        initialState: WalletDetailsState(selectedWallet: wallet),
        geniusApi: api,
        networkTokensProvider: NetworkTokensProvider(),
      );
      final bloc = _SeededAppBloc(
        api: api,
        walletDetailsCubit: details,
        wallets: [wallet, other],
        sdkAccountLinks: _link,
      );

      bloc.add(DeleteSDKAccount(_sdkAddr));
      await bloc.close();
      await details.close();

      expect(api.deletedAccounts, isEmpty);
      expect(api.removedLinks, isEmpty);
      expect(api.deletedWallet, isNull);
    });

    test('unlinked deletes only the account', () async {
      final api = _Api();
      final details = WalletDetailsCubit(
        geniusApi: api,
        networkTokensProvider: NetworkTokensProvider(),
      );
      final bloc = _SeededAppBloc(
        api: api,
        walletDetailsCubit: details,
        wallets: [wallet, other],
      );

      bloc.add(DeleteSDKAccount(_sdkAddr));
      await bloc.close();
      await details.close();

      expect(api.deletedAccounts, [_sdkAddr]);
      expect(api.deletedWallet, isNull);
    });

    test('an SDK refusal deletes no wallet', () async {
      final api = _Api()
        ..deleteAccountResult =
            GeniusNodeReturnValue.GENIUS_NODE_ERROR_NOT_INITIALIZED;
      final details = WalletDetailsCubit(
        initialState: WalletDetailsState(selectedWallet: other),
        geniusApi: api,
        networkTokensProvider: NetworkTokensProvider(),
      );
      final bloc = _SeededAppBloc(
        api: api,
        walletDetailsCubit: details,
        wallets: [wallet, other],
        sdkAccountLinks: _link,
      );

      bloc.add(DeleteSDKAccount(_sdkAddr));
      await bloc.close();
      await details.close();

      expect(api.deletedAccounts, [_sdkAddr]);
      expect(api.removedLinks, isEmpty);
      expect(api.deletedWallet, isNull);
    });
  });

  test(
    'DeleteWallet never calls deleteAccount nor removeSDKAccountLink',
    () async {
      final api = _Api();
      final details = WalletDetailsCubit(
        initialState: WalletDetailsState(selectedWallet: other),
        geniusApi: api,
        networkTokensProvider: NetworkTokensProvider(),
      );
      final bloc = _SeededAppBloc(
        api: api,
        walletDetailsCubit: details,
        wallets: [wallet, other],
        sdkAccountLinks: _link,
      );

      bloc.add(DeleteWallet(_walletAddr, watchOnly: false));
      await bloc.close();
      await details.close();

      expect(api.deletedAccounts, isEmpty);
      expect(api.removedLinks, isEmpty);
      expect(api.deletedWallet, _walletAddr);
    },
  );

  testWidgets(
    'the delete dialog names the linked wallet, and refuses while it is '
    'the active wallet',
    (tester) async {
      final api = _Api();
      final details = WalletDetailsCubit(
        initialState: WalletDetailsState(selectedWallet: wallet),
        geniusApi: api,
        networkTokensProvider: NetworkTokensProvider(),
      );
      final bloc = _SeededAppBloc(
        api: api,
        walletDetailsCubit: details,
        wallets: [wallet, other],
        sdkAccountLinks: _link,
        sdkAccounts: [_sdkAddr],
      );
      try {
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
        expect(find.text('Main'), findsOneWidget);

        await tester.tap(find.byTooltip('Account options'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Delete account'));
        await tester.pumpAndSettle();

        expect(
          find.textContaining('"Main" is your active wallet.'),
          findsOneWidget,
        );
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();

        expect(api.deletedAccounts, isEmpty);
      } finally {
        await tester.runAsync(() => bloc.close());
        await details.close();
      }
    },
  );
}
