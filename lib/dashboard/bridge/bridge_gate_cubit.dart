import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
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
  }) : _readAppState = readAppState,
       _walletDetails = walletDetails,
       super(kBridgeGateUnknown) {
    _appSub = appStates.listen((_) => resolveNow());
    _walletSub = walletDetails.stream.listen((_) => resolveNow());
    resolveNow();
  }

  final AppState Function() _readAppState;
  final WalletDetailsCubit _walletDetails;
  late final StreamSubscription<AppState> _appSub;
  late final StreamSubscription<WalletDetailsState> _walletSub;

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

    final resolved = resolveBridgeGate(
      hasWallet: wallet != null,
      walletCanSign: wallet == null || walletCanSign(wallet),
      isChild: false,
      isSwitching: app.switchingSDKAccount != null,
      earningAccount: earning,
      isEarningWallet:
          wallet != null &&
          earning != null &&
          isEarningWallet(wallet, earning, app.sdkAccountLinks),
      networkCanSign: network != null && canSignOn(network),
      coinsReady: coinsReady,
      gnusBalance: coin?.balance,
      gnusElsewhere: false,
    );
    final gate = BridgeGate(
      resolved,
      coin: resolved == BridgeGateState.enabled ? coin : null,
    );
    if (!isClosed && gate != state) {
      emit(gate);
    }
    return gate;
  }

  @override
  Future<void> close() {
    _appSub.cancel();
    _walletSub.cancel();
    return super.close();
  }
}
