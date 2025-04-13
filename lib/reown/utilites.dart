String formatEth(String weiStr) {
  try {
    final wei = BigInt.parse(weiStr);
    final eth = wei / BigInt.from(10).pow(18);
    return eth.toStringAsFixed(10);
  } catch (_) {
    return '0';
  }
}

BigInt parseHexToBigInt(String? hex) {
  if (hex == null || hex == '0x' || hex == '0x0') return BigInt.zero;
  return BigInt.tryParse(hex.replaceFirst('0x', ''), radix: 16) ?? BigInt.zero;
}
