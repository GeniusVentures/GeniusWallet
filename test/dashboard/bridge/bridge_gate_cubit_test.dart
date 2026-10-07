import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/ffi/trust_wallet_api_ffi.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/coin.dart';
import 'package:genius_api/models/network.dart';
import 'package:genius_api/models/token.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/child_wallets/child_operations_cubit.dart';
import 'package:genius_wallet/child_wallets/child_wallets_cubit.dart'
    show ChildWallet;
import 'package:genius_wallet/dashboard/bridge/bridge_gate.dart';
import 'package:genius_wallet/dashboard/bridge/bridge_gate_cubit.dart';
import 'package:genius_wallet/providers/network_tokens_provider.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';

class _UnusedApi implements GeniusApi {
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _FakeChildOps extends ChildOperationsCubit {
  _FakeChildOps(AppState Function() readAppState)
    : super(api: _UnusedApi(), readAppState: readAppState);

  Map<String, List<ChildWallet>>? registrations;
  int reads = 0;

  @override
  Map<String, List<ChildWallet>>? ownRegistrations() {
    reads++;
    return registrations;
  }

  // A const state would be the same instance and never emit.
  // ignore: prefer_const_constructors
  void reemit() => emit(ChildOperationsState(operations: []));

  Future<void> publish(Map<String, List<ChildWallet>>? next) async {
    registrations = next;
    reemit();
    await Future<void>.delayed(Duration.zero);
  }
}

class _TestWalletDetails extends WalletDetailsCubit {
  _TestWalletDetails({
    required super.initialState,
    required super.geniusApi,
    required super.networkTokensProvider,
  });

  void push(WalletDetailsState next) => emit(next);
}

class _Read {
  _Read(this.rpc);

  final String rpc;
  final result = Completer<double>();
}

/// Every balance read waits on a completer, so pending and stale cases are
/// explicit.
class _Reads {
  final calls = <_Read>[];

  Future<double> call({
    required String address,
    required String contractAddress,
    required String rpcUrl,
  }) {
    final read = _Read(rpcUrl);
    calls.add(read);
    return read.result.future;
  }

  void answer(int from, Map<String, double> values, {int? to}) {
    for (final read in calls.skip(from).take((to ?? calls.length) - from)) {
      if (!read.result.isCompleted) {
        read.result.complete(values[read.rpc] ?? 0);
      }
    }
  }

  void fail(int from) {
    for (final read in calls.skip(from)) {
      if (!read.result.isCompleted) {
        read.result.completeError(StateError('rpc down'));
      }
    }
  }
}

Network _net(String name, int chainId, {bool testnet = false}) => Network(
  name: name,
  symbol: name.toLowerCase(),
  chainId: chainId,
  rpcUrl: 'https://rpc.$chainId.invalid',
  testnet: testnet,
);

final _ethereum = _net('Ethereum', 1);
final _polygon = _net('Polygon', 137);
final _base = _net('Base', 8453);
final _sepolia = _net('Ethereum Sepolia', 11155111, testnet: true);
final _baseSepolia = _net('Base - Sepolia', 84532, testnet: true);

const _amoy = Network(
  name: 'Polygon Amoy',
  symbol: 'matic',
  chainId: 80002,
  rpcUrl: 'https://rpc.invalid',
);

const _walletAddress = '0xAbCd567890123456789012345678901234567890';
const _otherWallet = '0x1111111111111111111111111111111111111111';
final _earningAccount = '0x${'a' * 128}';
final _mainAccount = '0x${'b' * 128}';

const _wallet = Wallet(
  coinType: TWCoinType.TWCoinTypeEthereum,
  walletName: 'Test Wallet',
  currencySymbol: 'MATIC',
  walletType: WalletType.mnemonic,
  balance: 0,
  address: _walletAddress,
);

const _otherWalletModel = Wallet(
  coinType: TWCoinType.TWCoinTypeEthereum,
  walletName: 'Other Wallet',
  currencySymbol: 'MATIC',
  walletType: WalletType.mnemonic,
  balance: 0,
  address: _otherWallet,
);

const _gnus = Coin(symbol: 'GNUS', address: '0xabc', balance: 10);

// A fresh list each call: a coins refresh is a new list instance.
List<Coin> _noGnus() => [const Coin(symbol: 'GNUS', address: '0xabc')];

AppState _app({String? earning, String? switching}) => AppState(
  selectedSDKAccount: earning ?? _earningAccount,
  switchingSDKAccount: switching,
  sdkAccounts: [_earningAccount, _mainAccount],
  sdkAccountLinks: {
    _earningAccount.toLowerCase(): (
      walletAddress: _walletAddress.toLowerCase(),
      walletName: 'Linked',
    ),
    _mainAccount.toLowerCase(): (
      walletAddress: _otherWallet,
      walletName: 'Main',
    ),
  },
);

ChildWallet _child(String address) => ChildWallet(
  address: address,
  name: 'Child',
  linkedWallet: null,
  balanceGnus: '0',
);

Future<void> _settle() => Future<void>.delayed(Duration.zero);

class _Rig {
  _Rig({
    Network network = _amoy,
    List<Coin> coins = const [_gnus],
    AppState? app,
    Map<String, List<ChildWallet>>? registrations,
  }) {
    this.app = app ?? _app();
    final provider = NetworkTokensProvider();
    for (final n in [_ethereum, _base, _sepolia, _baseSepolia, _polygon]) {
      provider.tokensByNetwork[n] = [
        Token(name: 'GNUS', address: '0x${n.chainId}'),
      ];
    }
    wallet = _TestWalletDetails(
      initialState: WalletDetailsState(
        selectedWallet: _wallet,
        selectedNetwork: network,
        coins: coins,
        coinsNetwork: network,
        coinsStatus: WalletStatus.successful,
      ),
      geniusApi: _UnusedApi(),
      networkTokensProvider: provider,
    );
    ops = _FakeChildOps(() => this.app)..registrations = registrations ?? {};
    gate = BridgeGateCubit(
      readAppState: () => this.app,
      appStates: appStream.stream,
      walletDetails: wallet,
      childOperations: ops,
      balanceOf: reads.call,
    );
  }

