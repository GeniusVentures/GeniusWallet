import 'dart:math';

import 'package:genius_wallet/squid_router/squid_util.dart';

/// A token the swap may offer, paired with what the wallet holds of it.
/// Aggregator-neutral — an adapter maps its provider's shape onto this, and
/// nothing above the adapter names a provider type.
class SwapToken {
  const SwapToken({
    required this.chainId,
    required this.address,
    required this.name,
    required this.symbol,
    required this.decimals,
    this.logoUri,
    this.rawBalance,
  });

  final String chainId;
  final String address;
  final String name;
  final String symbol;

  /// As the AGGREGATOR reports it — never read from the contract. A wrong
  /// value misprices every amount by a power of ten, so only values passing
  /// [isPlausibleDecimals] should reach this field.
  final int decimals;

  final String? logoUri;

  /// Base units, or null when the holding is unknown. Absent and zero are
  /// different facts: the CTA must not say "insufficient" on data that never
  /// arrived.
  final BigInt? rawBalance;

  SwapToken withBalance(BigInt? balance) => SwapToken(
    chainId: chainId,
    address: address,
    name: name,
    symbol: symbol,
    decimals: decimals,
    logoUri: logoUri,
    rawBalance: balance,
  );

  /// Token identity. **Address alone is not it** — the same address exists on
  /// several chains and this list is cross-chain, so both halves are
  /// load-bearing. A balance is not part of it.
  bool sameAs(SwapToken? other) =>
      other != null &&
      address.toLowerCase() == other.address.toLowerCase() &&
      chainId == other.chainId;

  /// The holding as a number, or null when it is absent. Nullable rather than
  /// zero because the swap CTA reads the two differently.
  double? get amountAsDouble =>
      rawBalance == null ? null : rawBalance!.toDouble() / pow(10, decimals);

  /// The EXACT holding, every digit. This is what MAX puts in the amount
  /// field, so it may not round — rounding up asks for more than is held and
  /// rounding down strands dust.
  String get formattedBalance =>
      rawBalance == null ? '0' : formatTokenAmount(rawBalance!, decimals);

  /// [formattedBalance] for READING. Never for MAX.
  ///
  /// ponytail: 6 decimals is a readability choice, not a token property. A
  /// token whose meaningful unit is smaller than 1e-6 would read as `0`, so
  /// the branch below says "less than" instead of lying.
  String get displayBalance {
    final value = amountAsDouble;
    if (value == null || value == 0) {
      return '0';
    }
    if (value < 0.000001) {
      return '<0.000001';
    }
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value
        .toStringAsFixed(6)
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }
}

/// Whether a provider-reported decimals value can size an amount at all.
/// On chain it is a uint8 and nothing real exceeds 36. This catches only the
/// absurd — a provider publishing 16 for an 18-decimal token passes.
bool isPlausibleDecimals(num decimals) =>
    decimals >= 0 && decimals <= 36 && decimals == decimals.round();
