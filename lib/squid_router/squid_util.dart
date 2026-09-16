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

String formatTokenAmount(BigInt raw, int decimals) {
  final divisor = BigInt.from(10).pow(decimals);
  final integerPart = raw ~/ divisor;
  final fractionalPart = raw
      .remainder(divisor)
      .toString()
      .padLeft(decimals, '0');
  final trimmedFraction = fractionalPart.replaceFirst(RegExp(r'0+$'), '');
  return trimmedFraction.isEmpty
      ? integerPart.toString()
      : '$integerPart.$trimmedFraction';
}