  late AppState app;
  final appStream = StreamController<AppState>.broadcast();
  final reads = _Reads();
  late final _TestWalletDetails wallet;
  late final _FakeChildOps ops;
  late final BridgeGateCubit gate;

  Future<void> refreshCoins(List<Coin> coins) async {
    wallet.push(wallet.state.copyWith(coins: coins));
    await _settle();
  }

  Future<void> dispose() async {
    await gate.close();
    await ops.close();
    await wallet.close();
    await appStream.close();
  }
}

void main() {
  late _Rig rig;

  setUp(() => rig = _Rig());
  tearDown(() => rig.dispose());

  test('the earning wallet listed under another own main is a child', () async {
    await rig.ops.publish({
      _mainAccount.toLowerCase(): [_child(_earningAccount)],
    });

    expect(rig.gate.resolveNow().state, BridgeGateState.child);
    expect(rig.gate.resolveNow().caption, "Child wallets can't bridge.");
  });

  test('an unreadable registrations read keeps the gate closed', () async {
    await rig.ops.publish(null);

    expect(rig.gate.resolveNow().state, BridgeGateState.checking);
    expect(rig.gate.state.caption, 'Checking your GNUS balance.');
    expect(rig.gate.state.enabled, isFalse);
  });

  test('an unreadable read is retried, not cached as not a child', () async {
    await rig.ops.publish(null);
    final before = rig.ops.reads;

    rig.gate.resolveNow();
    expect(rig.ops.reads, before + 1);

    await rig.ops.publish({
      _mainAccount.toLowerCase(): [_child(_earningAccount)],
    });
    expect(rig.gate.state.state, BridgeGateState.child);
  });

  test('an unreadable read runs no other-network probe', () async {
    final r = _Rig(network: _polygon, coins: _noGnus());
    addTearDown(r.dispose);
    await r.ops.publish(null);
    await r.refreshCoins(_noGnus());

    expect(r.reads.calls, hasLength(2));
    expect(r.gate.state.state, BridgeGateState.checking);
  });

  test('a mixed-case child address still matches', () async {
    await rig.ops.publish({
      _mainAccount.toLowerCase(): [_child('0x${'A' * 128}')],
    });

    expect(rig.gate.resolveNow().state, BridgeGateState.child);
  });

  test('an account listed only under itself is not a child', () async {
    await rig.ops.publish({
      _earningAccount.toLowerCase(): [_child(_earningAccount)],
    });

    expect(rig.gate.resolveNow().state, BridgeGateState.enabled);
  });

  test('unchanged inputs make one registrations read', () {
    final before = rig.ops.reads;

    rig.gate.resolveNow();
    rig.gate.resolveNow();

    expect(rig.ops.reads, before);
  });

  test('a re-emitted child operations state reads again', () async {
    final before = rig.ops.reads;

    rig.ops.reemit();
    await _settle();

    expect(rig.ops.reads, before + 1);
  });

  test('a child gate lifts when the registration disappears', () async {
    await rig.ops.publish({
      _mainAccount.toLowerCase(): [_child(_earningAccount)],
    });
    expect(rig.gate.state.state, BridgeGateState.child);

    await rig.ops.publish({});

    expect(rig.gate.state.state, BridgeGateState.enabled);
  });

  test('the gate follows an earning switch live', () async {
    expect(rig.gate.resolveNow().state, BridgeGateState.enabled);

    rig.app = _app(switching: _mainAccount);
    rig.appStream.add(rig.app);
    await _settle();
    expect(rig.gate.state.state, BridgeGateState.switching);
    expect(rig.gate.state.caption, 'Switching earning. Try again soon.');

    rig.app = _app(earning: _mainAccount);
    rig.appStream.add(rig.app);
    await _settle();
    expect(rig.gate.state.state, BridgeGateState.notEarning);
    expect(rig.gate.state.caption, 'Only the earning wallet can bridge.');

    rig.app = _app();
    rig.appStream.add(rig.app);
    await _settle();
    expect(rig.gate.state.state, BridgeGateState.enabled);
  });

  group('other-network probe', () {
    String rpc(Network n) => n.rpcUrl!;

    test('names the first network holding GNUS and changes nothing', () async {
      final r = _Rig(network: _polygon, coins: _noGnus());
      addTearDown(r.dispose);
      expect(r.gate.state.state, BridgeGateState.checking);
      expect(r.gate.state.caption, 'Checking your GNUS balance.');

      r.reads.answer(0, {rpc(_base): 5});
      await _settle();

      expect(r.gate.state.state, BridgeGateState.gnusElsewhere);
      expect(r.gate.state.caption, 'GNUS is on Base. Switch network.');
      expect(r.gate.state.enabled, isFalse);
      expect(r.wallet.state.selectedNetwork, _polygon);
    });

    test('the first positive in provider order wins', () async {
      final r = _Rig(network: _polygon, coins: _noGnus());
      addTearDown(r.dispose);

      r.reads.answer(0, {rpc(_base): 5, rpc(_ethereum): 1});
      await _settle();

      expect(r.gate.state.caption, 'GNUS is on Ethereum. Switch network.');
    });

    test('a mainnet reads no testnet and not the selected chain', () {
      final r = _Rig(network: _polygon, coins: _noGnus());
      addTearDown(r.dispose);

      expect(r.reads.calls.map((c) => c.rpc).toSet(), {
        rpc(_ethereum),
        rpc(_base),
      });
    });

    test('a testnet reads only other testnets', () {
      final r = _Rig(network: _baseSepolia, coins: _noGnus());
      addTearDown(r.dispose);

      expect(r.reads.calls.map((c) => c.rpc).toSet(), {rpc(_sepolia)});
    });

    test('every read zero means no GNUS and no network named', () async {
      final r = _Rig(network: _polygon, coins: _noGnus());
      addTearDown(r.dispose);

      r.reads.answer(0, {});
      await _settle();

      expect(r.gate.state.state, BridgeGateState.noGnus);
      expect(r.gate.state.caption, 'You have no GNUS to bridge.');
      expect(r.gate.state.elsewhereNetwork, isNull);
    });

    test('every read failing means no GNUS and no network named', () async {
      final r = _Rig(network: _polygon, coins: _noGnus());
      addTearDown(r.dispose);

      r.reads.fail(0);
      await _settle();

      expect(r.gate.state.state, BridgeGateState.noGnus);
      expect(r.gate.state.elsewhereNetwork, isNull);
    });

    test('a read that never answers counts as zero', () {
      fakeAsync((async) {
        final r = _Rig(network: _polygon, coins: _noGnus());
        expect(r.reads.calls.first.rpc, rpc(_ethereum));
        r.reads.answer(1, {rpc(_base): 5});
        async.flushMicrotasks();
        expect(r.gate.state.state, BridgeGateState.checking);

        async.elapse(const Duration(seconds: 30));

        expect(r.gate.state.state, BridgeGateState.gnusElsewhere);
        expect(r.gate.state.caption, 'GNUS is on Base. Switch network.');
        unawaited(r.dispose());
      });
    });

    test('every read hanging still ends on no GNUS', () {
      fakeAsync((async) {
        final r = _Rig(network: _polygon, coins: _noGnus());
        async.elapse(const Duration(seconds: 30));

        expect(r.gate.state.state, BridgeGateState.noGnus);
        unawaited(r.dispose());
      });
    });

    test('a wallet switch mid-probe discards the older results', () async {
      final r = _Rig(network: _polygon, coins: _noGnus());
      addTearDown(r.dispose);
      expect(r.reads.calls, hasLength(2));

      r.app = _app(earning: _mainAccount);
      r.appStream.add(r.app);
      await _settle();
      r.wallet.push(r.wallet.state.copyWith(selectedWallet: _otherWalletModel));
      await _settle();
      expect(r.reads.calls, hasLength(4));

      r.reads.answer(0, {rpc(_base): 5}, to: 2);
      await _settle();
      expect(r.gate.state.state, BridgeGateState.checking);

      r.reads.answer(2, {});
      await _settle();
      expect(r.gate.state.state, BridgeGateState.noGnus);
    });

    test('an earlier rung that fails runs no read', () {
      final notEarning = _Rig(
        network: _polygon,
        coins: _noGnus(),
        app: _app(earning: _mainAccount),
      );
      addTearDown(notEarning.dispose);
      final switching = _Rig(
        network: _polygon,
        coins: _noGnus(),
        app: _app(switching: _mainAccount),
      );
      addTearDown(switching.dispose);
      final child = _Rig(
        network: _polygon,
        coins: _noGnus(),
        registrations: {
          _mainAccount.toLowerCase(): [_child(_earningAccount)],
        },
      );
      addTearDown(child.dispose);

      expect(notEarning.gate.state.state, BridgeGateState.notEarning);
      expect(switching.gate.state.state, BridgeGateState.switching);
      expect(child.gate.state.state, BridgeGateState.child);
      expect(notEarning.reads.calls, isEmpty);
      expect(switching.reads.calls, isEmpty);
      expect(child.reads.calls, isEmpty);
    });

    test('GNUS on the selected network runs no read', () {
      final r = _Rig(network: _polygon);
      addTearDown(r.dispose);

      expect(r.gate.state.state, BridgeGateState.enabled);
      expect(r.reads.calls, isEmpty);
    });

    test('resolving again with the same coins runs no second read', () {
      final r = _Rig(network: _polygon, coins: _noGnus());
      addTearDown(r.dispose);

      r.gate.resolveNow();
      r.gate.resolveNow();

      expect(r.reads.calls, hasLength(2));
    });

    test('mock mode alone does not suppress the probe', () async {
      final r = _Rig(network: _polygon, coins: _noGnus());
      addTearDown(r.dispose);
      r.wallet.mockMode = true;

      await r.refreshCoins(_noGnus());

      expect(r.reads.calls, hasLength(4));
    });

    test('a state change that keeps the coins list runs no read', () async {
      final r = _Rig(network: _polygon, coins: _noGnus());
      addTearDown(r.dispose);
      r.reads.answer(0, {});
      await _settle();

      r.wallet.push(r.wallet.state.copyWith(gasFees: 2));
      await _settle();

      expect(r.reads.calls, hasLength(2));
      expect(r.gate.state.state, BridgeGateState.noGnus);
    });

    test('a coins refresh probes again and keeps the old outcome', () async {
      final r = _Rig(network: _polygon, coins: _noGnus());
      addTearDown(r.dispose);
      r.reads.answer(0, {});
      await _settle();
      expect(r.gate.state.caption, 'You have no GNUS to bridge.');

      await r.refreshCoins(_noGnus());
      expect(r.reads.calls, hasLength(4));
      expect(r.gate.state.caption, 'You have no GNUS to bridge.');

      r.reads.answer(2, {rpc(_base): 5});
      await _settle();
      expect(r.gate.state.caption, 'GNUS is on Base. Switch network.');

      await r.refreshCoins(_noGnus());
      expect(r.reads.calls, hasLength(6));
    });

    test('an overtaken re-probe never lands', () async {
      final r = _Rig(network: _polygon, coins: _noGnus());
      addTearDown(r.dispose);
      r.reads.answer(0, {});
      await _settle();

      await r.refreshCoins(_noGnus());
      await r.refreshCoins(_noGnus());
      expect(r.reads.calls, hasLength(6));

      r.reads.answer(4, {rpc(_base): 5});
      await _settle();
      expect(r.gate.state.caption, 'GNUS is on Base. Switch network.');

      r.reads.answer(2, {}, to: 4);
      await _settle();
      expect(r.gate.state.caption, 'GNUS is on Base. Switch network.');
    });
  });
}
