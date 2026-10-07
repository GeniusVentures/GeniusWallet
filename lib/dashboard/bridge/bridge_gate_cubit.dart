import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/models/wallet.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/child_wallets/child_operations_cubit.dart';
import 'package:genius_wallet/dashboard/bridge/bridge_gate.dart';
import 'package:genius_wallet/reown/utilities.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';

/// Keeps the Bridge gate current with the earning account, the selected
/// wallet and its coins, so every surface reads one value.
class BridgeGateCubit extends Cubit<BridgeGate> {
  BridgeGateCubit({
    required AppState Function() readAppState,
    required Stream<AppState> appStates,
    required WalletDetailsCubit walletDetails,
    ChildOperationsCubit? childOperations,
  }) : _readAppState = readAppState,
       _walletDetails = walletDetails,
       _childOperations = childOperations,
       super(kBridgeGateUnknown) {
    _appSub = appStates.listen((_) => resolveNow());
    _walletSub = walletDetails.stream.listen((_) => resolveNow());
    _childSub = childOperations?.stream.listen((_) => resolveNow());
    resolveNow();
  }

  final AppState Function() _readAppState;
  final WalletDetailsCubit _walletDetails;
  final ChildOperationsCubit? _childOperations;
  late final StreamSubscription<AppState> _appSub;
  late final StreamSubscription<WalletDetailsState> _walletSub;
  late final StreamSubscription<ChildOperationsState>? _childSub;

  String? _childKey;
  bool _isChild = false;

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

    final isChild = wallet != null && _refreshChild(app, wallet);
    final walletCanSignNow = wallet == null || walletCanSign(wallet);
    final isEarning =
        wallet != null &&
        earning != null &&
        isEarningWallet(wallet, earning, app.sdkAccountLinks);
    final networkCanSignNow = network != null && canSignOn(network);

    BridgeGateState resolve(bool gnusElsewhere) => resolveBridgeGate(
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

    final resolved = resolve(false);
    final gate = BridgeGate(
      resolved,
      coin: resolved == BridgeGateState.enabled ? coin : null,
    );
    if (!isClosed && gate != state) {
      emit(gate);
    }
    return gate;
  }

  /// Whether [wallet] is registered as a child under another own main. Cached
  /// by its inputs, so the SDK read runs on a change, not on every emit.
  // ponytail: only the user's own mains are scanned, so a child of a main
  // they do not own still reads as bridgeable; upgrade is an SDK by-child query.
  bool _refreshChild(AppState app, Wallet wallet) {
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
    _childKey = key;
    final candidates = {
      for (final link in app.sdkAccountLinks.entries)
        if (link.value.walletAddress.toLowerCase() == address)
          link.key.toLowerCase(),
    };
    var child = false;
    if (candidates.isNotEmpty) {
      final registrations = operations.ownRegistrations();
      if (registrations != null) {
        for (final candidate in candidates) {
          for (final entry in registrations.entries) {
            if (entry.key != candidate &&
                entry.value.any((c) => c.address.toLowerCase() == candidate)) {
              child = true;
            }
          }
        }
      }
    }
    return _isChild = child;
  }

  @override
  Future<void> close() {
    _appSub.cancel();
    _walletSub.cancel();
    _childSub?.cancel();
    return super.close();
  }
}
