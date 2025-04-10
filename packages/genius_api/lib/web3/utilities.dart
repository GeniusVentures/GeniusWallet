BigInt parseHexToBigInt(String? hex) {
  if (hex == null || hex == '0x' || hex == '0x0') return BigInt.zero;
  return BigInt.tryParse(hex.replaceFirst('0x', ''), radix: 16) ?? BigInt.zero;
}
