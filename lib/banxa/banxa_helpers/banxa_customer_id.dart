/// The Banxa `externalCustomerId` for a wallet — the one key that ties a
/// created order to the order list that later has to find it.
///
/// Lower-cased because EVM addresses are case-insensitive and Banxa matches
/// this field literally. Returns null for a missing address: callers must not
/// substitute a fallback, since an order created under a wrong-but-present id
/// is unrecoverable.
String? banxaCustomerId(String? walletAddress) {
  final address = walletAddress?.trim().toLowerCase();
  if (address == null || address.isEmpty) {
    return null;
  }
  return 'gw-$address';
}
