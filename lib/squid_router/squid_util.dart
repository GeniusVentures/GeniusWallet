String formatTokenAmount(BigInt raw, int decimals) {
  final divisor = BigInt.from(10).pow(decimals);
  final integerPart = raw ~/ divisor;
  final fractionalPart =
      raw.remainder(divisor).toString().padLeft(decimals, '0');
  final trimmedFraction = fractionalPart.replaceFirst(RegExp(r'0+$'), '');
  return trimmedFraction.isEmpty
      ? integerPart.toString()
      : '$integerPart.$trimmedFraction';
}
