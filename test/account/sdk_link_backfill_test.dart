// Pins the one-time backfill for accounts older than the link feature:
// a re-add's single new address links, a one-to-one leftover pair links,
// and anything wider is left honestly 'Unlinked' rather than guessed.
// Also pins that the pass runs once after SDK start-up.
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/ffi/genius_api_ffi.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/sgnus_connection.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/dashboard/transactions/cubit/transactions_cubit.dart';
import 'package:genius_wallet/providers/network_provider.dart';
import 'package:genius_wallet/providers/network_tokens_provider.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:local_secure_storage/local_secure_storage.dart';

typedef _Candidate = ({
  String walletAddress,
  String walletName,
  GeniusNodeReturnValue Function() reAdd,
});

void main() {
  group('GeniusApi.backfillLinks', () {
    test('a re-add that appends one address links that address to the '
        'wallet, lowercased', () {
      final accounts = <String>['0xexisting'];
      final result = GeniusApi.backfillLinks(
        unlinked: <_Candidate>[
          (
            walletAddress: '0xW1',
            walletName: 'Main',
            reAdd: () {
              accounts.add('0xNEW1');
              return GeniusNodeReturnValue.GENIUS_NODE_RET_OK;
            },
          ),
        ],
        accounts: () => accounts,
        linkedSDKAddresses: const {},
      );

      expect(result, {'0xnew1': (walletAddress: '0xW1', walletName: 'Main')});
    });

    test('one no-op re-add plus exactly one leftover address: linked', () {
      final accounts = <String>['0xexisting', '0xleftover'];
      final result = GeniusApi.backfillLinks(
        unlinked: <_Candidate>[
          (
            walletAddress: '0xW1',
            walletName: 'Main',
            reAdd: () => GeniusNodeReturnValue.GENIUS_NODE_RET_OK,
          ),
        ],
        accounts: () => accounts,
        linkedSDKAddresses: const {'0xexisting'},
      );

      expect(result, {
        '0xleftover': (walletAddress: '0xW1', walletName: 'Main'),
      });
    });

    test('two no-op re-adds and two leftover addresses: nothing is linked', () {
      final accounts = <String>['0xleftover1', '0xleftover2'];
      final result = GeniusApi.backfillLinks(
        unlinked: <_Candidate>[
          (
            walletAddress: '0xW1',
            walletName: 'Main',
            reAdd: () => GeniusNodeReturnValue.GENIUS_NODE_RET_OK,
          ),
          (
            walletAddress: '0xW2',
            walletName: 'Second',
            reAdd: () => GeniusNodeReturnValue.GENIUS_NODE_RET_OK,
          ),
        ],
        accounts: () => accounts,
        linkedSDKAddresses: const {},
      );

      expect(result, isEmpty);
    });

    test('a re-add that appends two addresses stops the pass: the next '
        "wallet's re-add never runs and nothing more is linked", () {
      final accounts = <String>['0xexisting'];
      var secondReAddCalled = false;
      final result = GeniusApi.backfillLinks(
        unlinked: <_Candidate>[
          (
            walletAddress: '0xW1',
            walletName: 'Main',
            reAdd: () {
              accounts.addAll(['0xnew1', '0xnew2']);
              return GeniusNodeReturnValue.GENIUS_NODE_RET_OK;
            },
          ),
          (
            walletAddress: '0xW2',
            walletName: 'Second',
            reAdd: () {
              secondReAddCalled = true;
              return GeniusNodeReturnValue.GENIUS_NODE_RET_OK;
            },
          ),
        ],
        accounts: () => accounts,
        linkedSDKAddresses: const {},
      );

      expect(result, isEmpty);
      expect(secondReAddCalled, isFalse);
    });

    test('a re-add error never becomes an elimination candidate', () {
      final accounts = <String>['0xleftover'];
      final result = GeniusApi.backfillLinks(
        unlinked: <_Candidate>[
          (
            walletAddress: '0xW1',
            walletName: 'Main',
            reAdd: () =>
                GeniusNodeReturnValue.GENIUS_NODE_ERROR_NOT_INITIALIZED,
          ),
        ],
        accounts: () => accounts,
        linkedSDKAddresses: const {},
      );

      expect(result, isEmpty);
    });

    test('the leftover pool for elimination excludes linkedSDKAddresses', () {
      final accounts = <String>['0xlinked', '0xleftover'];
      final result = GeniusApi.backfillLinks(
        unlinked: <_Candidate>[
          (
            walletAddress: '0xW1',
            walletName: 'Main',
            reAdd: () => GeniusNodeReturnValue.GENIUS_NODE_RET_OK,
          ),
        ],
        accounts: () => accounts,
        linkedSDKAddresses: const {'0xlinked'},
      );

      expect(result, {
        '0xleftover': (walletAddress: '0xW1', walletName: 'Main'),
      });
    });

    test('empty wallets and an empty account list: empty result, no '
        'exception', () {
      final result = GeniusApi.backfillLinks(
        unlinked: const <_Candidate>[],
        accounts: () => const [],
        linkedSDKAddresses: const {},
      );

      expect(result, isEmpty);
    });
  });

  group('AppBloc.InitializeSDK runs the backfill pass once', () {
    late _CountingApi api;
    late AppBloc bloc;

    setUp(() {
      api = _CountingApi();
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
      'after InitializeSDK, the pass ran once and sdkStatus is loaded',
      () async {
        bloc.add(LoadWallets());
        await bloc.stream.firstWhere(
          (s) => s.subscribeToWalletStatus == AppStatus.loaded,
        );

        bloc.add(InitializeSDK());
        final state = await bloc.stream.firstWhere(
          (s) => s.sdkAccountLinks.isNotEmpty,
        );

        expect(api.linkCalls, 1);
        expect(state.sdkStatus, AppStatus.loaded);
      },
    );
  });
}

/// `implements`, not `extends`: the real constructor dlopens the native SDK.
class _CountingApi implements GeniusApi {
  int linkCalls = 0;

  @override
  Future<void> initSDK() async {}

  @override
  Future<void> linkExistingSDKAccounts() async {
    linkCalls++;
  }

  @override
  Stream<List<Wallet>> getWallets() => Stream.value(const []);

  @override
  Stream<SGNUSConnection> getSGNUSConnectionStream() => Stream.value(
    const SGNUSConnection(
      sgnusAddress: '',
      walletAddress: '',
      isConnected: false,
    ),
  );

  @override
  String? getSelectedAccountAddress() => null;

  @override
  String? getStartAccountAddress() => '0xstart';

  @override
  List<String> getAvailableAccounts() => const [];

  @override
  Future<Map<String, SDKAccountLink>> getSDKAccountLinks() async => {
    '0xstart': (walletAddress: '0xstart', walletName: 'Main'),
  };

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
