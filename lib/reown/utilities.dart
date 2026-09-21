import 'package:reown_walletkit/reown_walletkit.dart';

/// The chain a CAIP-2 id names (`eip155:8453` -> 8453), or null for anything
/// that is not an EVM chain id this wallet could act on.
int? eip155ChainId(String caip2) {
  final parts = caip2.split(':');
  if (parts.length != 2 || parts[0] != 'eip155') {
    return null;
  }
  return int.tryParse(parts[1]);
}

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
