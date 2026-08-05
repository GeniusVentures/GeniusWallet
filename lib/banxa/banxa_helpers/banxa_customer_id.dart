/// The Banxa `externalCustomerId` for a wallet — the key that ties a created
/// order to the order list that later has to find it.
///
/// Both sides of that round trip were broken independently, which is why this
/// is one function and not two literals:
///
/// - **Create** stamped every order with
///   `'my_id_${DateTime.now().millisecondsSinceEpoch}'` — a NEW customer per
///   order, so no two orders a user placed ever shared a customer key.
/// - **Fetch** asked for the literal `'your-cust-id'` — a placeholder that
///   matches nothing Banxa ever stored.
///
/// The order list could therefore never return a real user's orders, no matter
/// how the screen above it was built.
///
/// The wallet address is the right key: it is stable for the life of the
/// wallet, it is already sent to Banxa as the order's destination (so this
/// discloses nothing new), and it scopes order history per wallet, which is
/// what a user switching wallets expects to see.
///
/// Lower-cased because EVM addresses are case-insensitive and Banxa matches
/// this field literally — a checksummed address on create and a lower-cased
/// one on fetch would silently miss.
///
/// Returns null for a missing or blank address. Callers must NOT substitute a
/// fallback string: querying with a wrong-but-present id is what produced the
/// original bug, and creating an order under one is unrecoverable.
String? banxaCustomerId(String? walletAddress) {
  final address = walletAddress?.trim().toLowerCase();
  if (address == null || address.isEmpty) {
    return null;
  }
  return 'gw-$address';
}
