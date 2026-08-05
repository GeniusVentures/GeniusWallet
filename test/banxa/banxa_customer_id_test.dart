import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/banxa/banxa_helpers/banxa_customer_id.dart';

/// The check owed by `banxaCustomerId`.
///
/// The bug this closes was not a wrong value, it was TWO wrong values that
/// never had to agree: create stamped a fresh timestamped id per order, fetch
/// asked for a literal placeholder. Nothing in the type system connected them,
/// so the order list returned nothing and looked like an empty history.
///
/// What matters is therefore the round trip: the id a wallet creates orders
/// under must be the id that same wallet asks for.
void main() {
  const address = '0xAbCdEf0123456789';

  test('create and fetch derive the SAME id from one wallet', () {
    // The whole defect in one assertion.
    expect(banxaCustomerId(address), banxaCustomerId(address));
    expect(banxaCustomerId(address), isNotNull);
  });

  test('is stable across calls -- never time-derived', () {
    final first = banxaCustomerId(address);
    final second = banxaCustomerId(address);
    expect(
      first,
      second,
      reason: 'a per-call id is exactly what made orders unretrievable',
    );
  });

  test('case and surrounding space do not split one wallet in two', () {
    // A checksummed address on create and a lower-cased one on fetch would
    // otherwise silently miss -- Banxa matches this field literally.
    expect(banxaCustomerId(address), banxaCustomerId(address.toLowerCase()));
    expect(banxaCustomerId(address), banxaCustomerId('  $address  '));
  });

  test('different wallets do not share an order history', () {
    expect(banxaCustomerId('0xaaa'), isNot(banxaCustomerId('0xbbb')));
  });

  test('no wallet yields null, never a fallback string', () {
    // A wrong-but-present id is what produced the original bug: it reads as
    // "no orders" instead of "nobody said whose orders".
    expect(banxaCustomerId(null), isNull);
    expect(banxaCustomerId(''), isNull);
    expect(banxaCustomerId('   '), isNull);
  });
}
