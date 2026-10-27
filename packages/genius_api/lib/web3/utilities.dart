BigInt parseHexToBigInt(String? hex) {
  if (hex == null || hex == '0x' || hex == '0x0') return BigInt.zero;
  return BigInt.tryParse(hex.replaceFirst('0x', ''), radix: 16) ?? BigInt.zero;
}

/// The typed amount as raw base units — the integer the router actually
/// spends. String and BigInt only: a double cannot hold 18 significant
/// digits, and this value is the amount of money that moves.
BigInt? toBaseUnits(String amount, int decimals) {
  if (decimals < 0) {
    return null;
  }
  final match = RegExp(r'^(\d*)(?:\.(\d*))?$').firstMatch(amount.trim());
  if (match == null) {
    return null;
  }
  final whole = match.group(1) ?? '';
  final fraction = match.group(2) ?? '';
  if (whole.isEmpty && fraction.isEmpty) {
    return null;
  }
  // Truncate rather than round: the router cannot spend a digit below the
  // token's smallest unit, and rounding up spends more than was typed.
  final scaled = fraction.padRight(decimals, '0').substring(0, decimals);
  return BigInt.parse('0$whole$scaled');
}

/// The GNUS token's decimals, which every GNUS amount in the wallet assumes.
const int gnusTokenDecimals = 18;

/// The exact raw amount `bridgeOut` burns for [amount] whole GNUS, or null when
/// [amount] is not a plain decimal or the token reports [decimals] other than
/// [gnusTokenDecimals], which every GNUS amount the wallet reports assumes.
// ponytail: refuses a GNUS deployment with other decimals rather than
// threading the read value out to every caller. Upgrade: return the decimals
// with the estimate and show amounts in them.
BigInt? gnusBurnBaseUnits(String amount, int decimals) =>
    decimals == gnusTokenDecimals ? toBaseUnits(amount, decimals) : null;
