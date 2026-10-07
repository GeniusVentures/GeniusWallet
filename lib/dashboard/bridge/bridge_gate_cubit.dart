import 'dart:async';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/models/coin.dart';
import 'package:genius_api/models/network.dart';
import 'package:genius_api/models/wallet.dart';
import 'package:genius_api/web3/web3.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/child_wallets/child_operations_cubit.dart';
import 'package:genius_wallet/dashboard/bridge/bridge_gate.dart';
import 'package:genius_wallet/dev/dev_flags.dart';
import 'package:genius_wallet/reown/utilities.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';

/// Reads a token balance over a public RPC. [Web3.balanceOf] returns 0 when
/// the read fails.
typedef GnusBalanceRead =
    Future<double> Function({
      required String address,
      required String contractAddress,
      required String rpcUrl,
    });

/// A stalled public RPC must not hold the caption on checking.
const _probeTimeout = Duration(seconds: 8);

/// Keeps the Bridge gate current with the earning account, the selected
/// wallet and its coins, so every surface reads one value.
class BridgeGateCubit extends Cubit<BridgeGate> {
  BridgeGateCubit({
    required AppState Function() readAppState,
    required Stream<AppState> appStates,
    required WalletDetailsCubit walletDetails,
    ChildOperationsCubit? childOperations,
    GnusBalanceRead? balanceOf,
  }) : _readAppState = readAppState,
       _walletDetails = walletDetails,
       _childOperations = childOperations,
       _balanceOf = balanceOf ?? Web3().balanceOf,
       super(kBridgeGateUnknown) {
    _appSub = appStates.listen((_) => resolveNow());
    _walletSub = walletDetails.stream.listen((_) => resolveNow());
    _childSub = childOperations?.stream.listen((_) => resolveNow());
    resolveNow();
  }

  final AppState Function() _readAppState;
  final WalletDetailsCubit _walletDetails;
  final ChildOperationsCubit? _childOperations;
  final GnusBalanceRead _balanceOf;
  late final StreamSubscription<AppState> _appSub;
  late final StreamSubscription<WalletDetailsState> _walletSub;
  late final StreamSubscription<ChildOperationsState>? _childSub;

  String? _childKey;
  bool _isChild = false;

  String? _probeKey;
  List<Coin>? _probedCoins;
  int _probeGeneration = 0;

  /// The answer for [_probeKey]: the first other network holding GNUS, or
  /// null for none. A null record means no probe has landed yet.
  ({String? network})? _outcome;

  /// Reads live state now, so a tap never acts on the last frame's gate.
  BridgeGate resolveNow() {
    final app = _readAppState();
    final details = _walletDetails.state;
    final wallet = details.selectedWallet;
    final network = details.selectedNetwork;
    final earning = app.selectedSDKAccount;
    final coinsReady =
        network != null &&
        details.coinsNetwork == network &&
        details.coinsStatus == WalletStatus.successful;
    final coin = coinsReady ? bridgeCoin(details.coins) : null;

    final isChild = wallet == null ? false : _refreshChild(app, wallet);
    final walletCanSignNow = wallet == null || walletCanSign(wallet);
    final isEarning =
        wallet != null &&
        earning != null &&
        isEarningWallet(wallet, earning, app.sdkAccountLinks);
    final networkCanSignNow = network != null && canSignOn(network);

    BridgeGateState resolve(bool? gnusElsewhere) => resolveBridgeGate(
      hasWallet: wallet != null,
      walletCanSign: walletCanSignNow,
      isChild: isChild,
      isSwitching: app.switchingSDKAccount != null,
      earningAccount: earning,
      isEarningWallet: isEarning,
      networkCanSign: networkCanSignNow,
      coinsReady: coinsReady,
      gnusBalance: coin?.balance,
      gnusElsewhere: gnusElsewhere,
    );

    _refreshProbeKey(wallet, network);
    // Probe only when nothing above the other-network rung stops the gate.
    if (wallet != null &&
        network != null &&
        coinsReady &&
        isChild != null &&
        resolve(null) == BridgeGateState.checking &&
        !identical(details.coins, _probedCoins)) {
      _startProbe(wallet, network, details.coins);
    }

    final outcome = _outcome;
    final resolved = resolve(outcome == null ? null : outcome.network != null);
    final gate = BridgeGate(
      resolved,
      coin: resolved == BridgeGateState.enabled ? coin : null,
      elsewhereNetwork: resolved == BridgeGateState.gnusElsewhere
          ? outcome?.network
          : null,
    );
    if (!isClosed && gate != state) {
      emit(gate);
    }
    return gate;
  }

