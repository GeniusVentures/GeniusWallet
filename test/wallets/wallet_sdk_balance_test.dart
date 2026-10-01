// A wallet shows only its own SDK balance: the node's, a registered child's
// read through the node, or none at all - never another account's number.
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/ffi/genius_api_ffi.dart';
import 'package:genius_api/ffi/trust_wallet_api_ffi.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/coin.dart';
import 'package:genius_api/models/network.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/dev/dev_flags.dart';
import 'package:genius_wallet/dev/dev_mock_child_wallets.dart';
import 'package:genius_wallet/providers/network_tokens_provider.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:local_secure_storage/local_secure_storage.dart';

const _node = '0xNODE000000000000000000000000000000000001';
const _child = '0xCHILD00000000000000000000000000000000002';
const _stranger = '0xSTRANGER000000000000000000000000000000003';

class _FakeApi implements GeniusApi {
  List<ChildRegistration> children = const [];

  @override
  String getSGNUSBalance() => '7';

  @override
  String getMinionsBalance([String? tokenId]) => '7000000';

  @override
  ChildRegistrations getChildRegistrations(String mainAddress) => (
    result: GeniusNodeReturnValue.GENIUS_NODE_RET_OK,
    entries: mainAddress == _node ? children : const <ChildRegistration>[],
  );

  @override
  BigInt getChildBalance(String childAddress, {String? tokenId}) =>
      childAddress == _child ? BigInt.from(2500000) : BigInt.zero;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Wallet _wallet(String address, WalletType type) => Wallet(
  coinType: TWCoinType.TWCoinTypeEthereum,
  walletType: type,
  address: address,
  balance: 0,
  currencySymbol: 'minions',
  walletName: 'Test',
);

const _superGenius = Network(name: 'Super Genius', symbol: 'gnus', chainId: 1);

Future<WalletDetailsCubit> _read(
  Wallet wallet, {
  _FakeApi? api,
  String? node = _node,
  Map<String, SDKAccountLink> links = const {},
}) async {
  final cubit = WalletDetailsCubit(
    geniusApi: api ?? _FakeApi(),
    networkTokensProvider: NetworkTokensProvider(),
    initialState: WalletDetailsState(
      selectedWallet: wallet,
      selectedNetwork: _superGenius,
    ),
  );
  addTearDown(cubit.close);
  cubit.appStateChanged(
    AppState(selectedSDKAccount: node, sdkAccountLinks: links),
  );
  await cubit.getCoins();
  return cubit;
}

void main() {
  test('the node account keeps reading the node balance', () async {
    final cubit = await _read(_wallet(_node, WalletType.sgnus));

    expect(cubit.state.balanceUnreadable, isFalse);
    expect(cubit.state.coins.single.balance, 7);
    expect(cubit.readSdkBalance(), (gnus: 7.0, minions: 7000000.0));
  });

  test(
    'a registered child shows its own GNUS balance, no token rows',
    () async {
      final api = _FakeApi()
        ..children = const [
          ChildRegistration(
            childAddress: _child,
            mainAddress: _node,
            sequence: 0,
          ),
        ];
      final cubit = await _read(
        _wallet(_child.toLowerCase(), WalletType.sgnus),
        api: api,
      );

      expect(cubit.state.balanceUnreadable, isFalse);
      expect(cubit.state.coins.single.balance, 2.5);
      expect(cubit.readSdkBalance(), (gnus: 2.5, minions: 2500000.0));
    },
  );

  test('an own wallet reads through its linked SDK account', () async {
    final cubit = await _read(
      _wallet('0xOwnWallet', WalletType.mnemonic),
      links: {
        _node.toLowerCase(): (walletAddress: '0xownwallet', walletName: 'Own'),
      },
    );

    expect(cubit.state.balanceUnreadable, isFalse);
    expect(cubit.state.coins.single.balance, 7);
  });

  test('an account the node cannot read shows no number at all', () async {
    for (final cubit in [
      await _read(_wallet(_stranger, WalletType.sgnus)),
      await _read(_wallet(_node, WalletType.sgnus), node: null),
      await _read(_wallet('0xUnlinked', WalletType.mnemonic)),
    ]) {
      expect(cubit.state.balanceUnreadable, isTrue);
      expect(cubit.state.coins, isEmpty);
      expect(cubit.readSdkBalance(), isNull);
    }
  });

  test('switching the node account re-reads the balance', () async {
    final cubit = await _read(_wallet(_node, WalletType.sgnus), node: _child);
    expect(cubit.state.balanceUnreadable, isTrue);

    cubit.appStateChanged(const AppState(selectedSDKAccount: _node));
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.balanceUnreadable, isFalse);
    expect(cubit.state.coins.single.balance, 7);
  });

  test(
    'a failed read after an unreadable one drops the unreadable notice',
    () async {
      final cubit = await _read(_wallet('0xUnlinked', WalletType.mnemonic));
      expect(cubit.state.balanceUnreadable, isTrue);

      // An RPC network with no symbol fails its read before any fetch.
      cubit.selectNetwork(
        const Network(name: 'Broken', rpcUrl: 'https://rpc.invalid'),
      );
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.coinsStatus, WalletStatus.error);
      expect(cubit.state.balanceUnreadable, isFalse);
    },
  );

  test('injected dev holdings replace the unreadable notice', () async {
    final cubit = await _read(_wallet(_stranger, WalletType.sgnus));

    cubit.injectMockCoins(const [
      Coin(symbol: 'ETH', balance: 1),
    ], balance: '1');

    expect(cubit.state.balanceUnreadable, isFalse);
  });

  test(
    'a dev child preset still reads its mock balance',
    () async {
      DevMockChildWallets.instance.arm(DevChildWalletsPreset.oneChild);
      addTearDown(DevMockChildWallets.instance.clear);
      final cubit = await _read(
        _wallet(DevMockChildWallets.singleChildAddress, WalletType.sgnus),
      );

      expect(cubit.state.coins.single.balance, 1.5);
    },
    skip: kShowDevTools ? null : 'needs --dart-define=GW_DEV_TOOLS=true',
  );
}
