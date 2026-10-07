import 'package:equatable/equatable.dart';
import 'package:genius_api/models/coin.dart';
import 'package:genius_api/models/wallet.dart';
import 'package:local_secure_storage/local_secure_storage.dart'
    show SDKAccountLink;

/// Why Bridge is enabled or disabled, highest rank first. Pure Dart: colour
/// and layout stay with the widgets, this file owns precedence and copy.
enum BridgeGateState {
  /// No wallet is selected.
  noWallet,

  /// The wallet holds no key here: a tracked wallet or an SDK account view.
  viewOnly,

  /// The selected wallet is a child of another account.
  child,

  /// An earning switch is pending, so the earning account is not trustworthy.
  switching,

  /// No account is earning yet.
  notStarted,

  /// Another wallet is the earning one. Minting would credit that account.
  notEarning,

  /// The selected network has no RPC to burn on.
  wrongNetwork,

  /// Coins are loading, or loaded for another network, or the probe is out.
  checking,

  /// GNUS is held on another network, not this one.
  gnusElsewhere,

  /// No GNUS on this network, and none found elsewhere.
  noGnus,

  /// The earning wallet holds GNUS here.
  enabled,
}

/// The resolved gate plus what the tap needs: the coin to open and, for
/// [BridgeGateState.gnusElsewhere], the network that holds the GNUS.
class BridgeGate extends Equatable {
  const BridgeGate(this.state, {this.coin, this.elsewhereNetwork});

  final BridgeGateState state;
  final Coin? coin;
  final String? elsewhereNetwork;

  bool get enabled => state == BridgeGateState.enabled;

  String? get caption => bridgeGateCaption(state, network: elsewhereNetwork);

  @override
  List<Object?> get props => [state, coin, elsewhereNetwork];
}

/// What a surface shows before the cubit has read anything: disabled, never
/// enabled by default.
const kBridgeGateUnknown = BridgeGate(BridgeGateState.checking);

/// [gnusElsewhere] is null while the other-network probe has not answered.
BridgeGateState resolveBridgeGate({
  required bool hasWallet,
  required bool walletCanSign,
  required bool isChild,
  required bool isSwitching,
  required String? earningAccount,
  required bool isEarningWallet,
  required bool networkCanSign,
  required bool coinsReady,
  required double? gnusBalance,
  required bool? gnusElsewhere,
}) {
  if (!hasWallet) {
    return BridgeGateState.noWallet;
  }
  if (!walletCanSign) {
    return BridgeGateState.viewOnly;
  }
  if (isChild) {
    return BridgeGateState.child;
  }
  if (isSwitching) {
    return BridgeGateState.switching;
  }
  if (earningAccount == null) {
    return BridgeGateState.notStarted;
  }
  if (!isEarningWallet) {
    return BridgeGateState.notEarning;
  }
  if (!networkCanSign) {
    return BridgeGateState.wrongNetwork;
  }
  if (!coinsReady) {
    return BridgeGateState.checking;
  }
  if ((gnusBalance ?? 0) > 0) {
    return BridgeGateState.enabled;
  }
  if (gnusElsewhere == null) {
    return BridgeGateState.checking;
  }
  return gnusElsewhere ? BridgeGateState.gnusElsewhere : BridgeGateState.noGnus;
}

/// The one-line reason under a disabled Bridge, or null when it is enabled.
String? bridgeGateCaption(BridgeGateState state, {String? network}) {
  switch (state) {
    case BridgeGateState.noWallet:
      return 'Select a wallet to bridge.';
    case BridgeGateState.viewOnly:
      return "View-only wallets can't bridge.";
    case BridgeGateState.child:
      return "Child wallets can't bridge.";
    case BridgeGateState.switching:
      return 'Switching earning. Try again soon.';
    case BridgeGateState.notStarted:
      return 'Start earning to bridge.';
    case BridgeGateState.notEarning:
      return 'Only the earning wallet can bridge.';
    case BridgeGateState.wrongNetwork:
      return "Can't bridge on this network.";
    case BridgeGateState.checking:
      return 'Checking your GNUS balance.';
    case BridgeGateState.gnusElsewhere:
      return (network ?? '').isEmpty
          ? 'GNUS is on another network.'
          : 'GNUS is on $network. Switch network.';
    case BridgeGateState.noGnus:
      return 'You have no GNUS to bridge.';
    case BridgeGateState.enabled:
      return null;
  }
}

/// Whether [wallet] is the one linked to the [earning] account. Looked up
/// earning -> wallet, so a second account linked to the same wallet cannot
/// make another wallet pass.
bool isEarningWallet(
  Wallet wallet,
  String earning,
  Map<String, SDKAccountLink> links,
) =>
    links[earning.toLowerCase()]?.walletAddress.toLowerCase() ==
    wallet.address.toLowerCase();

/// The GNUS token to bridge from. The address requirement rejects the Super
/// Genius native GNUS, which has none and cannot be burned through a contract.
Coin? bridgeCoin(List<Coin> coins) {
  for (final coin in coins) {
    if (coin.symbol?.toLowerCase() == 'gnus' &&
        (coin.address ?? '').isNotEmpty) {
      return coin;
    }
  }
  return null;
}
