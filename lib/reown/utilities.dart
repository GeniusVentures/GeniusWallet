import 'package:genius_api/models/network.dart';
import 'package:genius_api/models/wallet.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:reown_walletkit/reown_walletkit.dart' hide Wallet;

/// The chain a CAIP-2 id names (`eip155:8453` -> 8453), or null for anything
/// that is not an EVM chain id this wallet could act on.
int? eip155ChainId(String caip2) {
  final parts = caip2.split(':');
  if (parts.length != 2 || parts[0] != 'eip155') {
    return null;
  }
  return int.tryParse(parts[1]);
}

/// Whether the wallet can act on a dApp request for [network]: it has a chain
/// id to match the request against and an RPC to send the result through.
/// The catalogue carries entries with neither.
bool canSignOn(Network network) =>
    network.chainId != null && (network.rpcUrl ?? '').isNotEmpty;

/// Whether [wallet] can sign a send on [network]. A tracked wallet holds only
/// an address, and a Super Genius account's key lives in the SDK, not here.
bool canSendFrom(Wallet? wallet, Network? network) =>
    wallet != null &&
    wallet.walletType != WalletType.tracking &&
    wallet.walletType != WalletType.sgnus &&
    network != null &&
    canSignOn(network);

/// The `eip155` namespace to approve a session with: every chain this wallet
/// carries, and the same account on each. A session approved for one chain
/// cannot receive a request for another, however well the wallet decodes it.
Namespace eip155Namespace({
  required Iterable<int> chainIds,
  required String address,
  required List<String> methods,
}) {
  final chains = [for (final id in chainIds) 'eip155:$id'];
  return Namespace(
    chains: chains,
    methods: methods,
    events: const ['chainChanged', 'accountsChanged'],
    accounts: [for (final chain in chains) '$chain:$address'],
  );
}

String formatEth(String weiStr) {
  try {
    final wei = BigInt.parse(weiStr);
    final eth = wei / BigInt.from(10).pow(18);
    return eth.toStringAsFixed(10);
  } catch (_) {
    return '0';
  }
}

BigInt parseHexToBigInt(String? hex) {
  if (hex == null || hex == '0x' || hex == '0x0') {
    return BigInt.zero;
  }
  return BigInt.tryParse(hex.replaceFirst('0x', ''), radix: 16) ?? BigInt.zero;
}
