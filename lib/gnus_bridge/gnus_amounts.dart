// Conversions from the wallet's own amount units to the contract's: every GNUS
// amount is an integer in base units of [kGnusDecimals], as a decimal string.
// This file is the only place the unit is decided. BigInt and string only.

import 'package:genius_wallet/squid_router/squid_util.dart';

// ponytail: assumes the GNUS token has 18 decimals on every chain the wallet
// burns on. `Token` carries no decimals field, so none can be read from the
// app's token info. Upgrade: read `decimals()` from the token contract once per
// chain and cache it.
const int kGnusDecimals = 18;

final BigInt _gnusScale = BigInt.from(10).pow(kGnusDecimals);

/// The SDK job cost (whole GNUS, the integer `bridgeOut` burns) in base units,
/// or null when it is not a positive cost.
String? gnusCostBaseUnits(int wholeGnus) {
  if (wholeGnus <= 0) {
    return null;
  }
  return (BigInt.from(wholeGnus) * _gnusScale).toString();
}

final RegExp _gweiPattern = RegExp(r'^(\d+(?:\.\d+)?) Gwei$');

/// The contract `gas` map from the owner's `"<number> Gwei"` string, or null
/// when the string is not a number (the owner formats a missing price as the
/// literal `"null Gwei"`) or the chain's native symbol is unknown.
Map<String, String>? gnusGasPrice(String? ownerGas, String? nativeSymbol) {
  if (ownerGas == null || nativeSymbol == null || nativeSymbol.isEmpty) {
    return null;
  }
  final match = _gweiPattern.firstMatch(ownerGas);
  if (match == null) {
    return null;
  }
  return {
    'gasPriceGwei': match.group(1)!,
    'symbol': nativeSymbol.toUpperCase(),
  };
}

final RegExp _plainDecimal = RegExp(r'^\d+(?:\.\d+)?$');
final RegExp _exponentDecimal = RegExp(r'^(\d+)(?:\.(\d+))?e([+-]\d+)$');

/// The payer's balance, a whole-GNUS double from the wallet's coin read, in
/// base units, or null when it is not a usable balance. The only double
/// operation is `toString()`, which prints the shortest digits that round-trip.
String? gnusBalanceBaseUnits(double? wholeGnus) {
  if (wholeGnus == null || wholeGnus.isNaN || wholeGnus.isInfinite) {
    return null;
  }
  if (wholeGnus == 0) {
    return '0';
  }
  if (wholeGnus < 0) {
    return null;
  }
  final plain = _expandExponent(wholeGnus.toString());
  if (plain == null) {
    return null;
  }
  return toBaseUnits(plain, kGnusDecimals)?.toString();
}

/// The node's SGNUS balance, the SDK's decimal string with up to 6 decimals,
/// in base units, or null when it does not parse.
String? sgnusBalanceBaseUnits(String sdkBalance) {
  return toBaseUnits(sdkBalance.trim(), kGnusDecimals)?.toString();
}

/// `1.5e+21` or `1e-7` as plain digits; a plain decimal passes through.
String? _expandExponent(String printed) {
  if (_plainDecimal.hasMatch(printed)) {
    return printed;
  }
  final match = _exponentDecimal.firstMatch(printed);
  if (match == null) {
    return null;
  }
  final whole = match.group(1)!;
  final digits = whole + (match.group(2) ?? '');
  final pointAt = whole.length + int.parse(match.group(3)!);
  if (pointAt <= 0) {
    return '0.${'0' * -pointAt}$digits';
  }
  if (pointAt >= digits.length) {
    return digits + '0' * (pointAt - digits.length);
  }
  return '${digits.substring(0, pointAt)}.${digits.substring(pointAt)}';
}
