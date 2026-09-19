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

/// A percentage for display: at most two decimals, trailing zeros dropped.
///
/// The aggregator sends these as strings at whatever precision it likes, and
/// [SwapQuote] keeps them as strings so no float rounding creeps in between
/// the aggregator and the screen. This is the display step, and the only one.
///
/// Two values are never rendered as a plain `0`: an unreadable string passes
/// through untouched rather than becoming an invented number, and a value too
/// small to survive two decimals renders `~0`, because printing `0` would
/// claim an impact the route does not have.
String formatPercent(String raw) {
  final value = double.tryParse(raw.trim());
  // `toStringAsFixed` throws on a non-finite double, and neither is a
  // percentage anyone can act on.
  if (value == null || !value.isFinite) {
    return raw;
  }
  final rounded = double.parse(value.toStringAsFixed(2));
  if (rounded == 0) {
    return value == 0 ? '0' : '~0';
  }
  return rounded.toString().replaceFirst(RegExp(r'\.0$'), '');
}

/// An amount for display, cut to [max] digits counted from the first
/// significant one. String in, string out: these carry up to 18 digits and a
/// double cannot hold them. Truncates, so it never claims a better price.
String capDecimals(String raw, int max) {
  if (max < 0) {
    return raw;
  }
  final match = RegExp(r'^(\d+)\.(\d+)$').firstMatch(raw.trim());
  if (match == null) {
    return raw;
  }
  final fraction = match.group(2)!;
  if (fraction.length <= max) {
    return raw;
  }
  // Count from the first significant digit, not from the point. Cutting
  // 0.00019999 at the fourth decimal place renders 0.0001 and understates
  // the amount by half — on a token worth $100k that is a $10 misread.
  final lead =
      fraction.length - fraction.replaceFirst(RegExp(r'^0+'), '').length;
  final keep = lead + max;
  final cut = fraction
      .substring(0, keep > fraction.length ? fraction.length : keep)
      .replaceFirst(RegExp(r'0+$'), '');
  // An all-zero remainder means the value really is zero to this precision;
  // rendering it as `0` would claim the route returns nothing.
  if (cut.isEmpty) {
    return raw;
  }
  return '${match.group(1)}.$cut';
}
