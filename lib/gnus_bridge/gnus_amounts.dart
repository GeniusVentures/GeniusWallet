// Conversions from the wallet's own amount units to the contract's: every GNUS
// amount is an integer in base units of [kGnusDecimals], as a decimal string.
// This file is the only place the unit is decided. BigInt and string only.

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
