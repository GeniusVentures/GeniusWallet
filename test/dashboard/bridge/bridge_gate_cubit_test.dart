import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/ffi/trust_wallet_api_ffi.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/coin.dart';
import 'package:genius_api/models/network.dart';
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

const _gnus = Coin(symbol: 'GNUS', address: '0xabc', balance: 10);

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
  _Rig() {
    app = _app();
    wallet = WalletDetailsCubit(
      initialState: const WalletDetailsState(
        selectedWallet: _wallet,
        selectedNetwork: _amoy,
        coins: [_gnus],
        coinsNetwork: _amoy,
        coinsStatus: WalletStatus.successful,
      ),
      geniusApi: _UnusedApi(),
      networkTokensProvider: NetworkTokensProvider(),
    );
    ops = _FakeChildOps(() => app);
    gate = BridgeGateCubit(
      readAppState: () => app,
      appStates: appStream.stream,
      walletDetails: wallet,
      childOperations: ops,
    );
  }

  late AppState app;
  final appStream = StreamController<AppState>.broadcast();
  late final WalletDetailsCubit wallet;
  late final _FakeChildOps ops;
  late final BridgeGateCubit gate;

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

  test('without a registrations read the wallet is not a child', () {
    rig.ops.registrations = null;

    expect(rig.gate.resolveNow().state, BridgeGateState.enabled);
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
}
