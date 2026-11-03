BigInt parseHexToBigInt(String? hex) {
  if (hex == null || hex == '0x' || hex == '0x0') return BigInt.zero;
  return BigInt.tryParse(hex.replaceFirst('0x', ''), radix: 16) ?? BigInt.zero;
}

/// A decimal amount as raw base units, the integer that actually moves on
/// chain. String and BigInt only: a double cannot hold 18 significant
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
  // Truncate rather than round: a chain cannot move a digit below the token's
  // smallest unit, and rounding up spends more than was asked for.
  final scaled = fraction.padRight(decimals, '0').substring(0, decimals);
  return BigInt.parse('0$whole$scaled');
}