  /// Whether [wallet] is registered as a child under another own main, or null
  /// when the registrations cannot be read. A known answer is cached by its
  /// inputs; an unknown one is read again on the next resolve.
  // ponytail: only the user's own mains are scanned, so a child of a main
  // they do not own still reads as bridgeable; upgrade is an SDK by-child query.
  bool? _refreshChild(AppState app, Wallet wallet) {
    final operations = _childOperations;
    if (operations == null) {
      return false;
    }
    final address = wallet.address.toLowerCase();
    final key = [
      app.selectedSDKAccount?.toLowerCase(),
      app.sdkAccounts.join(','),
      [
        for (final link in app.sdkAccountLinks.entries)
          '${link.key}>${link.value.walletAddress.toLowerCase()}',
      ].join(','),
      address,
      identityHashCode(operations.state),
    ].join('|');
    if (key == _childKey) {
      return _isChild;
    }
    final candidates = {
      for (final link in app.sdkAccountLinks.entries)
        if (link.value.walletAddress.toLowerCase() == address)
          link.key.toLowerCase(),
    };
    var child = false;
    if (candidates.isNotEmpty) {
      final registrations = operations.ownRegistrations();
      if (registrations == null) {
        _childKey = null;
        return null;
      }
      for (final candidate in candidates) {
        for (final entry in registrations.entries) {
          if (entry.key != candidate &&
              entry.value.any((c) => c.address.toLowerCase() == candidate)) {
            child = true;
          }
        }
      }
    }
    _childKey = key;
    return _isChild = child;
  }

  /// A new wallet or network drops the cached outcome and any probe in flight.
  void _refreshProbeKey(Wallet? wallet, Network? network) {
    final key = wallet == null || network == null
        ? null
        : '${wallet.address.toLowerCase()}|${network.chainId}';
    if (key == _probeKey) {
      return;
    }
    _probeKey = key;
    _outcome = null;
    _probedCoins = null;
    _probeGeneration++;
  }

  /// Names the first other network of the same class that holds GNUS. The
  /// answer only picks a caption; it never enables Bridge.
  // ponytail: only networks of the selected one's mainnet/testnet class are
  // probed, and results refresh with the coins, never on a timer; upgrade is
  // probing every class.
  void _startProbe(Wallet wallet, Network current, List<Coin> coins) {
    _probedCoins = coins;
    final generation = ++_probeGeneration;
    if (kDebugMode && kShowDevTools && _walletDetails.mockMode) {
      _outcome = (network: null);
      return;
    }
    final probes = <({String name, String contract, String rpc})>[];
    final tokens = _walletDetails.networkTokensProvider.tokensByNetwork;
    for (final entry in tokens.entries) {
      final other = entry.key;
      final contract = entry.value
          .where(
            (t) =>
                t.name?.toLowerCase() == 'gnus' && (t.address ?? '').isNotEmpty,
          )
          .firstOrNull
          ?.address;
      if ((other.rpcUrl ?? '').isEmpty ||
          other.testnet != current.testnet ||
          other.chainId == current.chainId ||
          contract == null) {
        continue;
      }
      probes.add((
        name: other.name ?? '',
        contract: contract,
        rpc: other.rpcUrl!,
      ));
    }
    if (probes.isEmpty) {
      _outcome = (network: null);
      return;
    }
    final key = _probeKey;
    unawaited(
      Future.wait([
        for (final p in probes)
          _balanceOf(
                address: wallet.address,
                contractAddress: p.contract,
                rpcUrl: p.rpc,
              )
              .timeout(_probeTimeout)
              .then<double>((v) => v, onError: (Object _) => 0.0),
      ]).then((balances) {
        if (isClosed || generation != _probeGeneration || key != _probeKey) {
          return;
        }
        final hit = balances.indexWhere((b) => b > 0);
        _outcome = (network: hit < 0 ? null : probes[hit].name);
        resolveNow();
      }),
    );
  }

  @override
  Future<void> close() {
    _appSub.cancel();
    _walletSub.cancel();
    _childSub?.cancel();
    return super.close();
  }
}
