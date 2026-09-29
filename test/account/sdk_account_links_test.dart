// Pins how an SDK row is named from its link (LINK-01/LINK-02): the live
// wallet's name, the removed wallet's last name, or an honest 'Unlinked'.
// No path may guess a link from anything but the stored map.
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/ffi/trust_wallet_api_ffi.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/sgnus_connection.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/dashboard/transactions/cubit/transactions_cubit.dart';
import 'package:genius_wallet/providers/network_provider.dart';
import 'package:genius_wallet/providers/network_tokens_provider.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:local_secure_storage/local_secure_storage.dart';

Wallet _wallet(
  String name,
  String address, {
  WalletType type = WalletType.privateKey,
}) => Wallet(
  coinType: TWCoinType.TWCoinTypeEthereum,
  walletName: name,
  currencySymbol: 'ETH',
  walletType: type,
  balance: 0,
  address: address,
);

/// `implements`, not `extends`: the real constructor dlopens the native SDK.
class _LinkedApi implements GeniusApi {
  @override
  Stream<SGNUSConnection> getSGNUSConnectionStream() => Stream.value(
    const SGNUSConnection(
      sgnusAddress: '',
      walletAddress: '',
      isConnected: true,
    ),
  );

  @override
  List<String> getAvailableAccounts() => const ['0xS1', '0xS2'];

  @override
  Future<Map<String, SDKAccountLink>> getSDKAccountLinks() async => {
    '0xs1': (walletAddress: '0xmain', walletName: 'Main'),
  };

  @override
  String? getSelectedAccountAddress() => null;

  @override
  String? getStartAccountAddress() => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('AppBloc.linkedWallet / sdkAccountName', () {
    final main = _wallet('Main', '0xMAIN');
    final wallets = [main];

    test('a linked SDK address resolves to the wallet and its name', () {
      final links = {'0xsdk': (walletAddress: '0xmain', walletName: 'Main')};

      expect(AppBloc.linkedWallet('0xSDK', links, wallets), main);
      expect(AppBloc.sdkAccountName('0xSDK', links, wallets), 'Main');
    });

    test('a link whose wallet is gone reads "(wallet removed)"', () {
      final links = {'0xsdk': (walletAddress: '0xgone', walletName: 'Old')};

      expect(AppBloc.linkedWallet('0xSDK', links, wallets), isNull);
      expect(
        AppBloc.sdkAccountName('0xSDK', links, wallets),
        'Old (wallet removed)',
      );
    });

    test('no link at all reads "Unlinked"', () {
      expect(AppBloc.linkedWallet('0xSDK', const {}, wallets), isNull);
      expect(AppBloc.sdkAccountName('0xSDK', const {}, wallets), 'Unlinked');
    });

    test('the lookup is case-insensitive on the SDK address', () {
      final links = {'0xsdk': (walletAddress: '0xmain', walletName: 'Main')};

      expect(AppBloc.sdkAccountName('0XsDk', links, wallets), 'Main');
    });

    test('a watch-only wallet at the linked address does not count', () {
      final watchOnly = [
        _wallet('Watching', '0xmain', type: WalletType.tracking),
      ];
      final links = {'0xsdk': (walletAddress: '0xmain', walletName: 'Main')};

      expect(AppBloc.linkedWallet('0xSDK', links, watchOnly), isNull);
      expect(
        AppBloc.sdkAccountName('0xSDK', links, watchOnly),
        'Main (wallet removed)',
      );
    });

    test('empty links and empty wallets give Unlinked, never throw', () {
      expect(AppBloc.sdkAccountName('0xSDK', const {}, const []), 'Unlinked');
    });
  });

  group('_mergeSgnusWallet names rows from the link map', () {
    late AppBloc bloc;

    setUp(() {
      final api = _LinkedApi();
      bloc = AppBloc(
        api: api,
        transactionsCubit: TransactionsCubit(),
        walletDetailsCubit: WalletDetailsCubit(
          geniusApi: api,
          networkTokensProvider: NetworkTokensProvider(),
        ),
        networkProvider: NetworkProvider(),
      );
    });

    tearDown(() async {
      await bloc.close();
    });

    test(
      'a refresh names the linked row and the unlinked row honestly',
      () async {
        bloc.add(RefreshSDKAccounts());
        await Future<void>.delayed(const Duration(milliseconds: 50));

        final names = {
          for (final w in bloc.state.wallets) w.address: w.walletName,
        };
        expect(names['0xS1'], 'Main (wallet removed)');
        expect(names['0xS2'], 'Unlinked');
      },
    );
  });
}
